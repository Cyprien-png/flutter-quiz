import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/game_mode.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/game_mode_controllers.dart';
import '../services/question_service.dart';
import '../behaviors/quiz_behavior.dart';
import '../behaviors/quiz_behavior_factory.dart';
import '../behaviors/quiz_behavior_decorators.dart';

class QuizProvider with ChangeNotifier {
  final QuestionService _questionService;
  QuizBehavior _behavior;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isGameFinished = false;
  int _score = 0;
  bool _isHintVisible = false;
  bool _isLoading = false;
  String? _error;

  QuizProvider({required QuestionService questionService})
      : _questionService = questionService,
        _behavior = QuizBehaviorFactory.createRookieMode() {
    _loadQuestions();
  }

  // Getters
  Question? get currentQuestion => 
      _questions.isEmpty ? null : _questions[_currentQuestionIndex];
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isGameFinished => _isGameFinished;
  int get totalQuestions => _questions.length;
  int get score => _score;
  bool get isHintVisible => _isHintVisible;
  bool get isLoading => _isLoading;
  String? get error => _error;
  QuizBehavior get behavior => _behavior;
  int get remainingTotalTime => 
      (_behavior is TimeLimitDecorator) ? 
      (_behavior as TimeLimitDecorator).remainingTime : 0;
  int get remainingQuestionTime => 
      (_behavior is QuestionTimeLimitDecorator) ? 
      (_behavior as QuestionTimeLimitDecorator).remainingTime : 0;

  void setBehavior(QuizBehavior newBehavior) {
    if (newBehavior == _behavior) return;
    
    _behavior.dispose();
    _behavior = newBehavior;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final questions = await _questionService.getQuestions();
      if (questions.isEmpty) {
        throw Exception('No questions available');
      }

      _questions = questions.take(_behavior.questionCount).toList();
      _resetGameState();
      _behavior.onQuizStarted();
    } catch (e) {
      _error = 'Failed to load questions: $e';
      _questions = [];
      _resetGameState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetGameState() {
    _currentQuestionIndex = 0;
    _isGameFinished = false;
    _score = 0;
    _isHintVisible = false;
  }

  void answerQuestion(int selectedAnswer) {
    if (_questions.isEmpty || 
        currentQuestion == null || 
        _isGameFinished) return;

    if (selectedAnswer >= 0 && selectedAnswer < currentQuestion!.options.length) {
      final isCorrect = currentQuestion!.isCorrect(selectedAnswer);
      _score = _behavior.calculateScore(isCorrect, _score);
    }

    _behavior.onQuestionAnswered(currentQuestion!, selectedAnswer);
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _isHintVisible = false;
    } else {
      _finishGame();
    }
    
    notifyListeners();
  }

  void _finishGame() {
    if (_isGameFinished) return;
    
    _isGameFinished = true;
    _behavior.onQuizFinished();
    notifyListeners();
  }

  void resetQuiz() {
    if (_isLoading) return;
    _loadQuestions();
  }

  void toggleHint() {
    if (_isGameFinished || currentQuestion?.hint == null) return;
    _isHintVisible = !_isHintVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _behavior.dispose();
    super.dispose();
  }
} 