package com.huawei.ict.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.huawei.ict.config.AiProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

/**
 * AI 服务（双引擎）
 * 1) 优先：Ollama 本地大模型（http://localhost:11434）
 *    - 免 Key、免注册、免登录、纯本地推理
 *    - 安装方式：https://ollama.com → ollama pull qwen2.5:3b
 * 2) 兜底：内置知识库智能引擎（KnowledgeEngine）
 *    - Ollama 未启动时自动切换
 *    - 基于规则+知识库+模板生成，永不"哑火"
 *
 * 纯 JDK 8 实现，无 Map.of / List.of / java.net.http
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiService {

    private final AiProperties props;
    private final KnowledgeEngine knowledgeEngine;
    private final ObjectMapper mapper = new ObjectMapper();

    /** Ollama 是否可达（懒加载 + 30s 缓存探测结果，避免每次请求都连一次） */
    private volatile Boolean ollamaReachable = null;
    private final AtomicLong lastProbeTime = new AtomicLong(0L);
    private static final long PROBE_CACHE_MS = 30_000L;

    /** 当前生效的引擎名（仅用于前端展示与日志） */
    public String currentEngine() {
        return isOllamaReachable() ? "ollama" : "knowledge";
    }

    private boolean isOllamaReachable() {
        long now = System.currentTimeMillis();
        if (ollamaReachable != null && now - lastProbeTime.get() < PROBE_CACHE_MS) {
            return ollamaReachable;
        }
        if ("knowledge".equalsIgnoreCase(props.getEngine())) {
            ollamaReachable = false;
            lastProbeTime.set(now);
            return false;
        }
        if ("ollama".equalsIgnoreCase(props.getEngine())) {
            // 用户强制指定 ollama 时不做探测，直接用
            ollamaReachable = true;
            lastProbeTime.set(now);
            return true;
        }
        // auto：探测一次
        ollamaReachable = probeOllama();
        lastProbeTime.set(now);
        if (ollamaReachable) {
            log.info("[AI] Ollama 已就绪 → url={} model={}", props.getOllamaUrl(), props.getOllamaModel());
        } else {
            log.info("[AI] Ollama 不可用，自动启用内置知识库引擎");
        }
        return ollamaReachable;
    }

    private boolean probeOllama() {
        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(props.getOllamaUrl() + "/api/tags").openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(props.getProbeTimeoutMs());
            conn.setReadTimeout(props.getProbeTimeoutMs());
            int code = conn.getResponseCode();
            return code >= 200 && code < 300;
        } catch (Exception e) {
            return false;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    // ====================== 非流式 ======================

    public String chat(String userMessage) {
        if (isOllamaReachable()) {
            try {
                return ollamaChat(buildMessages(userMessage), false, null, null, null);
            } catch (Exception e) {
                log.warn("[AI] Ollama 非流式失败，降级到知识库: {}", e.getMessage());
            }
        }
        return knowledgeEngine.generate(userMessage);
    }

    public String chatWithHistory(List<Map<String, String>> history) {
        if (history == null || history.isEmpty()) return "（请输入内容）";
        if (isOllamaReachable()) {
            ArrayList<Map<String, String>> msgs = new ArrayList<>();
            if (props.getSystemPrompt() != null && !props.getSystemPrompt().isEmpty()) {
                HashMap<String, String> sys = new HashMap<>();
                sys.put("role", "system");
                sys.put("content", props.getSystemPrompt());
                msgs.add(sys);
            }
            msgs.addAll(history);
            try {
                return ollamaChatFromMap(msgs, false, null, null, null);
            } catch (Exception e) {
                log.warn("[AI] Ollama 多轮非流式失败，降级: {}", e.getMessage());
            }
        }
        // 知识库降级
        StringBuilder sb = new StringBuilder();
        for (Map<String, String> m : history) {
            if ("user".equals(m.get("role"))) sb.append(m.get("content")).append("\n");
        }
        return knowledgeEngine.generate(sb.toString().trim());
    }

    // ====================== 流式 ======================

    public void chatStream(String userMessage,
                           java.util.function.Consumer<String> onDelta,
                           Runnable onDone,
                           java.util.function.Consumer<Throwable> onError) {
        chatStream(buildMessages(userMessage), onDelta, onDone, onError);
    }

    public void chatStream(List<Map<String, String>> historyWithSystem,
                           java.util.function.Consumer<String> onDelta,
                           Runnable onDone,
                           java.util.function.Consumer<Throwable> onError) {
        if (isOllamaReachable()) {
            try {
                ollamaChatFromMap(historyWithSystem, true, onDelta, onDone, onError);
                return;
            } catch (Exception e) {
                log.warn("[AI] Ollama 流式失败，降级到知识库: {}", e.getMessage());
            }
        }
        // 知识库降级（模拟打字机）
        try {
            String lastUser = "";
            for (int i = historyWithSystem.size() - 1; i >= 0; i--) {
                Map<String, String> m = historyWithSystem.get(i);
                if ("user".equals(m.get("role"))) {
                    lastUser = m.get("content");
                    break;
                }
            }
            final String answer = knowledgeEngine.generate(lastUser);
            simulateStream(answer, onDelta, onDone);
        } catch (Exception e) {
            if (onError != null) onError.accept(e);
            onDone.run();
        }
    }

    // ====================== 错题 AI 解析 ======================

    /**
     * 为错题生成 AI 解析。
     * 优先调用 Ollama 本地大模型；不可用时返回结构化本地解析。
     */
    public String explainWrongAnswer(String questionContent, String options, String questionType,
                                     String correctAnswer, String userAnswer) {
        String prompt = buildExplanationPrompt(questionContent, options, questionType, correctAnswer, userAnswer);
        if (isOllamaReachable()) {
            try {
                return ollamaChat(buildMessages(prompt), false, null, null, null);
            } catch (Exception e) {
                log.warn("[AI] 错题解析 Ollama 失败，降级到本地解析: {}", e.getMessage());
            }
        }
        return generateLocalExplanation(questionContent, options, questionType, correctAnswer, userAnswer);
    }

    private String buildExplanationPrompt(String questionContent, String options, String questionType,
                                          String correctAnswer, String userAnswer) {
        StringBuilder sb = new StringBuilder();
        sb.append("你是一名华为 ICT 智慧实训平台的 AI 助教，专门为学生分析错题。请用中文回答，结构清晰。\n\n");
        sb.append("题目类型：").append(questionType == null ? "未知" : questionType).append("\n");
        sb.append("题目内容：").append(questionContent == null ? "" : questionContent).append("\n");
        if (options != null && !options.trim().isEmpty()) {
            sb.append("选项：").append(options).append("\n");
        }
        sb.append("学生答案：").append(userAnswer == null ? "未作答" : userAnswer).append("\n");
        sb.append("正确答案：").append(correctAnswer == null ? "未知" : correctAnswer).append("\n\n");
        sb.append("请按以下结构给出解析：\n");
        sb.append("1. 知识点定位：本题考查的核心知识点是什么。\n");
        sb.append("2. 错因分析：学生选择 \"").append(userAnswer == null ? "" : userAnswer)
          .append("\" 为什么不对。\n");
        sb.append("3. 正确解析：为什么正确答案是 \"").append(correctAnswer == null ? "" : correctAnswer)
          .append("\"，请结合原理说明。\n");
        sb.append("4. 记忆技巧：给出一句帮助记忆的口诀或要点。");
        return sb.toString();
    }

    private String generateLocalExplanation(String questionContent, String options, String questionType,
                                              String correctAnswer, String userAnswer) {
        StringBuilder sb = new StringBuilder();
        sb.append("【AI 解析】\n\n");
        sb.append("1. 知识点定位\n");
        sb.append("本题主要考查华为 ICT 相关知识。题干关键词：")
          .append(extractKeywords(questionContent)).append("。\n\n");
        sb.append("2. 错因分析\n");
        sb.append("你选择的答案 \"").append(userAnswer == null ? "未作答" : userAnswer)
          .append("\" 不符合题意，可能是对概念理解不够准确或混淆了相似知识点。\n\n");
        sb.append("3. 正确解析\n");
        sb.append("正确答案是 \"").append(correctAnswer == null ? "未知" : correctAnswer).append("\"。\n");
        sb.append("建议回到「课程学习」模块复习该知识点，并通过「云端实训」进行动手实验，加深理解。\n\n");
        sb.append("4. 记忆技巧\n");
        sb.append("遇到类似题目时，先定位题干考查的核心概念，再逐个排除明显错误的选项，最后结合正确答案对应的原理进行验证。");
        return sb.toString();
    }

    private String extractKeywords(String text) {
        if (text == null) return "";
        // 简单提取华为 ICT 常见关键词
        String[] keywords = {
            "OSPF", "VLAN", "STP", "RSTP", "BGP", "ACL", "NAT", "TCP", "IP",
            "VPC", "ECS", "EIP", "子网", "安全组", "路由表", "HCIA", "HCIP", "HCIE",
            "Datacom", "云计算", "鸿蒙", "ArkTS", "HarmonyOS", "链路聚合", "默认路由",
            "静态路由", "动态路由", "IP 地址", "子网掩码", "DHCP", "DNS", "HTTP", "HTTPS"
        };
        StringBuilder found = new StringBuilder();
        for (String kw : keywords) {
            if (text.toUpperCase().contains(kw.toUpperCase())) {
                if (found.length() > 0) found.append("、");
                found.append(kw);
            }
        }
        return found.length() > 0 ? found.toString() : "相关技术概念";
    }

    private List<Map<String, String>> buildMessages(String userMessage) {
        ArrayList<Map<String, String>> list = new ArrayList<>();
        if (props.getSystemPrompt() != null && !props.getSystemPrompt().isEmpty()) {
            HashMap<String, String> sys = new HashMap<>();
            sys.put("role", "system");
            sys.put("content", props.getSystemPrompt());
            list.add(sys);
        }
        HashMap<String, String> user = new HashMap<>();
        user.put("role", "user");
        user.put("content", userMessage);
        list.add(user);
        return list;
    }

    // ====================== 内部：Ollama 调用 ======================

    private String ollamaChatFromMap(List<Map<String, String>> messages,
                                     boolean stream,
                                     java.util.function.Consumer<String> onDelta,
                                     Runnable onDone,
                                     java.util.function.Consumer<Throwable> onError) throws IOException {
        Map<String, Object> body = new HashMap<>();
        body.put("model", props.getOllamaModel());
        body.put("messages", messages);
        body.put("stream", stream);
        Map<String, Object> options = new HashMap<>();
        options.put("temperature", props.getTemperature());
        options.put("num_predict", props.getMaxTokens());
        body.put("options", options);
        return ollamaPost(body, stream, onDelta, onDone, onError);
    }

    /** 兼容旧 DTO 风格的入口（按 message 列表） */
    private String ollamaChat(List<Map<String, String>> messages,
                              boolean stream,
                              java.util.function.Consumer<String> onDelta,
                              Runnable onDone,
                              java.util.function.Consumer<Throwable> onError) throws IOException {
        return ollamaChatFromMap(messages, stream, onDelta, onDone, onError);
    }

    private String ollamaPost(Map<String, Object> body,
                              boolean stream,
                              java.util.function.Consumer<String> onDelta,
                              Runnable onDone,
                              java.util.function.Consumer<Throwable> onError) throws IOException {
        String json = mapper.writeValueAsString(body);
        HttpURLConnection conn = (HttpURLConnection) new URL(props.getOllamaUrl() + "/api/chat").openConnection();
        try {
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(120000);
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", stream ? "application/x-ndjson" : "application/json");
            conn.getOutputStream().write(json.getBytes(StandardCharsets.UTF_8));
            conn.getOutputStream().flush();

            int code = conn.getResponseCode();
            if (code < 200 || code >= 300) {
                String err = readAll(conn.getErrorStream());
                throw new IOException("Ollama HTTP " + code + " " + err);
            }
            if (!stream) {
                String resp = readAll(conn.getInputStream());
                JsonNode node = mapper.readTree(resp);
                JsonNode msg = node.get("message");
                if (msg != null && msg.has("content")) {
                    return msg.get("content").asText();
                }
                return "（空响应）";
            }
            // 流式：NDJSON，每行一个 JSON
            try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.isEmpty()) continue;
                    try {
                        JsonNode node = mapper.readTree(line);
                        if (node.has("done") && node.get("done").asBoolean()) break;
                        JsonNode msg = node.get("message");
                        if (msg != null && msg.has("content")) {
                            String content = msg.get("content").asText();
                            if (content != null && !content.isEmpty() && onDelta != null) {
                                onDelta.accept(content);
                            }
                        }
                    } catch (Exception ignore) {}
                }
            }
            if (onDone != null) onDone.run();
            return null;
        } finally {
            conn.disconnect();
        }
    }

    private String readAll(InputStream is) throws IOException {
        if (is == null) return "";
        StringBuilder sb = new StringBuilder();
        byte[] buf = new byte[2048];
        int n;
        while ((n = is.read(buf)) > 0) sb.append(new String(buf, 0, n, StandardCharsets.UTF_8));
        return sb.toString();
    }

    /** 知识库兜底：模拟流式打字机 */
    private void simulateStream(String answer, java.util.function.Consumer<String> onDelta, Runnable onDone) {
        new Thread(() -> {
            try {
                // 按 1~3 字一片推送，模拟真实大模型
                int i = 0;
                int n = answer.length();
                while (i < n) {
                    int step = 1 + (int) (Math.random() * 3);
                    int end = Math.min(i + step, n);
                    onDelta.accept(answer.substring(i, end));
                    i = end;
                    Thread.sleep(18);
                }
            } catch (Exception e) {
                if (onDelta != null) onDelta.accept("【生成中断】" + e.getMessage());
            } finally {
                if (onDone != null) onDone.run();
            }
        }, "kb-stream").start();
    }
}
