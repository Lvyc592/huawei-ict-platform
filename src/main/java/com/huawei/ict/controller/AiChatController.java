package com.huawei.ict.controller;

import com.huawei.ict.dto.ApiResponse;
import com.huawei.ict.service.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 助学智能体 Controller
 * 提供非流式 / SSE 流式两种对话能力
 * 引擎自动选择：Ollama 本地大模型（首选） → 内置知识库（兜底）
 * 注：本项目基于 Java 8，不使用 Map.of / List.of（Java 9+）
 */
@Slf4j
@RestController
@RequestMapping("/api/student/ai")
@RequiredArgsConstructor
public class AiChatController {

    private final AiService aiService;

    /**
     * 健康检查 / 引擎状态
     * GET /api/student/ai/status
     */
    @GetMapping("/status")
    public ApiResponse<Map<String, Object>> status() {
        Map<String, Object> data = new HashMap<>();
        data.put("engine", aiService.currentEngine());
        return ApiResponse.ok(data);
    }

    /**
     * 非流式对话
     * POST /api/student/ai/chat
     * body: { "message": "xxx" } 或 { "messages": [ {"role":"user","content":"xx"} ] }
     */
    @PostMapping("/chat")
    public ApiResponse<Map<String, Object>> chat(@RequestBody Map<String, Object> body) {
        Object msgs = body.get("messages");
        String answer;
        if (msgs instanceof List) {
            @SuppressWarnings("unchecked")
            List<Map<String, String>> history = (List<Map<String, String>>) msgs;
            answer = aiService.chatWithHistory(history);
        } else {
            String message = body.get("message") == null ? "" : body.get("message").toString();
            answer = aiService.chat(message);
        }
        Map<String, Object> data = new HashMap<>();
        data.put("answer", answer);
        data.put("engine", aiService.currentEngine());
        return ApiResponse.ok(data);
    }

    /**
     * SSE 流式对话
     * POST /api/student/ai/chat/stream
     */
    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chatStream(@RequestBody Map<String, Object> body) {
        SseEmitter emitter = new SseEmitter(180000L);
        emitter.onTimeout(() -> {
            log.warn("SSE 连接超时");
            try { emitter.complete(); } catch (Exception ignore) {}
        });
        emitter.onError(t -> log.warn("SSE 客户端断开: {}", t == null ? "null" : t.getMessage()));

        try {
            // 构造 messages 列表
            List<Map<String, String>> messages = new ArrayList<>();
            Object msgs = body.get("messages");
            if (msgs instanceof List) {
                @SuppressWarnings("unchecked")
                List<Map<String, String>> history = (List<Map<String, String>>) msgs;
                for (Map<String, String> m : history) {
                    Map<String, String> copy = new HashMap<>();
                    copy.put("role", m.get("role"));
                    copy.put("content", m.get("content"));
                    messages.add(copy);
                }
            } else {
                String message = body.get("message") == null ? "" : body.get("message").toString();
                Map<String, String> userMsg = new HashMap<>();
                userMsg.put("role", "user");
                userMsg.put("content", message);
                messages.add(userMsg);
            }
            log.info("[AI] 流式请求，消息条数={}，引擎={}", messages.size(), aiService.currentEngine());
            aiService.chatStream(messages,
                    delta -> {
                        try { emitter.send(SseEmitter.event().data(delta)); }
                        catch (IOException e) { try { emitter.completeWithError(e); } catch (Exception ignore) {} }
                    },
                    () -> {
                        try { emitter.send(SseEmitter.event().name("done").data("[DONE]")); }
                        catch (IOException ignored) {}
                        try { emitter.complete(); } catch (Exception ignore) {}
                    },
                    err -> {
                        log.error("SSE 回调异常", err);
                        try { emitter.send(SseEmitter.event().name("error").data("【流式异常】" + err.getMessage())); }
                        catch (IOException ignored) {}
                        try { emitter.completeWithError(err); } catch (Exception ignore) {}
                    }
            );
        } catch (Exception e) {
            log.error("AI 流式对话初始化失败", e);
            try { emitter.send(SseEmitter.event().name("error").data("【初始化失败】" + e.getMessage())); }
            catch (IOException ignored) {}
            try { emitter.completeWithError(e); } catch (Exception ignore) {}
        }
        return emitter;
    }
}
