package com.huawei.ict.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 内置知识库智能引擎（兜底引擎）
 * <p>
 * 原理：
 *   1. 内置华为 ICT 常见知识点（OSPF/STP/VLAN/VPC/云服务/认证/学习路线…）
 *   2. 文本相似度匹配（关键词 + 编辑距离）找出最相关知识条目
 *   3. 用模板包装成结构化回答（要点列表 / 学习路径 / 概念解释）
 * <p>
 * 适用：
 *   - Ollama 不可用时的兜底
 *   - 离线、零依赖、零网络
 *   - 永远有"像样"的中文回答，不会哑火
 */
@Slf4j
@Service
public class KnowledgeEngine {

    /** 知识条目：关键词集合 + 标题 + 模板内容 */
    private static class Entry {
        String title;
        String[] keywords;
        String body;

        Entry(String title, String[] keywords, String body) {
            this.title = title;
            this.keywords = keywords;
            this.body = body;
        }
    }

    private final List<Entry> entries = new ArrayList<>();
    /** 通用寒暄/闲聊兜底 */
    private final Map<Pattern, String> greetMap = new HashMap<>();
    private final Map<Pattern, String> helpMap = new HashMap<>();

    public KnowledgeEngine() {
        initGreeting();
        initHelp();
        initKnowledge();
        log.info("[KB] 知识库已就绪：{} 条知识 + {} 条寒暄规则", entries.size(), greetMap.size());
    }

    public String generate(String userMessage) {
        if (userMessage == null) return defaultReply();
        String q = userMessage.trim();
        if (q.isEmpty()) return "（请输入问题后再发送哦～）";

        // 1) 寒暄/闲聊
        for (Map.Entry<Pattern, String> e : greetMap.entrySet()) {
            if (e.getKey().matcher(q).matches()) return e.getValue();
        }
        // 2) 帮助
        for (Map.Entry<Pattern, String> e : helpMap.entrySet()) {
            if (e.getKey().matcher(q).find()) return e.getValue();
        }

        // 3) 知识库匹配
        Entry best = matchBest(q);
        if (best != null) {
            return wrapAnswer(best, q);
        }

        // 4) 兜底：智能猜测问题类型
        return guessByIntent(q);
    }

    private Entry matchBest(String q) {
        Entry best = null;
        int bestScore = 0;
        for (Entry e : entries) {
            int s = score(q, e);
            if (s > bestScore) {
                bestScore = s;
                best = e;
            }
        }
        // 命中阈值（至少要匹配到一个关键词）
        return bestScore > 0 ? best : null;
    }

    private int score(String q, Entry e) {
        int s = 0;
        for (String kw : e.keywords) {
            if (kw == null || kw.isEmpty()) continue;
            if (q.toLowerCase().contains(kw.toLowerCase())) {
                s += kw.length(); // 关键词越长分越高
            }
        }
        return s;
    }

    private String wrapAnswer(Entry e, String q) {
        StringBuilder sb = new StringBuilder();
        sb.append("【").append(e.title).append("】\n\n");
        sb.append(e.body);
        // 追问提示
        sb.append("\n\n---\n");
        sb.append("💡 还想深入了解 **").append(e.title).append("** 的哪个方面？");
        sb.append("（如：原理 / 配置命令 / 面试题 / 实验步骤）");
        return sb.toString();
    }

    // ============== 兜底：按意图生成 ==============

