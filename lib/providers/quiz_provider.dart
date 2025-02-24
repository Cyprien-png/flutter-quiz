import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class QuizProvider with ChangeNotifier {
  final QuestionService _questionService;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isGameFinished = false;
  int _score = 0;
  bool _isHintVisible = false;
  bool _isLoading = false;
  String? _error;

  QuizProvider({required QuestionService questionService}) 
      : _questionService = questionService {
    _loadQuestions();
  }

  Question? get currentQuestion => 
      _questions.isEmpty ? null : _questions[_currentQuestionIndex];
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isGameFinished => _isGameFinished;
  int get totalQuestions => _questions.length;
  int get score => _score;
  bool get isHintVisible => _isHintVisible;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _questionService.getQuestions();
      _currentQuestionIndex = 0;
      _isGameFinished = false;
      _score = 0;
      _isHintVisible = false;
    } catch (e) {
      _error = 'Failed to load questions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerQuestion(int selectedAnswer) {
    if (_questions.isEmpty || currentQuestion == null) return;

    if (currentQuestion!.isCorrect(selectedAnswer)) {
      _score++;
    }
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _isHintVisible = false;
      notifyListeners();
    } else {
      _isGameFinished = true;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _loadQuestions();
  }

  void toggleHint() {
    _isHintVisible = !_isHintVisible;
    notifyListeners();
  }
} 