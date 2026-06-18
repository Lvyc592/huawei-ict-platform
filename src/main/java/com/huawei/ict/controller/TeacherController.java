package com.huawei.ict.controller;

import com.huawei.ict.dto.ApiResponse;
import com.huawei.ict.entity.*;
import com.huawei.ict.repository.*;
import com.huawei.ict.service.ExamService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 教师端 API
 * - 路由：/api/teacher/**
 * - 鉴权：hasAuthority("TEACHER")（SecurityConfig 中已配置）
 *
 * 核心设计：
 *   1. 教师 id = Authentication.principal
 *   2. 教师能看到的数据 = 自己 teacher_id 下的课程 + 这些课的学生 + 这些学生的学情
 *   3. 不暴露管理端的全局数据（用户管理、设置）
 */
@RestController
@RequestMapping("/api/teacher")
public class TeacherController {

    private final UserRepository userRepository;
    private final CourseRepository courseRepository;
    private final UserCourseRepository userCourseRepository;
    private final LearningRecordRepository learningRecordRepository;
    private final KnowledgePointRepository knowledgePointRepository;
    private final QuestionRecordRepository questionRecordRepository;
    private final NotificationRepository notificationRepository;
    private final ExamRepository examRepository;

    private final ExamResultRepository examResultRepository;
    private final ExamService examService;

    public TeacherController(UserRepository userRepository,
                             CourseRepository courseRepository,
                             UserCourseRepository userCourseRepository,
                             LearningRecordRepository learningRecordRepository,
                             KnowledgePointRepository knowledgePointRepository,
                             QuestionRecordRepository questionRecordRepository,
                             NotificationRepository notificationRepository,
                             ExamRepository examRepository,
                             ExamResultRepository examResultRepository,
                             ExamService examService) {
        this.userRepository = userRepository;
        this.courseRepository = courseRepository;
        this.userCourseRepository = userCourseRepository;
        this.learningRecordRepository = learningRecordRepository;
        this.knowledgePointRepository = knowledgePointRepository;
        this.questionRecordRepository = questionRecordRepository;
        this.notificationRepository = notificationRepository;
        this.examRepository = examRepository;
        this.examResultRepository = examResultRepository;
        this.examService = examService;
    }

    private Long getTeacherId(Authentication auth) {
        return (Long) auth.getPrincipal();
    }

    // ============== 教师概览 ==============

    /** 教师仪表盘 - 4 个核心数字 + 所教课程数 + 学员数 + 班级整体学情 */
    @GetMapping("/dashboard")
    public ApiResponse<Map<String, Object>> dashboard(Authentication auth) {
        Long tid = getTeacherId(auth);
        return ApiResponse.ok(buildOverview(tid));
    }

    @GetMapping("/dashboard/full")
    public ApiResponse<Map<String, Object>> dashboardFull(Authentication auth) {
        Long tid = getTeacherId(auth);
        Map<String, Object> result = buildOverview(tid);
        result.put("myCourses", courseRepository.findByTeacherId(tid));
        // 平台通知（ALL + TEACHER 受众）—— 当前还没建 TEACHER 受众，沿用 ALL
        result.put("notifications", notificationRepository.findByAudienceInOrderByIdDesc(
                java.util.Arrays.asList(Notification.AUDIENCE_ALL)));
        return ApiResponse.ok(result);
    }

