package com.huawei.ict.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * AI 服务配置（双引擎）
 * - primary：Ollama 本地大模型（零 Key、零注册、零网络外联）
 * - fallback：内置知识库智能引擎（Ollama 不可用时自动启用，永远能回复）
 *
 * 默认配置已调好，开箱即用，无需填写任何字段。
 * 想要更好效果？安装 Ollama 并运行 ollama pull qwen2.5:3b 即可。
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "app.ai")
public class AiProperties {

    /** 引擎类型：ollama（首选，零依赖需安装） / knowledge（内置知识库） / auto（自动检测） */
    private String engine = "auto";

    /** Ollama 服务地址，默认本地 11434 端口 */
    private String ollamaUrl = "http://localhost:11434";

    /** Ollama 模型名，常用轻量级：qwen2.5:3b、qwen2.5:1.5b、phi3:mini、llama3.2:3b */
    private String ollamaModel = "qwen2.5:3b";

    /** 是否启用流式打字效果（Ollama 走 NDJSON 流；知识库走单次返回） */
    private boolean stream = true;

    /** 单次最大 token */
    private Integer maxTokens = 1024;

    /** 温度（0-1） */
    private Double temperature = 0.7;

    /** 系统提示词（教师身份） */
    private String systemPrompt = "你是华技云·华为ICT智慧实训平台的AI助学智能体，名叫\"华小智\"。你精通华为HCIA/HCIP/HCIE认证的数通（Datacom）、云计算、安全、存储、大数据、鸿蒙等内容。请用中文回答，结构清晰、要点明确；如需列举请使用编号列表；遇到代码请用代码块包裹。";

    /** Ollama 探测超时（毫秒），太短会让首条消息假死 */
    private int probeTimeoutMs = 1500;
}
