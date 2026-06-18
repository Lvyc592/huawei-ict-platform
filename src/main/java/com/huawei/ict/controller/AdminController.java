package com.huawei.ict.controller;

import com.huawei.ict.dto.ApiResponse;
import com.huawei.ict.dto.DashboardStats;
import com.huawei.ict.entity.*;
import com.huawei.ict.service.*;
import com.huawei.ict.repository.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final DashboardService dashboardService;
    private final UserService userService;
    private final CourseService courseService;
    private final CertificationService certificationService;
    private final LabService labService;
    private final CompetitionService competitionService;
    private final JobService jobService;
    private final NotificationService notificationService;
    private final SystemSettingService settingService;
    private final ExamService examService;
    private final LearningRecordRepository learningRecordRepository;

    public AdminController(DashboardService dashboardService, UserService userService,
                           CourseService courseService, CertificationService certificationService,
                           LabService labService, CompetitionService competitionService,
                           JobService jobService, NotificationService notificationService,
                           SystemSettingService settingService,
                           ExamService examService,
                           LearningRecordRepository learningRecordRepository) {
        this.dashboardService = dashboardService;
        this.userService = userService;
        this.courseService = courseService;
        this.certificationService = certificationService;
        this.labService = labService;
        this.competitionService = competitionService;
        this.jobService = jobService;
        this.notificationService = notificationService;
        this.settingService = settingService;
        this.examService = examService;
        this.learningRecordRepository = learningRecordRepository;
    }

    @GetMapping("/dashboard")
    public ApiResponse<DashboardStats> dashboard() {
        return ApiResponse.ok(dashboardService.getAdminStats());
    }

    @GetMapping("/dashboard/full")
    public ApiResponse<Map<String, Object>> dashboardFull() {
        Map<String, Object> result = new HashMap<>();
        result.put("stats", dashboardService.getAdminStats());
        result.put("recentUsers", userService.listUsers(PageRequest.of(0, 5)));
        result.put("notifications", notificationService.listNotifications());
        return ApiResponse.ok(result);
    }

    @GetMapping("/users")
    public ApiResponse<?> users(@RequestParam(defaultValue = "0") int page,
                                @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.ok(userService.listUsers(PageRequest.of(page, size)));
    }

    @PostMapping("/users")
    public ApiResponse<User> createUser(@RequestBody User user) {
        return ApiResponse.ok("创建成功", userService.createUser(user));
    }

    @PutMapping("/users/{id}")
    public ApiResponse<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        return ApiResponse.ok(userService.updateUser(id, user));
    }

    @PutMapping("/users/{id}/status")
    public ApiResponse<?> updateUserStatus(@PathVariable Long id, @RequestParam User.UserStatus status) {
        userService.updateStatus(id, status);
        return ApiResponse.ok("更新成功", null);
    }

    @GetMapping("/courses")
    public ApiResponse<?> courses() { return ApiResponse.ok(courseService.listCourses()); }

    @PostMapping("/courses")
    public ApiResponse<Course> createCourse(@RequestBody Course course) {
        return ApiResponse.ok("创建成功", courseService.createCourse(course));
    }

    @GetMapping("/certifications")
    public ApiResponse<?> certifications() { return ApiResponse.ok(certificationService.listAll()); }

    @GetMapping("/labs")
    public ApiResponse<?> labs() { return ApiResponse.ok(labService.listLabs()); }

    @GetMapping("/competitions")
    public ApiResponse<?> competitions() { return ApiResponse.ok(competitionService.listCompetitions()); }

    @GetMapping("/jobs")
    public ApiResponse<?> jobs() { return ApiResponse.ok(jobService.listJobs()); }

    @GetMapping("/notifications")
    public ApiResponse<?> notifications() { return ApiResponse.ok(notificationService.listNotifications()); }

    @GetMapping("/settings")
    public ApiResponse<?> settings() { return ApiResponse.ok(settingService.getAllSettings()); }

    @PutMapping("/settings")
    public ApiResponse<?> updateSetting(@RequestParam String key, @RequestParam String value) {
        return ApiResponse.ok(settingService.updateSetting(key, value));
    }

    // ============== Exam Management ==============

    @GetMapping("/exams")
    public ApiResponse<?> exams(@RequestParam(required = false) String category) {
        if (category != null) return ApiResponse.ok(examService.listByCategory(category));
        return ApiResponse.ok(examService.listExams());
    }

    @PostMapping("/exams")
    public ApiResponse<Exam> createExam(@RequestBody Exam exam) {
        return ApiResponse.ok("创建成功", examService.createExam(exam));
    }

    @PutMapping("/exams/{id}")
    public ApiResponse<Exam> updateExam(@PathVariable Long id, @RequestBody Exam exam) {
        return ApiResponse.ok(examService.updateExam(id, exam));
    }

    @DeleteMapping("/exams/{id}")
    public ApiResponse<?> deleteExam(@PathVariable Long id) {
        examService.deleteExam(id);
        return ApiResponse.ok("删除成功", null);
    }

    @GetMapping("/exams/{id}/questions")
    public ApiResponse<?> examQuestions(@PathVariable Long id) {
        return ApiResponse.ok(examService.getQuestions(id));
    }

    @PostMapping("/exams/{id}/questions")
    public ApiResponse<Question> createQuestion(@PathVariable Long id, @RequestBody Question question) {
        question.setExamId(id);
        return ApiResponse.ok("创建成功", examService.createQuestion(question));
    }

    @PutMapping("/questions/{id}")
    public ApiResponse<Question> updateQuestion(@PathVariable Long id, @RequestBody Question question) {
        return ApiResponse.ok(examService.updateQuestion(id, question));
    }

    @DeleteMapping("/questions/{id}")
    public ApiResponse<?> deleteQuestion(@PathVariable Long id) {
        examService.deleteQuestion(id);
        return ApiResponse.ok("删除成功", null);
    }

    @GetMapping("/exams/{id}/stats")
    public ApiResponse<?> examStats(@PathVariable Long id) {
        return ApiResponse.ok(examService.getExamStats(id));
    }

    @GetMapping("/exams/results")
    public ApiResponse<?> allExamResults() {
        // Admin view all results - use a simple approach
        return ApiResponse.ok(examService.listExams());
    }
}