    private Map<String, Object> buildOverview(Long teacherId) {
        Map<String, Object> out = new HashMap<>();

        // 1) 我教的课程
        List<Course> myCourses = courseRepository.findByTeacherId(teacherId);
        List<Long> courseIds = myCourses.stream().map(Course::getId).collect(Collectors.toList());

        // 2) 我的学员（所有报名我课程的学生，按 user_id 去重）
        Set<Long> studentIdSet = new HashSet<>();
        if (!courseIds.isEmpty()) {
            List<UserCourse> ucs = userCourseRepository.findByCourseIdIn(courseIds);
            for (UserCourse uc : ucs) studentIdSet.add(uc.getUserId());
        }
        List<Long> studentIds = new ArrayList<>(studentIdSet);

        // 3) 学员平均掌握度（最近 7 天）
        double avgMastery = 0;
        if (!studentIds.isEmpty()) {
            List<KnowledgePoint> kps = knowledgePointRepository.findByUserIdIn(studentIds);
            avgMastery = kps == null || kps.isEmpty() ? 0 :
                    kps.stream().filter(k -> k.getMasteryRate() != null)
                            .mapToDouble(KnowledgePoint::getMasteryRate).average().orElse(0);
        }

        // 4) 学员最近 7 天活跃度
        int activeStudents = 0;
        int totalMinutes = 0;
        if (!studentIds.isEmpty()) {
            List<LearningRecord> recent = learningRecordRepository
                    .findByUserIdInAndDateBetween(studentIds, LocalDate.now().minusDays(7), LocalDate.now());
            Set<Long> activeSet = new HashSet<>();
            for (LearningRecord r : recent) {
                if (r.getDuration() != null) {
                    totalMinutes += r.getDuration();
                    if (r.getDuration() > 0) activeSet.add(r.getUserId());
                }
            }
            activeStudents = activeSet.size();
        }

        // 5) 在读 / 已完成课程数
        long inProgress = 0, completed = 0;
        if (!courseIds.isEmpty()) {
            for (Long cid : courseIds) {
                inProgress += userCourseRepository.findByCourseId(cid).stream()
                        .filter(uc -> uc.getStatus() == UserCourse.CourseStatus.IN_PROGRESS).count();
                completed += userCourseRepository.findByCourseId(cid).stream()
                        .filter(uc -> uc.getStatus() == UserCourse.CourseStatus.COMPLETED).count();
            }
        }

        out.put("totalCourses", myCourses.size());
        out.put("totalStudents", studentIds.size());
        out.put("activeStudents", activeStudents);
        out.put("avgMastery", Math.round(avgMastery * 10) / 10.0);
        out.put("inProgressEnroll", inProgress);
        out.put("completedEnroll", completed);
        out.put("weeklyMinutes", totalMinutes);
        out.put("teacherId", teacherId);
        return out;
    }

    // ============== 我的课程 ==============

    @GetMapping("/my-courses")
    public ApiResponse<List<Course>> myCourses(Authentication auth) {
        return ApiResponse.ok(courseRepository.findByTeacherId(getTeacherId(auth)));
    }