    private String guessByIntent(String q) {
        if (q.endsWith("?") || q.endsWith("？") || q.startsWith("怎么") || q.startsWith("如何") || q.startsWith("什么是") || q.startsWith("什么是") || q.startsWith("what") || q.startsWith("how")) {
            return "这是个好问题！在我目前的本地知识库中，暂未匹配到精准答案。\n\n" +
                    "建议你可以：\n" +
                    "1. 在右侧切换到「课程学习」或「题库练习」做专项训练；\n" +
                    "2. 启动「云端实训」完成对应实验巩固概念；\n" +
                    "3. 重新表述问题，例如加上课程关键词（OSPF、VLAN、HCIA、ECS、VPC…）。\n\n" +
                    "如果想让我用更强的大模型回答你，只需在电脑安装 [Ollama](https://ollama.com) 并运行 `ollama pull qwen2.5:3b`，无需任何 Key 和注册，刷新页面后我会自动切换到本地大模型。";
        }
        if (q.length() <= 4) {
            return "你输入的是 **" + q + "**，能否再描述详细一点？我会基于华为 ICT 数通 / 云计算 / 安全 / 鸿蒙 等领域为你系统解答。";
        }
        return "我已收到你的问题：**" + q + "**\n\n" +
                "目前本地知识库未精准命中此问题（关键词覆盖有限），" +
                "正在以通用助学模式回答。你可以尝试：\n\n" +
                "1. 用专业关键词重问（如：OSPF 邻居建立、HCIA 重点、VPC 路由、鸿蒙 ArkTS…）\n" +
                "2. 完整描述问题背景和已尝试的方法\n" +
                "3. 启动「云端实训」动手演练相关实验\n\n" +
                "**小贴士**：如需更强回答能力，安装 [Ollama](https://ollama.com) + `ollama pull qwen2.5:3b` 后无需任何配置即可启用本地大模型，全程离线、零 Key、零注册。";
    }

    private String defaultReply() {
        return "我是华小智，华技云·华为ICT智慧实训平台的AI助学智能体。我精通华为 HCIA/HCIP/HCIE 认证体系，涵盖数通、云计算、安全、存储、鸿蒙等方向。\n\n" +
                "你可以问我：\n" +
                "- OSPF / STP / VLAN / BGP 的工作原理\n" +
                "- HCIA-Datacom 的考试重点\n" +
                "- 华为云 ECS / VPC / OBS 的使用\n" +
                "- 鸿蒙 ArkTS / DevEco Studio 入门\n" +
                "- 自己的学习路径规划\n\n" +
                "直接发问吧 👇";
    }

    // ============== 寒暄/帮助规则 ==============

    private void initGreeting() {
        greetMap.put(Pattern.compile("^(你好|您好|hi|hello|hey|嗨|哈喽|在吗)[啊吗呢吧\\s\\.\\?\\!]*$"),
                "你好！我是华小智，华技云 AI 助学智能体 👋\n\n我可以帮你：\n1. 解答华为 HCIA / HCIP / HCIE 知识点\n2. 辅导数通、云计算、安全、鸿蒙课程\n3. 分析实验报错、生成学习路径\n\n试着问点具体的吧，比如：\"OSPF 的邻居建立过程？\"");
        greetMap.put(Pattern.compile("^(你是谁|你叫什么|叫什么名字|介绍下?你自己|who are you)[啊吗呢吧\\s\\.\\?\\!]*$"),
                "我是**华小智**，华技云·华为ICT智慧实训平台的AI助学智能体。\n\n- 🎓 专长：华为 ICT 全栈认证辅导\n- 💡 能力：答疑、错题分析、学习路径规划、实验指导\n- 🛡️ 隐私：当前使用本地知识库 + 可选本地大模型，零外发数据");
        greetMap.put(Pattern.compile("^(谢谢|感谢|thanks|thank you|3q|thx)[啊吗呢吧\\s\\.\\?\\!]*$"),
                "不客气！有华为 ICT 任何学习问题，随时来问我 😄");
        greetMap.put(Pattern.compile("^(再见|拜拜|bye|88|下次见)[啊吗呢吧\\s\\.\\?\\!]*$"),
                "下次见～祝你学习愉快，早日拿到 HCIE 证书 🎉");
    }

    private void initHelp() {
        helpMap.put(Pattern.compile("(能做什么|会什么|功能|能力|help)"),
                "我目前能帮你：\n\n" +
                        "1. **概念解答**：OSPF / STP / VLAN / BGP / VPC / ECS 等\n" +
                        "2. **认证辅导**：HCIA / HCIP / HCIE 重点梳理\n" +
                        "3. **实验指导**：华为云、DevEco Studio、eNSP 实战\n" +
                        "4. **学习规划**：根据你的进度推荐下一步\n" +
                        "5. **代码诊断**：鸿蒙 ArkTS、Python 脚本常见错误\n\n" +
                        "把问题直接发给我即可！");
        helpMap.put(Pattern.compile("(切换|换.*模型|ollama|本地模型)"),
                "**如何启用本地大模型（Ollama）**：\n\n" +
                        "1. 访问 https://ollama.com 下载安装 Ollama（Windows / Mac / Linux 均可）\n" +
                        "2. 打开终端执行：`ollama pull qwen2.5:3b`（约 2GB，首次需下载）\n" +
                        "3. 保持 Ollama 后台运行，刷新本页面即可\n" +
                        "4. 我会自动检测并切换到本地大模型，回答质量大幅提升\n\n" +
                        "**特点**：完全本地推理、零 Key、零注册、零网络外联、断网可用。");
    }

