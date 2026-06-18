package com.huawei.ict.service;

import com.huawei.ict.entity.Course;
import com.huawei.ict.entity.CourseChapter;
import com.huawei.ict.entity.UserCourse;
import com.huawei.ict.repository.CourseChapterRepository;
import com.huawei.ict.repository.CourseRepository;
import com.huawei.ict.repository.UserCourseRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CourseService {

    private final CourseRepository courseRepository;
    private final CourseChapterRepository chapterRepository;
    private final UserCourseRepository userCourseRepository;

    public CourseService(CourseRepository courseRepository, CourseChapterRepository chapterRepository,
                         UserCourseRepository userCourseRepository) {
        this.courseRepository = courseRepository;
        this.chapterRepository = chapterRepository;
        this.userCourseRepository = userCourseRepository;
    }

    public List<Course> listCourses() {
        return courseRepository.findAll();
    }

    public List<Course> listByCategory(String category) {
        return courseRepository.findByCategory(category);
    }

    public Course getCourseById(Long id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("课程不存在"));
    }

    public Course createCourse(Course course) {
        return courseRepository.save(course);
    }

    public Course updateCourse(Long id, Course updated) {
        Course course = getCourseById(id);
        if (updated.getName() != null) course.setName(updated.getName());
        if (updated.getDescription() != null) course.setDescription(updated.getDescription());
        if (updated.getCategory() != null) course.setCategory(updated.getCategory());
        if (updated.getTotalChapters() != null) course.setTotalChapters(updated.getTotalChapters());
        if (updated.getTotalHours() != null) course.setTotalHours(updated.getTotalHours());
        if (updated.getStatus() != null) course.setStatus(updated.getStatus());
        return courseRepository.save(course);
    }

    public List<CourseChapter> getChapters(Long courseId) {
        return chapterRepository.findByCourseIdOrderBySortOrder(courseId);
    }

    public List<UserCourse> getUserCourses(Long userId) {
        return userCourseRepository.findByUserId(userId);
    }

    public UserCourse enrollCourse(Long userId, Long courseId) {
        UserCourse uc = new UserCourse();
        uc.setUserId(userId);
        uc.setCourseId(courseId);
        uc.setProgress(0);
        uc.setStatus(UserCourse.CourseStatus.IN_PROGRESS);
        return userCourseRepository.save(uc);
    }
}
