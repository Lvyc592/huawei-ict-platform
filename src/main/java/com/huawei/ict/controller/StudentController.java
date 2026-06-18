package com.huawei.ict.controller;

import com.huawei.ict.dto.ApiResponse;
import com.huawei.ict.dto.MyCourseDTO;
import com.huawei.ict.dto.StudentStats;
import com.huawei.ict.dto.StudySuggestionDTO;
import com.huawei.ict.entity.*;
import com.huawei.ict.service.*;
import com.huawei.ict.repository.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private final DashboardService dashboardService;
    private final CourseService courseService;
    private final ExamService examService;
    private final PracticeService practiceService;
    private final LabService labService;
    private final CompetitionService competitionService;
    private final JobService jobService;
    private final CertificationService certificationService;
    private final NotificationRepository notificationRepository;
    private final LearningRecordRepository learningRecordRepository;
    private final KnowledgePointRepository knowledgePointRepository;
    private final QuestionRecordRepository questionRecordRepository;
    private final CourseRepository courseRepository;
    private final UserCourseRepository userCourseRepository;

    public StudentController(DashboardService dashboardService, CourseService courseService,
                             ExamService examService, PracticeService practiceService, LabService labService,
                             CompetitionService competitionService, JobService jobService,
                             CertificationService certificationService,
                             NotificationRepository notificationRepository,
                             LearningRecordRepository learningRecordRepository,
                             KnowledgePointRepository knowledgePointRepository,
                             QuestionRecordRepository questionRecordRepository,
                             CourseRepository courseRepository,
                             UserCourseRepository userCourseRepository) {
        this.dashboardService = dashboardService;
        this.courseService = courseService;
        this.examService = examService;
        this.practiceService = practiceService;
        this.labService = labService;
        this.competitionService = competitionService;
        this.jobService = jobService;
        this.certificationService = certificationService;
        this.notificationRepository = notificationRepository;
        this.learningRecordRepository = learningRecordRepository;
        this.knowledgePointRepository = knowledgePointRepository;
        this.questionRecordRepository = questionRecordRepository;
        this.courseRepository = courseRepository;
        this.userCourseRepository = userCourseRepository;
    }

    private Long getUserId(Authentication auth) {
        return (Long) auth.getPrincipal();
    }

    @GetMapping("/dashboard")
    public ApiResponse<StudentStats> dashboard(Authentication auth) {
        return ApiResponse.ok(dashboardService.getStudentStats(getUserId(auth)));
    }

    @GetMapping("/dashboard/full")
    public ApiResponse<Map<String, Object>> dashboardFull(Authentication auth) {
        Long uid = getUserId(auth);
        Map<String, Object> result = new HashMap<>();
        result.put("stats", dashboardService.getStudentStats(uid));

        // 我的课程：join Course 拿课程名/分类/简介/课时/学习人数
        List<UserCourse> myUc = userCourseRepository.findByUserId(uid);
        java.util.Map<Long, Course> courseMap = new java.util.HashMap<>();
        for (UserCourse uc : myUc) {
            if (!courseMap.containsKey(uc.getCourseId())) {
                courseRepository.findById(uc.getCourseId()).ifPresent(c -> courseMap.put(uc.getCourseId(), c));
            }
        }
        List<MyCourseDTO> myCourses = new java.util.ArrayList<>();
        for (UserCourse uc : myUc) {
            Course c = courseMap.get(uc.getCourseId());
            if (c == null) continue;
            MyCourseDTO dto = new MyCourseDTO();
            dto.setId(uc.getId());
            dto.setCourseId(c.getId());
            dto.setCourseName(c.getName());
            dto.setCategory(c.getCategory());
            dto.setDescription(c.getDescription());
            dto.setTotalChapters(c.getTotalChapters());
            dto.setTotalHours(c.getTotalHours());
            dto.setStudentCount(c.getStudentCount());
            dto.setProgress(uc.getProgress() == null ? 0 : uc.getProgress());
            dto.setStatus(uc.getStatus() == null ? "NOT_STARTED" : uc.getStatus().name());
            dto.setStatusText(toStatusText(dto.getStatus()));
            dto.setSlug(toSlug(c.getCategory(), c.getId()));
            myCourses.add(dto);
        }
        result.put("courses", myCourses);
        // 通知：只取学生端可见的（STUDENT + ALL），并按时间倒序
        result.put("notifications", notificationRepository.findByAudienceInOrderByIdDesc(
                java.util.Arrays.asList(Notification.AUDIENCE_STUDENT, Notification.AUDIENCE_ALL)));

        // 学习建议：基于薄弱知识点生成
        List<StudySuggestionDTO> suggestions = dashboardService.generateSuggestion(uid);
        result.put("studySuggestions", suggestions);
        // 摘要（首页卡片用）：取 HIGH 优先级的第一条作为"主要建议"
        if (suggestions != null && !suggestions.isEmpty()) {
            result.put("studySuggestionSummary", suggestions.get(0));
            result.put("weakCount", suggestions.size());
        } else {
            result.put("studySuggestionSummary", null);
            result.put("weakCount", 0);
        }
        return ApiResponse.ok(result);
    }

    @GetMapping("/study-suggestion")
    public ApiResponse<Map<String, Object>> studySuggestion(Authentication auth) {
        Long uid = getUserId(auth);
        Map<String, Object> result = new HashMap<>();
        List<StudySuggestionDTO> suggestions = dashboardService.generateSuggestion(uid);
        result.put("suggestions", suggestions);

        // 概览统计
        long total = knowledgePointRepository.findByUserId(uid).size();
        long weak = knowledgePointRepository.findByUserId(uid).stream()
                .filter(k -> k.getMasteryRate() != null && k.getMasteryRate() < 60)
                .count();
        double avg = knowledgePointRepository.findByUserId(uid).stream()
                .filter(k -> k.getMasteryRate() != null)
                .mapToDouble(KnowledgePoint::getMasteryRate)
                .average().orElse(0);
        Map<String, Object> overview = new HashMap<>();
        overview.put("total", total);
        overview.put("weak", weak);
        overview.put("avgMastery", Math.round(avg * 10) / 10.0);
        overview.put("highPriority", suggestions.stream().filter(s -> "HIGH".equals(s.getPriority())).count());
        overview.put("mediumPriority", suggestions.stream().filter(s -> "MEDIUM".equals(s.getPriority())).count());
        overview.put("lowPriority", suggestions.stream().filter(s -> "LOW".equals(s.getPriority())).count());
        result.put("overview", overview);
        return ApiResponse.ok(result);
    }

    @GetMapping("/analytics-insight")
    public ApiResponse<Map<String, Object>> analyticsInsight(Authentication auth) {
        Long uid = getUserId(auth);
        Map<String, Object> insight = dashboardService.generateAnalyticsInsight(uid);
        // 附学习建议列表
        insight.put("suggestions", dashboardService.generateSuggestion(uid));
        return ApiResponse.ok(insight);
    }

    private String toStatusText(String status) {
        if (status == null) return "未开始";
        switch (status) {
            case "IN_PROGRESS": return "进行中";
            case "COMPLETED":   return "已完成";
            default:            return "未开始";
        }
    }

    /** 课程分类 → course-detail.html 的 slug（与前端固定 6 个 SVG 卡片对应） */
    private String toSlug(String category, Long id) {
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

    @GetMapping("/courses")
    public ApiResponse<?> courses(@RequestParam(required = false) String category) {
        if (category != null) return ApiResponse.ok(courseService.listByCategory(category));
        return ApiResponse.ok(courseService.listCourses());
    }

    @PostMapping("/courses/enroll/{courseId}")
    public ApiResponse<?> enroll(Authentication auth, @PathVariable Long courseId) {
        return ApiResponse.ok("报名成功", courseService.enrollCourse(getUserId(auth), courseId));
    }

    @GetMapping("/courses/my")
    public ApiResponse<?> myCourses(Authentication auth) {
        return ApiResponse.ok(userCourseRepository.findByUserId(getUserId(auth)));
    }

    // ============== Exam System (Student) ==============

    @GetMapping("/exams")
    public ApiResponse<?> exams(@RequestParam(required = false) String category) {
        if (category != null) return ApiResponse.ok(examService.listByCategory(category));
        return ApiResponse.ok(examService.listExams());
    }

    @GetMapping("/exams/{id}")
    public ApiResponse<?> examDetail(@PathVariable Long id) {
        return ApiResponse.ok(examService.getExamById(id));
    }

    @GetMapping("/exams/{id}/questions")
    public ApiResponse<?> examQuestions(@PathVariable Long id) {
        return ApiResponse.ok(examService.getQuestions(id));
    }

    @PostMapping("/exams/{id}/start")
    public ApiResponse<?> startExam(Authentication auth, @PathVariable Long id) {
        try {
            ExamResult result = examService.startExam(id, getUserId(auth));
            return ApiResponse.ok("考试开始", result);
        } catch (RuntimeException e) {
            return ApiResponse.error(e.getMessage());
        }
    }

    @PostMapping("/exams/submit")
    public ApiResponse<?> submitExam(Authentication auth, @RequestBody Map<String, Object> body) {
        try {
            Long resultId = Long.valueOf(body.get("resultId").toString());
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> answers = (List<Map<String, Object>>) body.get("answers");
            ExamResult result = examService.submitExam(resultId, getUserId(auth), answers);
            return ApiResponse.ok("提交成功", result);
        } catch (RuntimeException e) {
            return ApiResponse.error(e.getMessage());
        }
    }

    @PostMapping("/answers/single")
    public ApiResponse<?> submitSingleAnswer(Authentication auth, @RequestBody Map<String, Object> body) {
        Long questionId = Long.valueOf(body.get("questionId").toString());
        String answer = (String) body.get("answer");
        boolean correct = examService.submitSingleAnswer(getUserId(auth), questionId, answer);
        return ApiResponse.ok(correct ? "回答正确" : "回答错误", Collections.singletonMap("correct", correct));
    }

    @PostMapping("/answers")
    public ApiResponse<?> submitAnswer(@RequestBody QuestionRecord record) {
        return ApiResponse.ok(examService.submitAnswer(record));
    }

    @GetMapping("/exam-results")
    public ApiResponse<?> examResults(Authentication auth) {
        return ApiResponse.ok(examService.getUserExamResults(getUserId(auth)));
    }

    @GetMapping("/exam-results/{id}")
    public ApiResponse<?> examResultDetail(Authentication auth, @PathVariable Long id) {
        // Return result with question details
        return ApiResponse.ok(examService.getUserExamResults(getUserId(auth)));
    }

    @GetMapping("/records/stats")
    public ApiResponse<Map<String, Object>> recordsStats(Authentication auth) {
        Long uid = getUserId(auth);
        Map<String, Object> stats = new HashMap<>();
        String mode = ExamService.MODE;
        long correct = questionRecordRepository.countByUserIdAndIsCorrectAndMode(uid, true, mode);
        long total = correct + questionRecordRepository.countByUserIdAndIsCorrectAndMode(uid, false, mode);
        stats.put("correct", correct);
        stats.put("total", total);
        stats.put("accuracy", total > 0 ? (double)correct/total*100 : 0);
        stats.put("examCount", examService.getUserExamResults(uid).size());
        stats.put("inProgress", examService.countInProgressExams(uid));
        return ApiResponse.ok(stats);
    }

    // ============== Question Bank Practice (Student) ==============

    @GetMapping("/practice/exams")
    public ApiResponse<?> practiceExams(@RequestParam(required = false) String category) {
        return ApiResponse.ok(practiceService.listPracticeExams(category));
    }

    @GetMapping("/practice/exams/{id}")
    public ApiResponse<?> practiceExamDetail(@PathVariable Long id) {
        return ApiResponse.ok(examService.getExamById(id));
    }

    @GetMapping("/practice/exams/{id}/questions")
    public ApiResponse<?> practiceQuestions(@PathVariable Long id) {
        return ApiResponse.ok(practiceService.getPracticeQuestions(id));
    }

    @GetMapping("/practice/exams/{id}/progress")
    public ApiResponse<?> practiceProgress(Authentication auth, @PathVariable Long id) {
        return ApiResponse.ok(practiceService.getPracticeProgress(getUserId(auth), id));
    }

    @PostMapping("/practice/answers")
    public ApiResponse<?> submitPracticeAnswer(Authentication auth, @RequestBody Map<String, Object> body) {
        try {
            Long questionId = Long.valueOf(body.get("questionId").toString());
            String answer = (String) body.get("answer");
            return ApiResponse.ok("提交成功", practiceService.submitPracticeAnswer(getUserId(auth), questionId, answer));
        } catch (RuntimeException e) {
            return ApiResponse.error(e.getMessage());
        }
    }

    @GetMapping("/practice/stats")
    public ApiResponse<?> practiceStats(Authentication auth) {
        return ApiResponse.ok(practiceService.getPracticeStats(getUserId(auth)));
    }

    // ============== Existing Endpoints ==============

    @GetMapping("/labs")
    public ApiResponse<?> labs() { return ApiResponse.ok(labService.listLabs()); }

    @PostMapping("/labs/start/{labId}")
    public ApiResponse<?> startLab(Authentication auth, @PathVariable Long labId) {
        return ApiResponse.ok(labService.startInstance(getUserId(auth), labId));
    }

    @GetMapping("/labs/my")
    public ApiResponse<?> myLabs(Authentication auth) {
        return ApiResponse.ok(labService.getUserInstances(getUserId(auth)));
    }

    @GetMapping("/competitions")
    public ApiResponse<?> competitions() { return ApiResponse.ok(competitionService.listCompetitions()); }

    @PostMapping("/competitions/register/{competitionId}")
    public ApiResponse<?> register(Authentication auth, @PathVariable Long competitionId) {
        try { return ApiResponse.ok("报名成功", competitionService.register(competitionId, getUserId(auth))); }
        catch (RuntimeException e) { return ApiResponse.error(e.getMessage()); }
    }

    @GetMapping("/jobs")
    public ApiResponse<?> jobs() { return ApiResponse.ok(jobService.listJobs()); }

    @PostMapping("/jobs/apply/{jobId}")
    public ApiResponse<?> apply(Authentication auth, @PathVariable Long jobId) {
        return ApiResponse.ok("投递成功", jobService.apply(jobId, getUserId(auth)));
    }

    @GetMapping("/certifications")
    public ApiResponse<?> certifications(Authentication auth) {
        return ApiResponse.ok(certificationService.getUserCertifications(getUserId(auth)));
    }

    @GetMapping("/notifications")
    public ApiResponse<?> notifications() {
        return ApiResponse.ok(notificationRepository.findByAudienceInOrderByIdDesc(
                java.util.Arrays.asList(Notification.AUDIENCE_STUDENT, Notification.AUDIENCE_ALL)));
    }

    @GetMapping("/learning-records")
    public ApiResponse<?> learningRecords(Authentication auth) {
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(7);
        return ApiResponse.ok(learningRecordRepository.findByUserIdAndDateBetween(getUserId(auth), start, end));
    }

    @GetMapping("/knowledge-points")
    public ApiResponse<?> knowledgePoints(Authentication auth) {
        return ApiResponse.ok(knowledgePointRepository.findByUserId(getUserId(auth)));
    }
}
