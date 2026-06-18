package com.huawei.ict.service;

import com.huawei.ict.dto.DashboardStats;
import com.huawei.ict.dto.StudentStats;
import com.huawei.ict.dto.StudySuggestionDTO;
import com.huawei.ict.entity.*;
import com.huawei.ict.repository.*;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private final UserRepository userRepository;
    private final CourseRepository courseRepository;
    private final CertificationRepository certificationRepository;
    private final LabInstanceRepository labInstanceRepository;
    private final UserCourseRepository userCourseRepository;
    private final QuestionRecordRepository questionRecordRepository;
    private final LearningRecordRepository learningRecordRepository;
    private final KnowledgePointRepository knowledgePointRepository;
    private final AiService aiService;

    public DashboardService(UserRepository userRepository, CourseRepository courseRepository,
                            CertificationRepository certificationRepository,
                            LabInstanceRepository labInstanceRepository,
                            UserCourseRepository userCourseRepository,
                            QuestionRecordRepository questionRecordRepository,
                            LearningRecordRepository learningRecordRepository,
                            KnowledgePointRepository knowledgePointRepository,
                            AiService aiService) {
        this.userRepository = userRepository;
        this.courseRepository = courseRepository;
        this.certificationRepository = certificationRepository;
        this.labInstanceRepository = labInstanceRepository;
        this.userCourseRepository = userCourseRepository;
        this.questionRecordRepository = questionRecordRepository;
        this.learningRecordRepository = learningRecordRepository;
        this.knowledgePointRepository = knowledgePointRepository;
        this.aiService = aiService;
    }

    public DashboardStats getAdminStats() {
        DashboardStats stats = new DashboardStats();
        stats.setTotalStudents(userRepository.countByRole(User.Role.STUDENT));
        stats.setTotalCourses(courseRepository.count());
        stats.setTotalCertifications(certificationRepository.countByStatus(Certification.CertStatus.PASSED));
        stats.setTotalLabs(labInstanceRepository.count());
        stats.setOnlineUsers(256);
        stats.setTodayRegistrations(18);
        return stats;
    }

    public StudentStats getStudentStats(Long userId) {
        StudentStats stats = new StudentStats();
        stats.setFocusRate(86.0);
        stats.setAccuracy(72.0);

        long correct = questionRecordRepository.countByUserIdAndIsCorrect(userId, true);
        long total = questionRecordRepository.countByUserIdAndIsCorrect(userId, true)
                   + questionRecordRepository.countByUserIdAndIsCorrect(userId, false);
        if (total > 0) {
            stats.setAccuracy((double) correct / total * 100);
        }

        stats.setTotalHours(128);
        stats.setLevel("HCIA");

        long completed = userCourseRepository.countByUserIdAndStatus(userId, UserCourse.CourseStatus.COMPLETED);
        long enrolled = userCourseRepository.countByUserIdAndStatus(userId, UserCourse.CourseStatus.IN_PROGRESS);
        stats.setCompletedCourses((int) completed);
        stats.setTotalCourses((int) (completed + enrolled));
        stats.setClassRank(12);
        stats.setTotalClassmates(48);
        return stats;
    }

    // ============ 学习建议生成 ============

    /**
     * 为学员生成学习建议列表
     * 策略：
     *   1. 取该学员所有 knowledge_points，按 mastery_rate 升序
     *   2. mastery<40 标 HIGH，40-60 标 MEDIUM，>=60 标 LOW
     *   3. 通过 user_courses 找到该学员已报课程
     *   4. 关联课程 → 推荐 actionUrl
     */
    public List<StudySuggestionDTO> generateSuggestion(Long userId) {
        List<KnowledgePoint> kps = knowledgePointRepository.findByUserId(userId);
        if (kps == null || kps.isEmpty()) {
            return defaultSuggestions();
        }

        // 已报课程（用于关联）
        List<UserCourse> myUc = userCourseRepository.findByUserId(userId);
        Map<Long, Course> courseMap = new HashMap<>();
        for (UserCourse uc : myUc) {
            if (!courseMap.containsKey(uc.getCourseId())) {
                courseRepository.findById(uc.getCourseId())
                        .ifPresent(c -> courseMap.put(uc.getCourseId(), c));
            }
        }

        // 按掌握度升序
        List<KnowledgePoint> sorted = kps.stream()
                .sorted(Comparator.comparingDouble(k -> k.getMasteryRate() == null ? 0 : k.getMasteryRate()))
                .collect(Collectors.toList());

        List<StudySuggestionDTO> result = new ArrayList<>();
        for (KnowledgePoint kp : sorted) {
            if (result.size() >= 8) break; // 最多 8 条
            double rate = kp.getMasteryRate() == null ? 0 : kp.getMasteryRate();
            if (rate >= 80) continue; // 掌握度>=80 不需要建议

            StudySuggestionDTO dto = new StudySuggestionDTO();
            dto.setKpName(kp.getName());
            dto.setMasteryRate((int) rate);

            // 优先级
            String priority;
            if (rate < 40) priority = "HIGH";
            else if (rate < 60) priority = "MEDIUM";
            else priority = "LOW";
            dto.setPriority(priority);

            // 关联课程（用第一门已报课程）
            Course firstCourse = courseMap.values().stream().findFirst().orElse(null);
            String courseName = firstCourse != null ? firstCourse.getName() : "HCIA-Datacom 基础认证";
            String courseSlug = toSlug(firstCourse != null ? firstCourse.getCategory() : null);
            dto.setRelatedCourse(courseName);
            dto.setRelatedCourseSlug(courseSlug);

            // 标题 + 原因
            String title;
            String reason;
            if (rate < 40) {
                title = "建议加强 " + kp.getName() + " 相关知识点练习";
                reason = String.format("您当前掌握度仅 %d%%，低于及格线 60%%，建议优先巩固。", (int) rate);
                dto.setActionType("PRACTICE");
                dto.setActionUrl("exams.html");
                dto.setActionText("立即刷题");
            } else if (rate < 60) {
                title = "复习强化：" + kp.getName();
                reason = String.format("掌握度 %d%%，建议结合实验加深理解。", (int) rate);
                dto.setActionType("EXPERIMENT");
                dto.setActionUrl("cloud-lab.html");
                dto.setActionText("去做实验");
            } else {
                title = "查漏补缺：" + kp.getName();
                reason = String.format("掌握度 %d%%，已接近熟练，建议完成相关章节的复习题。", (int) rate);
                dto.setActionType("REVIEW");
                try {
                    String encoded = java.net.URLEncoder.encode(courseName, "UTF-8");
                    dto.setActionUrl("course-detail.html?id=" + courseSlug + "&name=" + encoded);
                } catch (java.io.UnsupportedEncodingException e) {
                    dto.setActionUrl("course-detail.html?id=" + courseSlug);
                }
                dto.setActionText("进入课程");
            }
            dto.setTitle(title);
            dto.setReason(reason);
            result.add(dto);
        }

        if (result.isEmpty()) {
            return defaultSuggestions();
        }
        return result;
    }

    /** 默认建议（学员无知识点数据时） */
    private List<StudySuggestionDTO> defaultSuggestions() {
        List<StudySuggestionDTO> list = new ArrayList<>();
        StudySuggestionDTO d1 = new StudySuggestionDTO();
        d1.setTitle("建议加强 ACL 和 NAT 相关知识点练习");
        d1.setReason("您在该知识点上的掌握度仅 35%，低于及格线 60%");
        d1.setKpName("ACL 访问控制列表");
        d1.setMasteryRate(35);
        d1.setPriority("HIGH");
        d1.setRelatedCourse("HCIA-Datacom 基础认证");
        d1.setRelatedCourseSlug("hcda-001");
        d1.setActionType("PRACTICE");
        d1.setActionUrl("exams.html");
        d1.setActionText("立即刷题");
        list.add(d1);

        StudySuggestionDTO d2 = new StudySuggestionDTO();
        d2.setTitle("复习强化：OSPF 邻居与区域");
        d2.setReason("掌握度 48%，建议结合实验加深理解");
        d2.setKpName("OSPF 邻居与区域");
        d2.setMasteryRate(48);
        d2.setPriority("MEDIUM");
        d2.setRelatedCourse("HCIA-Datacom 基础认证");
        d2.setRelatedCourseSlug("hcda-001");
        d2.setActionType("EXPERIMENT");
        d2.setActionUrl("cloud-lab.html");
        d2.setActionText("去做实验");
        list.add(d2);

        StudySuggestionDTO d3 = new StudySuggestionDTO();
        d3.setTitle("查漏补缺：VLAN 划分与配置");
        d3.setReason("掌握度 65%，已接近熟练，建议完成相关章节的复习题");
        d3.setKpName("VLAN 划分与配置");
        d3.setMasteryRate(65);
        d3.setPriority("LOW");
        d3.setRelatedCourse("HCIA-Datacom 基础认证");
        d3.setRelatedCourseSlug("hcda-001");
        d3.setActionType("REVIEW");
        d3.setActionUrl("course-detail.html?id=hcda-001&name=HCIA-Datacom%20基础认证");
        d3.setActionText("进入课程");
        list.add(d3);
        return list;
    }

    private String toSlug(String category) {
        if (category == null) return "hcda-001";
        String cat = category.toUpperCase();
        if (cat.startsWith("HCIA")) {
            if (cat.contains("DATACOM") || cat.equals("HCIA")) return "hcda-001";
            if (cat.contains("CLOUD"))   return "hccd-004";
            if (cat.contains("BIG"))     return "hbbd-005";
            if (cat.contains("AI"))      return "hcai-006";
        }
        if (cat.startsWith("HCIP")) return "hcdp-002";
        if (cat.startsWith("HCIE")) return "hcdx-003";
        return "hcda-001";
    }

    // ============ AI 学情分析报告 ============

    /**
     * 调用 AI 生成学员的学情分析报告
     * - 优先用 AiService（Ollama 优先，知识库兜底）
     * - 如果 AI 整体抛异常 → 用本地模板拼一份"降级报告"
     */
    public Map<String, Object> generateAnalyticsInsight(Long userId) {
        // 1. 收集学员数据
        StudentStats stats = getStudentStats(userId);
        List<KnowledgePoint> kps = knowledgePointRepository.findByUserId(userId);
        List<LearningRecord> recentRecords = learningRecordRepository
                .findByUserIdAndDateBetween(userId, LocalDate.now().minusDays(7), LocalDate.now());

        // 2. 弱项 Top 5
        List<Map<String, Object>> weak = new ArrayList<>();
        if (kps != null) {
            kps.stream()
               .filter(k -> k.getMasteryRate() != null && k.getMasteryRate() < 70)
               .sorted(Comparator.comparingDouble(KnowledgePoint::getMasteryRate))
               .limit(5)
               .forEach(k -> {
                   Map<String, Object> m = new HashMap<>();
                   m.put("name", k.getName());
                   m.put("mastery", (int) (k.getMasteryRate() == null ? 0 : k.getMasteryRate()));
                   weak.add(m);
               });
        }
        double avgMastery = kps == null || kps.isEmpty() ? 0
                : kps.stream().filter(k -> k.getMasteryRate() != null)
                        .mapToDouble(KnowledgePoint::getMasteryRate).average().orElse(0);
        long studyDays = recentRecords == null ? 0 : recentRecords.stream()
                .filter(r -> r.getDuration() != null && r.getDuration() > 0)
                .count();
        int totalMinutes = recentRecords == null ? 0 : recentRecords.stream()
                .filter(r -> r.getDuration() != null)
                .mapToInt(LearningRecord::getDuration).sum();

        // 3. 构造 prompt
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位资深的华为ICT学院学习教练，请基于以下学员数据输出【学情分析报告】：\n\n");
        prompt.append("【基础数据】\n");
        prompt.append("- 当前等级：").append(stats.getLevel()).append("\n");
        prompt.append("- 课堂专注度：").append(String.format("%.0f", stats.getFocusRate())).append("%\n");
        prompt.append("- 题库正确率：").append(String.format("%.1f", stats.getAccuracy())).append("%\n");
        prompt.append("- 累计学习时长：").append(stats.getTotalHours()).append(" 小时\n");
        prompt.append("- 已完成/在读课程：").append(stats.getCompletedCourses()).append("/").append(stats.getTotalCourses()).append("\n");
        prompt.append("- 班级排名：").append(stats.getClassRank()).append("/").append(stats.getTotalClassmates()).append("\n");
        prompt.append("- 平均知识点掌握度：").append(String.format("%.1f", avgMastery)).append("%\n");
        prompt.append("- 最近 7 天学习天数：").append(studyDays).append(" 天 / ").append(totalMinutes).append(" 分钟\n\n");
        prompt.append("【薄弱知识点 Top 5】\n");
        if (weak.isEmpty()) {
            prompt.append("（暂无明显薄弱点）\n");
        } else {
            for (int i = 0; i < weak.size(); i++) {
                Map<String, Object> w = weak.get(i);
                prompt.append(i + 1).append(". ").append(w.get("name")).append("（").append(w.get("mastery")).append("%）\n");
            }
        }
        prompt.append("\n【输出要求】\n");
        prompt.append("1) 用 4-6 段话给出诊断，每段不超过 120 字\n");
        prompt.append("2) 包含：综合表现、优势项、风险点、针对性训练建议、未来 7 天学习计划\n");
        prompt.append("3) 用第二人称「你」亲切口吻，多用 emoji 增加可读性\n");
        prompt.append("4) 不要说我是AI，直接给结论\n");
        prompt.append("5) 不要列表化，每段一段话自然过渡\n");

        // 4. 调 AI
        // 策略：知识库是固定模板答非所问，所以默认走本地"基于学员数据"的智能降级报告；
        //      只有 Ollama 在线时才走大模型（这样能产出真正的个性化分析）
        String aiText = null;
        String engine = "fallback";
        try {
            String activeEngine = aiService.currentEngine();
            if ("ollama".equals(activeEngine)) {
                aiText = aiService.chat(prompt.toString());
                engine = "ollama";
            } else {
                // knowledge 引擎：固定模板，无法基于学员数据 → 走本地降级
                engine = "fallback";
            }
        } catch (Exception e) {
            engine = "fallback";
        }
        if (aiText == null || aiText.trim().isEmpty()) {
            aiText = buildFallbackReport(stats, weak, avgMastery, studyDays, totalMinutes);
            engine = "fallback";
        }

        // 5. 拼返回
        Map<String, Object> out = new HashMap<>();
        out.put("report", aiText);
        out.put("engine", engine);
        out.put("stats", stats);
        out.put("weakPoints", weak);
        out.put("avgMastery", Math.round(avgMastery * 10) / 10.0);
        out.put("studyDays", studyDays);
        out.put("totalMinutes", totalMinutes);
        return out;
    }

    /** 模板降级报告（AI 不可用时） */
    private String buildFallbackReport(StudentStats stats,
                                       List<Map<String, Object>> weak,
                                       double avgMastery,
                                       long studyDays,
                                       int totalMinutes) {
        StringBuilder sb = new StringBuilder();
        sb.append("📊 **综合表现**：你当前处于 ").append(stats.getLevel()).append(" 阶段，")
          .append("课堂专注度 ").append(String.format("%.0f", stats.getFocusRate())).append("%，")
          .append("题库正确率 ").append(String.format("%.1f", stats.getAccuracy())).append("%，")
          .append("班级排名 ").append(stats.getClassRank()).append("/").append(stats.getTotalClassmates())
          .append("。整体节奏稳健，继续保持每天 1-2 小时的有效学习就能稳步进阶 🚀\n\n");
        sb.append("🌟 **优势项**：从累计 ").append(stats.getTotalHours()).append(" 小时学习时长和 ")
          .append(stats.getCompletedCourses()).append(" 门已完成的课程看，你的执行力很强。");
        if (avgMastery >= 70) {
            sb.append("平均掌握度 ").append(String.format("%.1f", avgMastery)).append("%，说明知识体系已经成型。\n\n");
        } else {
            sb.append("不过平均掌握度仅 ").append(String.format("%.1f", avgMastery)).append("%，知识体系还有补全空间。\n\n");
        }
        if (!weak.isEmpty()) {
            Map<String, Object> top = weak.get(0);
            sb.append("⚠️ **风险点**：你最薄弱的环节是 **").append(top.get("name"))
              .append("**（掌握度 ").append(top.get("mastery")).append("%），")
              .append("这是考试中分值占比很高的核心模块，")
              .append("如果不及时补齐，会影响后续路由交换综合实验题得分。\n\n");
        }
        sb.append("🎯 **针对性训练建议**：");
        if (!weak.isEmpty()) {
            List<String> names = new ArrayList<>();
            for (Map<String, Object> w : weak) names.add((String) w.get("name"));
            sb.append("接下来一周请集中刷 **").append(String.join("、", names))
              .append("** 相关题库（每日 15 道），错题归类后回看课程对应章节，")
              .append("并用华为云 eNSP/CloudLab 模拟器做 1 次综合实验巩固配置命令。\n\n");
        } else {
            sb.append("继续保持每天 15-20 道题 + 1 个实验的节奏，重点关注新知识点章节的预习。\n\n");
        }
        sb.append("📅 **未来 7 天学习计划**：");
        sb.append("Day 1-2 刷薄弱点题库 → Day 3 完成 1 次综合实验 → Day 4-5 复习错题 + 课程笔记 → ")
          .append("Day 6 做一套模拟卷（限时）→ Day 7 复盘错题并写下 3 条下周改进点 📝");
        if (studyDays < 4) {
            sb.append("\n\n⚡ 提醒：你最近 7 天仅 ").append(studyDays).append(" 天有学习记录，")
              .append("建议固定每天 20:00-21:30 为「ICT 学习时间」，养成习惯比突击更有效 ⏰");
        }
        return sb.toString();
    }
}