    /** 某门课的学员列表（含学习进度） */
    @GetMapping("/courses/{courseId}/students")
    public ApiResponse<List<Map<String, Object>>> courseStudents(Authentication auth, @PathVariable Long courseId) {
        Long tid = getTeacherId(auth);
        // 校验：这门课是不是这位老师教的
        Course c = courseRepository.findById(courseId).orElse(null);
        if (c == null || c.getTeacherId() == null || !c.getTeacherId().equals(tid)) {
            return ApiResponse.error("无权访问此课程");
        }
        List<UserCourse> ucs = userCourseRepository.findByCourseId(courseId);
        Map<Long, User> userMap = new HashMap<>();
        for (UserCourse uc : ucs) {
            if (!userMap.containsKey(uc.getUserId())) {
                userRepository.findById(uc.getUserId()).ifPresent(u -> userMap.put(uc.getUserId(), u));
            }
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (UserCourse uc : ucs) {
            User u = userMap.get(uc.getUserId());
            if (u == null) continue;
            Map<String, Object> m = new HashMap<>();
            m.put("userId", u.getId());
            m.put("username", u.getUsername());
            m.put("name", u.getName());
            m.put("studentId", u.getStudentId());
            m.put("progress", uc.getProgress() == null ? 0 : uc.getProgress());
            m.put("status", uc.getStatus() == null ? "NOT_STARTED" : uc.getStatus().name());
            m.put("statusText", toStatusText(uc.getStatus()));
            m.put("enrolledAt", uc.getCreatedAt() == null ? null : uc.getCreatedAt().toString());
            result.add(m);
        }
        return ApiResponse.ok(result);
    }

    /** 该教师所有学员的学情快照（用于"学员管理"页） */
    @GetMapping("/my-students")
    public ApiResponse<List<Map<String, Object>>> myStudents(Authentication auth) {
        Long tid = getTeacherId(auth);
        List<Course> myCourses = courseRepository.findByTeacherId(tid);
        List<Long> courseIds = myCourses.stream().map(Course::getId).collect(Collectors.toList());
        if (courseIds.isEmpty()) return ApiResponse.ok(new ArrayList<>());

        // 收集所有 (学生, 课程) 关联 + 计算每学生均掌握度
        Set<Long> studentIdSet = new LinkedHashSet<>();
        Map<Long, List<UserCourse>> ucByUser = new HashMap<>();
        for (UserCourse uc : userCourseRepository.findByCourseIdIn(courseIds)) {
            studentIdSet.add(uc.getUserId());
            ucByUser.computeIfAbsent(uc.getUserId(), k -> new ArrayList<>()).add(uc);
        }
        List<Long> studentIds = new ArrayList<>(studentIdSet);

        Map<Long, Double> avgByUser = new HashMap<>();
        if (!studentIds.isEmpty()) {
            for (KnowledgePoint kp : knowledgePointRepository.findByUserIdIn(studentIds)) {
                avgByUser.merge(kp.getUserId(), kp.getMasteryRate() == null ? 0.0 : kp.getMasteryRate(),
                        (a, b) -> (a + b) / 2);
            }
        }
        // 最近 7 天是否有学习记录
        Map<Long, Boolean> active7dByUser = new HashMap<>();
        if (!studentIds.isEmpty()) {
            for (LearningRecord r : learningRecordRepository
                    .findByUserIdInAndDateBetween(studentIds, LocalDate.now().minusDays(7), LocalDate.now())) {
                if (r.getDuration() != null && r.getDuration() > 0) {
                    active7dByUser.put(r.getUserId(), Boolean.TRUE);
                }
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Long uid : studentIds) {
            User u = userRepository.findById(uid).orElse(null);
            if (u == null) continue;
            List<UserCourse> list = ucByUser.getOrDefault(uid, new ArrayList<>());
            double avgProgress = list.stream().mapToInt(uc -> uc.getProgress() == null ? 0 : uc.getProgress()).average().orElse(0);
            Map<String, Object> m = new HashMap<>();
            m.put("userId", u.getId());
            m.put("username", u.getUsername());
            m.put("name", u.getName());
            m.put("studentId", u.getStudentId());
            m.put("courseCount", list.size());
            m.put("avgProgress", Math.round(avgProgress));
            m.put("mastery", Math.round(avgByUser.getOrDefault(uid, 0.0)));
            m.put("active7d", active7dByUser.containsKey(uid));
            m.put("courses", list.stream().map(uc -> {
                Map<String, Object> c = new HashMap<>();
                c.put("courseId", uc.getCourseId());
                Course course = courseRepository.findById(uc.getCourseId()).orElse(null);
                c.put("courseName", course == null ? "" : course.getName());
                c.put("progress", uc.getProgress() == null ? 0 : uc.getProgress());
                c.put("status", uc.getStatus() == null ? "NOT_STARTED" : uc.getStatus().name());
                return c;
            }).collect(Collectors.toList()));
            result.add(m);
        }
        // 排序：先按最近活跃，再按平均进度倒序
        result.sort((a, b) -> {
            if (Boolean.TRUE.equals(a.get("active7d")) != Boolean.TRUE.equals(b.get("active7d"))) {
                return Boolean.TRUE.equals(a.get("active7d")) ? -1 : 1;
            }
            return ((Number) b.get("avgProgress")).intValue() - ((Number) a.get("avgProgress")).intValue();
        });
        return ApiResponse.ok(result);
    }

    // ============== 学情分析（教师视角的班级整体） ==============

    @GetMapping("/analytics")
    public ApiResponse<Map<String, Object>> analytics(Authentication auth) {
        Long tid = getTeacherId(auth);
        List<Course> myCourses = courseRepository.findByTeacherId(tid);
        List<Long> courseIds = myCourses.stream().map(Course::getId).collect(Collectors.toList());

        Map<String, Object> out = new HashMap<>();
        out.put("myCourses", myCourses);

        if (courseIds.isEmpty()) {
            out.put("studentCount", 0);
            out.put("avgMastery", 0);
            out.put("weakPoints", new ArrayList<>());
            out.put("courseDistribution", new ArrayList<>());
            out.put("progressDistribution", new ArrayList<>());
            return ApiResponse.ok(out);
        }

        // 学员
        Set<Long> studentIdSet = new HashSet<>();
        for (UserCourse uc : userCourseRepository.findByCourseIdIn(courseIds)) studentIdSet.add(uc.getUserId());
        List<Long> studentIds = new ArrayList<>(studentIdSet);
        out.put("studentCount", studentIds.size());

        // 学员平均掌握度
        List<KnowledgePoint> kps = studentIds.isEmpty() ? new ArrayList<>() : knowledgePointRepository.findByUserIdIn(studentIds);
        double avg = kps.stream().filter(k -> k.getMasteryRate() != null)
                .mapToDouble(KnowledgePoint::getMasteryRate).average().orElse(0);
        out.put("avgMastery", Math.round(avg * 10) / 10.0);

        // 班级薄弱知识点 Top 10（按所有学员 knowledge_points 聚合）
        Map<String, double[]> agg = new HashMap<>();  // name → [sum, count]
        for (KnowledgePoint kp : kps) {
            double r = kp.getMasteryRate() == null ? 0 : kp.getMasteryRate();
            agg.computeIfAbsent(kp.getName(), k -> new double[2]);
            agg.get(kp.getName())[0] += r;
            agg.get(kp.getName())[1] += 1;
        }
        List<Map<String, Object>> weak = new ArrayList<>();
        for (Map.Entry<String, double[]> e : agg.entrySet()) {
            double sum = e.getValue()[0];
            double cnt = e.getValue()[1];
            if (cnt == 0) continue;
            double mean = sum / cnt;
            if (mean >= 70) continue;  // 只显示掌握度 < 70 的
            Map<String, Object> w = new HashMap<>();
            w.put("name", e.getKey());
            w.put("mastery", Math.round(mean));
            w.put("studentCount", (int) cnt);
            weak.add(w);
        }
        weak.sort((a, b) -> ((Number) a.get("mastery")).intValue() - ((Number) b.get("mastery")).intValue());
        if (weak.size() > 10) weak = weak.subList(0, 10);
        out.put("weakPoints", weak);

        // 每门课的报名情况
        List<Map<String, Object>> courseDist = new ArrayList<>();
        for (Course c : myCourses) {
            List<UserCourse> ucs = userCourseRepository.findByCourseId(c.getId());
            long ip = ucs.stream().filter(u -> u.getStatus() == UserCourse.CourseStatus.IN_PROGRESS).count();
            long co = ucs.stream().filter(u -> u.getStatus() == UserCourse.CourseStatus.COMPLETED).count();
            long nb = ucs.stream().filter(u -> u.getStatus() == UserCourse.CourseStatus.NOT_STARTED).count();
            Map<String, Object> cd = new HashMap<>();
            cd.put("courseId", c.getId());
            cd.put("courseName", c.getName());
            cd.put("category", c.getCategory());
            cd.put("total", ucs.size());
            cd.put("inProgress", ip);
            cd.put("completed", co);
            cd.put("notStarted", nb);
            courseDist.add(cd);
        }
        out.put("courseDistribution", courseDist);

        // 学员进度分布（按 user_id × 课程进度，0-25 / 26-50 / 51-75 / 76-100）
        int[] buckets = new int[4];
        if (!studentIds.isEmpty()) {
            for (UserCourse uc : userCourseRepository.findByCourseIdIn(courseIds)) {
                int p = uc.getProgress() == null ? 0 : uc.getProgress();
                if (p <= 25) buckets[0]++;
                else if (p <= 50) buckets[1]++;
                else if (p <= 75) buckets[2]++;
                else buckets[3]++;
            }
        }
        List<Map<String, Object>> progDist = new ArrayList<>();
        String[] labels = {"0-25%", "26-50%", "51-75%", "76-100%"};
        for (int i = 0; i < 4; i++) {
            Map<String, Object> b = new HashMap<>();
            b.put("label", labels[i]);
            b.put("count", buckets[i]);
            progDist.add(b);
        }
        out.put("progressDistribution", progDist);

        return ApiResponse.ok(out);
    }

    // ============== 考试记录（教师视角） ==============

    /**
     * 获取教师所教学员的模拟考试记录。
     * 支持按考试 ID、学生 ID、状态筛选；返回与学生端模拟考试同步的数据。
     */
    @GetMapping("/exam-records")
    public ApiResponse<List<Map<String, Object>>> examRecords(Authentication auth,
                                                               @RequestParam(required = false) Long examId,
                                                               @RequestParam(required = false) Long studentId,
                                                               @RequestParam(required = false) String status) {
        Long tid = getTeacherId(auth);
        List<Long> courseIds = courseRepository.findByTeacherId(tid).stream()
                .map(Course::getId).collect(Collectors.toList());
        if (courseIds.isEmpty()) return ApiResponse.ok(new ArrayList<>());

        Set<Long> studentIdSet = new LinkedHashSet<>();
        for (UserCourse uc : userCourseRepository.findByCourseIdIn(courseIds)) {
            studentIdSet.add(uc.getUserId());
        }
        if (studentIdSet.isEmpty()) return ApiResponse.ok(new ArrayList<>());

        // 如前端指定了 studentId，校验该学生是否属于当前教师
        List<Long> studentIds = new ArrayList<>(studentIdSet);
        if (studentId != null && !studentIdSet.contains(studentId)) {
            return ApiResponse.error("无权查看该学生记录");
        }
        if (studentId != null) studentIds = Collections.singletonList(studentId);

        List<ExamResult> results = examResultRepository.findByUserIdIn(studentIds);
        if (examId != null) {
            results = results.stream().filter(r -> examId.equals(r.getExamId())).collect(Collectors.toList());
        }
        if (status != null && !status.trim().isEmpty()) {
            results = results.stream().filter(r -> status.equals(r.getStatus().name())).collect(Collectors.toList());
        }
        results.sort((a, b) -> {
            LocalDateTime t1 = a.getCompletedAt() != null ? a.getCompletedAt() : a.getStartedAt();
            LocalDateTime t2 = b.getCompletedAt() != null ? b.getCompletedAt() : b.getStartedAt();
            if (t1 == null || t2 == null) return 0;
            return t2.compareTo(t1); // 倒序：最新在前
        });

        Map<Long, User> userMap = new HashMap<>();
        Map<Long, Exam> examMap = new HashMap<>();
        for (ExamResult r : results) {
            userMap.computeIfAbsent(r.getUserId(), id -> userRepository.findById(id).orElse(null));
            examMap.computeIfAbsent(r.getExamId(), id -> examRepository.findById(id).orElse(null));
        }

        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        List<Map<String, Object>> out = new ArrayList<>();
        for (ExamResult r : results) {
            User u = userMap.get(r.getUserId());
            Exam e = examMap.get(r.getExamId());
            Map<String, Object> m = new HashMap<>();
            m.put("resultId", r.getId());
            m.put("examId", r.getExamId());
            m.put("examTitle", e == null ? "未知考试" : e.getTitle());
            m.put("examCategory", e == null ? "" : e.getCategory());
            m.put("userId", r.getUserId());
            m.put("username", u == null ? "" : u.getUsername());
            m.put("name", u == null ? "" : u.getName());
            m.put("studentId", u == null ? "" : u.getStudentId());
            m.put("score", r.getScore());
            m.put("totalScore", r.getTotalScore());
            m.put("correctCount", r.getCorrectCount());
            m.put("questionCount", r.getQuestionCount());
            m.put("status", r.getStatus() == null ? "" : r.getStatus().name());
            m.put("statusText", r.getStatus() == ExamResult.ResultStatus.COMPLETED ? "已完成" : "进行中");
            m.put("startedAt", r.getStartedAt() == null ? "" : r.getStartedAt().format(df));
            m.put("completedAt", r.getCompletedAt() == null ? "" : r.getCompletedAt().format(df));
            m.put("passScore", e == null ? 0 : (e.getPassScore() == null ? 0 : e.getPassScore()));
            m.put("passed", e != null && e.getPassScore() != null && r.getScore() != null && r.getScore() >= e.getPassScore());
            out.add(m);
        }
        return ApiResponse.ok(out);
    }

    /**
     * 获取某条模拟考试记录的详情，含每道题的答题明细。
     * 校验该记录所属学生必须属于当前教师。
     */
    @GetMapping("/exam-records/{resultId}")
    public ApiResponse<Map<String, Object>> examRecordDetail(Authentication auth, @PathVariable Long resultId) {
        Long tid = getTeacherId(auth);
        ExamResult result = examResultRepository.findById(resultId).orElse(null);
        if (result == null) return ApiResponse.error("考试记录不存在");

        List<Long> courseIds = courseRepository.findByTeacherId(tid).stream()
                .map(Course::getId).collect(Collectors.toList());
        Set<Long> studentIdSet = new HashSet<>();
        if (!courseIds.isEmpty()) {
            for (UserCourse uc : userCourseRepository.findByCourseIdIn(courseIds)) studentIdSet.add(uc.getUserId());
        }
        if (!studentIdSet.contains(result.getUserId())) {
            return ApiResponse.error("无权查看该考试记录");
        }

        User u = userRepository.findById(result.getUserId()).orElse(null);
        Exam e = examRepository.findById(result.getExamId()).orElse(null);
        List<Question> questions = examService.getQuestions(result.getExamId());
        List<QuestionRecord> records = questionRecordRepository.findByUserIdAndMode(result.getUserId(), ExamService.MODE);
        Map<Long, QuestionRecord> recordMap = new HashMap<>();
        for (QuestionRecord rec : records) {
            if (rec.getCreatedAt() != null && result.getStartedAt() != null
                    && !rec.getCreatedAt().isBefore(result.getStartedAt())) {
                recordMap.put(rec.getQuestionId(), rec);
            }
        }

        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        Map<String, Object> out = new HashMap<>();
        out.put("resultId", result.getId());
        out.put("examId", result.getExamId());
        out.put("examTitle", e == null ? "未知考试" : e.getTitle());
        out.put("examCategory", e == null ? "" : e.getCategory());
        out.put("duration", e == null ? 60 : (e.getDuration() == null ? 60 : e.getDuration()));
        out.put("passScore", e == null ? 0 : (e.getPassScore() == null ? 0 : e.getPassScore()));
        out.put("userId", result.getUserId());
        out.put("username", u == null ? "" : u.getUsername());
        out.put("name", u == null ? "" : u.getName());
        out.put("studentId", u == null ? "" : u.getStudentId());
        out.put("score", result.getScore());
        out.put("totalScore", result.getTotalScore());
        out.put("correctCount", result.getCorrectCount());
        out.put("questionCount", result.getQuestionCount());
        out.put("status", result.getStatus() == null ? "" : result.getStatus().name());
        out.put("statusText", result.getStatus() == ExamResult.ResultStatus.COMPLETED ? "已完成" : "进行中");
        out.put("startedAt", result.getStartedAt() == null ? "" : result.getStartedAt().format(df));
        out.put("completedAt", result.getCompletedAt() == null ? "" : result.getCompletedAt().format(df));
        out.put("passed", e != null && e.getPassScore() != null && result.getScore() != null && result.getScore() >= e.getPassScore());

        List<Map<String, Object>> items = new ArrayList<>();
        int idx = 1;
        for (Question q : questions) {
            QuestionRecord rec = recordMap.get(q.getId());
            Map<String, Object> item = new HashMap<>();
            item.put("index", idx++);
            item.put("questionId", q.getId());
            item.put("content", q.getContent());
            item.put("type", q.getType());
            item.put("options", q.getOptions());
            item.put("correctAnswer", q.getAnswer());
            item.put("studentAnswer", rec == null ? "" : rec.getAnswer());
            item.put("isCorrect", rec == null ? null : rec.getIsCorrect());
            item.put("answered", rec != null);
            items.add(item);
        }
        out.put("questions", items);
        return ApiResponse.ok(out);
    }

    // ============== 工具 ==============

    private String toStatusText(UserCourse.CourseStatus status) {
        if (status == null) return "未开始";
        switch (status) {
            case IN_PROGRESS: return "进行中";
            case COMPLETED:   return "已完成";
            default:          return "未开始";
        }
    }
}
