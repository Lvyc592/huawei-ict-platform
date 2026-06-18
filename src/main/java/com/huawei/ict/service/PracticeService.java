package com.huawei.ict.service;

import com.huawei.ict.entity.Exam;
import com.huawei.ict.entity.Question;
import com.huawei.ict.entity.QuestionRecord;
import com.huawei.ict.repository.ExamRepository;
import com.huawei.ict.repository.QuestionRecordRepository;
import com.huawei.ict.repository.QuestionRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 题库练习服务：与模拟考试解耦，支持自由练习、即时反馈、不计入考试成绩。
 */
@Service
public class PracticeService {

    public static final String MODE = "PRACTICE";

    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final QuestionRecordRepository recordRepository;
    private final AiService aiService;

    public PracticeService(ExamRepository examRepository, QuestionRepository questionRepository,
                           QuestionRecordRepository recordRepository, AiService aiService) {
        this.examRepository = examRepository;
        this.questionRepository = questionRepository;
        this.recordRepository = recordRepository;
        this.aiService = aiService;
    }

    /**
     * 列出可用于练习的题库（复用 exams 表作为题库）。
     */
    public List<Exam> listPracticeExams(String category) {
        if (category != null && !category.isEmpty()) {
            return examRepository.findByCategory(category);
        }
        return examRepository.findAll(Sort.by(Sort.Direction.DESC, "id"));
    }

    /**
     * 获取指定题库下的全部题目。
     */
    public List<Question> getPracticeQuestions(Long examId) {
        return questionRepository.findByExamId(examId);
    }

    /**
     * 提交一道练习题的答案，返回是否正确、正确答案及（答错时）AI 解析。
     */
    @Transactional
    public Map<String, Object> submitPracticeAnswer(Long userId, Long questionId, String answer) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("题目不存在"));
        boolean isCorrect = question.getAnswer() != null && question.getAnswer().equalsIgnoreCase(answer);

        QuestionRecord record = new QuestionRecord();
        record.setUserId(userId);
        record.setQuestionId(questionId);
        record.setAnswer(answer);
        record.setIsCorrect(isCorrect);
        record.setMode(MODE);
        recordRepository.save(record);

        Map<String, Object> result = new HashMap<>();
        result.put("correct", isCorrect);
        result.put("correctAnswer", question.getAnswer());
        result.put("questionId", questionId);

        if (!isCorrect) {
            String explanation = aiService.explainWrongAnswer(
                    question.getContent(),
                    question.getOptions(),
                    question.getType(),
                    question.getAnswer(),
                    answer
            );
            result.put("explanation", explanation);
        }
        return result;
    }

    /**
     * 获取用户练习统计。
     */
    public Map<String, Object> getPracticeStats(Long userId) {
        long correct = recordRepository.countByUserIdAndIsCorrectAndMode(userId, true, MODE);
        long wrong = recordRepository.countByUserIdAndIsCorrectAndMode(userId, false, MODE);
        long total = correct + wrong;
        double accuracy = total > 0 ? (double) correct / total * 100 : 0;

        Map<String, Object> stats = new HashMap<>();
        stats.put("correct", correct);
        stats.put("wrong", wrong);
        stats.put("total", total);
        stats.put("accuracy", Math.round(accuracy * 100) / 100.0);
        return stats;
    }

    /**
     * 获取指定用户在指定题库下的练习进度。
     */
    public Map<String, Object> getPracticeProgress(Long userId, Long examId) {
        List<Question> questions = questionRepository.findByExamId(examId);
        List<QuestionRecord> records = recordRepository.findByUserIdAndMode(userId, MODE);
        long answered = records.stream()
                .filter(r -> questions.stream().anyMatch(q -> q.getId().equals(r.getQuestionId())))
                .count();
        long correct = records.stream()
                .filter(r -> r.getIsCorrect() != null && r.getIsCorrect())
                .filter(r -> questions.stream().anyMatch(q -> q.getId().equals(r.getQuestionId())))
                .count();

        Map<String, Object> progress = new HashMap<>();
        progress.put("total", questions.size());
        progress.put("answered", answered);
        progress.put("correct", correct);
        progress.put("progress", questions.isEmpty() ? 0 : Math.round((double) answered / questions.size() * 100));
        return progress;
    }
}