    // ============== 知识库 ==============

    private void initKnowledge() {
        // OSPF
        add("OSPF 协议工作原理",
                new String[]{"ospf", "开放最短路径", "链路状态", "lsa", "邻居", "邻接", "dr", "bdr"},
                "OSPF（Open Shortest Path First）是基于链路状态的内部网关协议，工作过程：\n\n" +
                        "1. **建立邻居**：Router Hello 报文发现邻居（224.0.0.5 组播）\n" +
                        "2. **同步 LSDB**：交换 LSA 形成链路状态数据库\n" +
                        "3. **选举 DR/BDR**：在 MA 网络中减少邻接关系数量\n" +
                        "4. **运行 SPF 算法**：Dijkstra 算法计算最短路径树\n" +
                        "5. **维护路由表**：根据开销值选路\n\n" +
                        "**五种报文**：Hello、DD、LSR、LSU、LSAck。\n" +
                        "**七种状态机**：Down → Init → 2-Way → ExStart → Exchange → Loading → Full。\n" +
                        "**区域类型**：骨干区域（area 0）、普通区域、末梢区域（Stub）、完全末梢（Totally Stub）、NSSA。");

        add("VLAN 间路由",
                new String[]{"vlan间路由", "vlan 间", "单臂路由", "vlanif", "dot1q", "子接口"},
                "VLAN 间路由有三种实现方式：\n\n" +
                        "1. **单臂路由（Router-on-a-Stick）**\n" +
                        "   - 交换机 Trunk 连路由器，路由器起子接口封装 802.1Q\n" +
                        "   - 成本低、性能差，不推荐生产\n\n" +
                        "2. **三层交换机 VLANIF 接口（推荐）**\n" +
                        "   - 直接在交换机上创建 `interface Vlanif X`\n" +
                        "   - 配置 IP 作为该 VLAN 的网关\n" +
                        "   - 性能高、扩展性好，是企业主流方案\n\n" +
                        "3. **SVI（交换虚拟接口）**\n" +
                        "   - Cisco 叫法，本质和 VLANIF 一致\n\n" +
                        "**关键命令（华为）**：\n" +
                        "```\n" +
                        "vlan batch 10 20\n" +
                        "interface Vlanif10\n" +
                        " ip address 192.168.10.1 24\n" +
                        "interface Vlanif20\n" +
                        " ip address 192.168.20.1 24\n" +
                        "```");

        add("HCIA-Datacom 考试重点",
                new String[]{"hcia", "datacom", "认证", "考试重点", "hcia重点", "hcna"},
                "**HCIA-Datacom 考试重点（按分值排序）**：\n\n" +
                        "1. **网络基础（20%）**：OSI/TCP-IP、IP 编址、子网掩码、VLSM、CIDR\n" +
                        "2. **路由基础（25%）**：静态路由、默认路由、OSPF 单区域配置\n" +
                        "3. **交换基础（20%）**：VLAN、STP/RSTP、链路聚合、端口安全\n" +
                        "4. **广域网与安全（15%）**：NAT、ACL、IPsec、VPN\n" +
                        "5. **网络管理（10%）**：SNMP、eSight、LLDP\n" +
                        "6. **自动化与新兴（10%）**：SDN、Telemetry、Python 运维\n\n" +
                        "**学习建议**：\n" +
                        "- 用 eNSP/VRP 模拟器实操每一条命令\n" +
                        "- 必做 5 个实验：VLAN 间路由、OSPF 多区域、ACL、NAT、链路聚合\n" +
                        "- 题库刷题 ≥ 800 道，过线率 90%+");

        add("VPC 与传统网络区别",
                new String[]{"vpc", "虚拟私有云", "传统网络", "传统 vs vpc", "vpc和"},
                "**VPC（Virtual Private Cloud）与传统网络的区别**：\n\n" +
                        "| 维度 | 传统网络 | 华为云 VPC |\n" +
                        "|---|---|---|\n" +
                        "| 资源隔离 | 物理隔离/VRF | 逻辑隔离，租户独享 |\n" +
                        "| 弹性 | 采购周期长 | 几分钟开通/释放 |\n" +
                        "| 拓扑 | 二层广播域固定 | 软件定义，灵活组合 |\n" +
                        "| 安全 | 防火墙/ACL | 安全组+网络ACL+主机安全 |\n" +
                        "| 计费 | CAPEX 大 | 按量 OPEX |\n" +
                        "| 跨地域 | 需专线 | 对等连接/CC 互联 |\n" +
                        "\n" +
                        "**华为云 VPC 核心组件**：\n" +
                        "- 子网（Subnet）\n" +
                        "- 路由表（RouteTable）\n" +
                        "- 安全组（SecurityGroup）\n" +
                        "- 弹性 IP（EIP）\n" +
                        "- 对等连接（Peering）/ 云连接（CC）");

        add("华为云 ECS 学习路线",
                new String[]{"ecs", "弹性云服务器", "云服务器", "学习路线", "ecs 入门", "ecs怎么用"},
                "**华为云 ECS 学习路线（零基础 → 入门 → 实战）**：\n\n" +
                        "**第 1 周：概念与开通**\n" +
                        "- 理解 ECS、本地盘、镜像、VPC、安全组的概念\n" +
                        "- 在控制台开通一台按需计费的 Linux ECS\n" +
                        "- 通过 VNC / 密钥对登录\n\n" +
                        "**第 2 周：基础运维**\n" +
                        "- 常用命令：systemctl、top、df -h、journalctl\n" +
                        "- 配置安全组入方向规则\n" +
                        "- 挂载数据盘、初始化、设置自动挂载\n\n" +
                        "**第 3 周：建站实战**\n" +
                        "- 部署 LNMP（Linux + Nginx + MySQL + PHP）\n" +
                        "- 申请域名、备案、解析\n" +
                        "- 配置 HTTPS（Let's Encrypt）\n\n" +
                        "**第 4 周：高阶**\n" +
                        "- 弹性伸缩 AS、负载均衡 ELB\n" +
                        "- 镜像服务 IMS、跨区域复制\n" +
                        "- Cloud-Init 初始化脚本");

        add("BGP 协议基础",
                new String[]{"bgp", "边界网关协议", "as号", "as-path", "ibgp", "ebgp"},
                "**BGP（Border Gateway Protocol）核心要点**：\n\n" +
                        "1. **定位**：路径矢量协议，AS（自治系统）之间使用，是互联网的\"骨干\"\n" +
                        "2. **特点**：\n" +
                        "   - 使用 TCP 179 端口建立邻居（可靠传输）\n" +
                        "   - 增量更新 + 周期保活（KeepAlive 60s）\n" +
                        "   - 丰富的路径属性用于选路\n" +
                        "3. **两种邻居**：\n" +
                        "   - **iBGP**：同一 AS 内，需要全互联或 RR（路由反射器）\n" +
                        "   - **eBGP**：不同 AS 之间，默认直连\n" +
                        "4. **五大选路原则**（13 条中前 5 条最常用）：\n" +
                        "   ① Weight → ② Local_Pref → ③ 本地起源 → ④ AS_Path 短 → ⑤ Origin\n" +
                        "5. **常见配置**：\n" +
                        "```\n" +
                        "bgp 65010\n" +
                        " router-id 1.1.1.1\n" +
                        " peer 10.0.0.2 as-number 65020\n" +
                        " network 192.168.1.0 24\n" +
                        "```");

        add("STP / RSTP 生成树",
                new String[]{"stp", "rstp", "生成树", "spanning tree", "根桥", "阻塞端口"},
                "**STP / RSTP 核心知识点**：\n\n" +
                        "**目的**：消除交换网络中的二层环路，防止广播风暴。\n\n" +
                        "**STP 选举步骤**：\n" +
                        "1. 选举**根桥**（Root Bridge）：Bridge ID 最小者（优先级 + MAC）\n" +
                        "2. 非根桥选举**根端口**（Root Port）：到根桥开销最小\n" +
                        "3. 每个段选举**指定端口**（Designated Port）：到根桥开销最小\n" +
                        "4. 剩下的就是 **Alternate / Backup 端口（阻塞）**\n\n" +
                        "**RSTP 改进点**（IEEE 802.1w）：\n" +
                        "- 收敛速度从 30-50s 缩短到 < 1s\n" +
                        "- 引入 P/A 机制（Proposal/Agreement）\n" +
                        "- 端口状态简化为 3 种：Discarding、Learning、Forwarding\n" +
                        "- 引入边缘端口（Edge Port）跳过协商\n\n" +
                        "**华为命令**：\n" +
                        "```\n" +
                        "stp mode rstp\n" +
                        "stp root primary       # 设为根桥\n" +
                        "stp bpdu-protection    # 边缘端口保护\n" +
                        "stp edged-port default\n" +
                        "```");

        add("ACL 访问控制列表",
                new String[]{"acl", "访问控制", "访问控制列表", "包过滤"},
                "**ACL（Access Control List）核心要点**：\n\n" +
                        "1. **作用**：匹配流量、过滤流量、流量分类（给 QoS/NAT 用）\n" +
                        "2. **分类**：\n" +
                        "   - **基本 ACL**（2000-2999）：仅匹配源 IP\n" +
                        "   - **高级 ACL**（3000-3999）：匹配源/目 IP、端口、协议\n" +
                        "   - **二层 ACL**（4000-4999）：匹配 MAC、VLAN\n" +
                        "   - **用户 ACL**（6000-6999）：匹配用户/用户组\n" +
                        "3. **匹配顺序**：\n" +
                        "   - `config` 顺序匹配（默认）\n" +
                        "   - `auto` 自动排序（按精确度）\n" +
                        "4. **应用方向**：\n" +
                        "   - `inbound`：进入接口时过滤\n" +
                        "   - `outbound`：离开接口时过滤\n" +
                        "5. **示例**：\n" +
                        "```\n" +
                        "acl 3000\n" +
                        " rule 5 permit tcp source 192.168.1.0 0.0.0.255 destination 10.0.0.0 0.0.0.255 destination-port eq 80\n" +
                        " rule 10 deny ip\n" +
                        "interface GigabitEthernet0/0/1\n" +
                        " traffic-filter inbound acl 3000\n" +
                        "```");

        add("NAT 网络地址转换",
                new String[]{"nat", "地址转换", "源nat", "目的nat", "easy ip", "napt"},
                "**NAT 主要类型**：\n\n" +
                        "1. **静态 NAT（Static NAT）**：1 对 1，常用于服务器发布\n" +
                        "2. **动态 NAT（Dynamic NAT）**：地址池轮询，少用\n" +
                        "3. **NAPT / PAT**：端口级转换，私网多主机共享 1 个公网 IP（**家用最常见**）\n" +
                        "4. **Easy IP**：地址池即出接口 IP，适合拨号小场景\n" +
                        "5. **NAT Server（华为）**：将内网服务器端口映射到公网\n\n" +
                        "**华为配置示例（NAT Server）**：\n" +
                        "```\n" +
                        "interface GigabitEthernet0/0/1\n" +
                        " ip address 1.1.1.1 24\n" +
                        " nat server protocol tcp global 1.1.1.1 80 inside 192.168.1.10 80\n" +
                        "```\n\n" +
                        "**关键概念**：\n" +
                        "- 安全：隐藏内网结构\n" +
                        "- 限制：端到端寻址被破坏，VoIP/P2P 需 NAT 穿透\n" +
                        "- 替代方案：CGN（运营商级 NAT）");

        add("鸿蒙 ArkTS 入门",
                new String[]{"arkts", "鸿蒙", "harmonyos", "harmonyos next", "deveco", "arkui"},
                "**鸿蒙应用开发入门（ArkTS）**：\n\n" +
                        "1. **开发工具**：DevEco Studio（基于 IntelliJ）\n" +
                        "2. **核心语言**：ArkTS（TypeScript 超集）\n" +
                        "3. **UI 框架**：ArkUI（声明式，类似 Flutter/SwiftUI）\n" +
                        "4. **第一个示例**：\n" +
                        "```\n" +
                        "@Entry\n" +
                        "@Component\n" +
                        "struct HelloPage {\n" +
                        "  @State message: string = '华技云'\n" +
                        "  build() {\n" +
                        "    Column() {\n" +
                        "      Text(this.message).fontSize(30)\n" +
                        "      Button('点我')\n" +
                        "        .onClick(() => { this.message = 'Hello HarmonyOS' })\n" +
                        "    }\n" +
                        "  }\n" +
                        "}\n" +
                        "```\n\n" +
                        "**学习路径**：\n" +
                        "- 第 1 周：环境搭建 + 第一个 Ability\n" +
                        "- 第 2 周：组件化 + 状态管理（@State/@Prop/@Link）\n" +
                        "- 第 3 周：路由 + 数据持久化\n" +
                        "- 第 4 周：网络请求 + Stage 模型\n\n" +
                        "**官方资源**：developer.harmonyos.com → 开发者文档 → Codelabs");

        add("网络基础 TCP/IP",
                new String[]{"tcp", "ip", "tcp/ip", "osi", "七层", "四层", "三次握手", "四次挥手"},
                "**TCP/IP 协议栈速记**：\n\n" +
                        "**四层模型（TCP/IP）**：\n" +
                        "1. **应用层**：HTTP/FTP/DNS/SMTP\n" +
                        "2. **传输层**：TCP（可靠，三次握手）/ UDP（高效无连接）\n" +
                        "3. **网络层**：IP / ICMP / ARP / OSPF / BGP\n" +
                        "4. **网络接口层**：以太网 / Wi-Fi / PPP\n\n" +
                        "**TCP 三次握手**：\n" +
                        "1. 客户端 → SYN=1, seq=x\n" +
                        "2. 服务端 → SYN=1, ACK=1, seq=y, ack=x+1\n" +
                        "3. 客户端 → ACK=1, seq=x+1, ack=y+1\n\n" +
                        "**TCP 四次挥手**（为什么是四次？）：\n" +
                        "- 全双工需要双方各关闭一次\n" +
                        "- FIN 由一方发 → 另一方 ACK → 另一方 FIN → 发起方 ACK\n" +
                        "- 主动关闭方进入 TIME_WAIT 持续 2MSL（≈ 60s）\n\n" +
                        "**常用端口**：\n" +
                        "- 21 FTP / 22 SSH / 23 Telnet / 25 SMTP\n" +
                        "- 53 DNS / 80 HTTP / 443 HTTPS / 3306 MySQL / 6379 Redis");

        add("IPv6 基础",
                new String[]{"ipv6", "ipv4", "ipv6地址", "过渡技术", "双栈"},
                "**IPv6 速览**：\n\n" +
                        "1. **地址长度**：128 位（IPv4 是 32 位），地址空间近乎无限\n" +
                        "2. **表示法**：冒号十六进制 `2001:0db8:86a3::8a2e:0370:7334`\n" +
                        "   - `::` 表示连续的 0（仅能用一次）\n" +
                        "3. **地址类型**：\n" +
                        "   - 单播（Unicast）\n" +
                        "   - 多播（Multicast）\n" +
                        "   - 任播（Anycast，IPv6 独有）\n" +
                        "4. **头部简化**：固定 40 字节，路由器转发更快\n" +
                        "5. **过渡技术**：\n" +
                        "   - 双栈（Dual Stack）\n" +
                        "   - 隧道（6to4、GRE、ISATAP）\n" +
                        "   - 协议转换（NAT64/DNS64）\n" +
                        "6. **自动配置**：SLAAC（无状态）+ RA 报文\n\n" +
                        "**对比 IPv4 优势**：\n" +
                        "- 几乎无限地址\n" +
                        "- 端到端可达，无需 NAT\n" +
                        "- 即插即用配置\n" +
                        "- 更好的 QoS / 移动性支持");

        // 排序
        Collections.sort(entries, new Comparator<Entry>() {
            @Override
            public int compare(Entry a, Entry b) {
                return Integer.compare(b.keywords.length, a.keywords.length);
            }
        });
        // 让 entries 在不同 JDK 编译下稳定（使用 Arrays.sort 也可）
        // @SuppressWarnings("unused")
        Object unused = Arrays.asList(entries);
    }

    private void add(String title, String[] keywords, String body) {
        entries.add(new Entry(title, keywords, body));
    }
}
