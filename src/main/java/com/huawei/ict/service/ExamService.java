package com.huawei.ict.service;

import com.huawei.ict.entity.Exam;
import com.huawei.ict.entity.ExamResult;
import com.huawei.ict.entity.Question;
import com.huawei.ict.entity.QuestionRecord;
import com.huawei.ict.repository.ExamResultRepository;
import com.huawei.ict.repository.ExamRepository;
import com.huawei.ict.repository.QuestionRecordRepository;
import com.huawei.ict.repository.QuestionRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class ExamService {

    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final QuestionRecordRepository recordRepository;
    private final ExamResultRepository examResultRepository;

    public ExamService(ExamRepository examRepository, QuestionRepository questionRepository,
                       QuestionRecordRepository recordRepository,
                       ExamResultRepository examResultRepository) {
        this.examRepository = examRepository;
        this.questionRepository = questionRepository;
        this.recordRepository = recordRepository;
        this.examResultRepository = examResultRepository;
    }

    public static final String MODE = "EXAM";

    // ============== Exam CRUD ==============

    public List<Exam> listExams() {
        return examRepository.findAll(Sort.by(Sort.Direction.DESC, "id"));
    }

    public List<Exam> listByCategory(String category) {
        return examRepository.findByCategory(category);
    }

    public Exam getExamById(Long id) {
        return examRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("考试不存在"));
    }

    public Exam createExam(Exam exam) {
        exam.setQuestionCount(exam.getQuestionCount() == null ? 0 : exam.getQuestionCount());
        return examRepository.save(exam);
    }

    public Exam updateExam(Long id, Exam exam) {
        Exam existing = getExamById(id);
        existing.setTitle(exam.getTitle());
        existing.setCategory(exam.getCategory());
        existing.setDuration(exam.getDuration());
        existing.setTotalScore(exam.getTotalScore());
        existing.setPassScore(exam.getPassScore());
        existing.setStatus(exam.getStatus());
        return examRepository.save(existing);
    }

    public void deleteExam(Long id) {
        Exam exam = getExamById(id);
        examRepository.delete(exam);
    }

    // ============== Question CRUD ==============

    public List<Question> getQuestions(Long examId) {
        return questionRepository.findByExamId(examId);
    }

    public Question createQuestion(Question question) {
        Question saved = questionRepository.save(question);
        Exam exam = getExamById(question.getExamId());
        exam.setQuestionCount((int) questionRepository.countByExamId(question.getExamId()));
        examRepository.save(exam);
        return saved;
    }

    public Question updateQuestion(Long id, Question question) {
        Question existing = questionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("题目不存在"));
        existing.setContent(question.getContent());
        existing.setOptions(question.getOptions());
        existing.setAnswer(question.getAnswer());
        existing.setType(question.getType());
        return questionRepository.save(existing);
    }

    public void deleteQuestion(Long id) {
        Question q = questionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("题目不存在"));
        Long examId = q.getExamId();
        questionRepository.delete(q);
        Exam exam = getExamById(examId);
        exam.setQuestionCount((int) questionRepository.countByExamId(examId));
        examRepository.save(exam);
    }

    // ============== Exam Taking (Student) ==============

    @Transactional
    public ExamResult startExam(Long examId, Long userId) {
        Exam exam = getExamById(examId);
        // 如果已有进行中的考试记录，直接返回（防止重复创建）
        Optional<ExamResult> existing = examResultRepository.findTopByUserIdAndExamIdAndStatusOrderByIdDesc(
                userId, examId, ExamResult.ResultStatus.IN_PROGRESS);
        if (existing.isPresent()) {
            return existing.get();
        }
        
        List<Question> questions = questionRepository.findByExamId(examId);
        if (questions.isEmpty()) {
            throw new RuntimeException("该考试暂无题目");
        }

        ExamResult result = new ExamResult();
        result.setExamId(examId);
        result.setUserId(userId);
        result.setTotalScore(exam.getTotalScore() != null ? exam.getTotalScore() : questions.size());
        result.setQuestionCount(questions.size());
        result.setCorrectCount(0);
        result.setScore(0);
        result.setStatus(ExamResult.ResultStatus.IN_PROGRESS);
        result.setStartedAt(LocalDateTime.now());
        return examResultRepository.save(result);
    }

    @Transactional
    public ExamResult submitExam(Long resultId, Long userId, List<Map<String, Object>> answers) {
        ExamResult result = examResultRepository.findById(resultId)
                .orElseThrow(() -> new RuntimeException("考试记录不存在"));
        if (!result.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        if (result.getStatus() == ExamResult.ResultStatus.COMPLETED) {
            throw new RuntimeException("考试已提交");
        }

        int correct = 0;
        int total = answers.size();
        for (Map<String, Object> ans : answers) {
            Long qid = Long.valueOf(ans.get("questionId").toString());
            String answer = (String) ans.get("answer");
            Question question = questionRepository.findById(qid).orElse(null);
            if (question == null) continue;
            boolean isCorrect = question.getAnswer() != null && question.getAnswer().equalsIgnoreCase(answer);
            if (isCorrect) correct++;

            QuestionRecord record = new QuestionRecord();
            record.setUserId(userId);
            record.setQuestionId(qid);
            record.setAnswer(answer);
            record.setIsCorrect(isCorrect);
            record.setMode(MODE);
            recordRepository.save(record);
        }

        result.setCorrectCount(correct);
        result.setScore(total > 0 ? (int) Math.round((double) correct / total * result.getTotalScore()) : 0);
        result.setStatus(ExamResult.ResultStatus.COMPLETED);
        result.setCompletedAt(LocalDateTime.now());
        return examResultRepository.save(result);
    }

    public boolean submitSingleAnswer(Long userId, Long questionId, String answer) {
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
        return isCorrect;
    }

    public Map<String, Object> getExamStats(Long examId) {
        Map<String, Object> stats = new HashMap<>();
        List<ExamResult> results = examResultRepository.findByExamId(examId);
        stats.put("totalAttempts", results.size());
        stats.put("completedCount", results.stream().filter(r -> r.getStatus() == ExamResult.ResultStatus.COMPLETED).count());
        double avgScore = results.stream().filter(r -> r.getStatus() == ExamResult.ResultStatus.COMPLETED)
                .mapToInt(ExamResult::getScore).average().orElse(0);
        stats.put("avgScore", Math.round(avgScore * 10) / 10.0);
        return stats;
    }

    // ============== Student Records ==============

    public List<ExamResult> getUserExamResults(Long userId) {
        return examResultRepository.findByUserId(userId);
    }

    public QuestionRecord submitAnswer(QuestionRecord record) {
        if (record.getMode() == null || record.getMode().isEmpty()) {
            record.setMode(MODE);
        }
        return recordRepository.save(record);
    }

    public List<QuestionRecord> getUserRecords(Long userId) {
        return recordRepository.findByUserId(userId);
    }

    public long countInProgressExams(Long userId) {
        return examResultRepository.countByUserIdAndStatus(userId, ExamResult.ResultStatus.IN_PROGRESS);
    }
}
