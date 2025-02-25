import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/game_mode.dart';
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
  IGameMode _gameMode = GameModeFactory.getDefaultMode();
  Timer? _totalTimer;
  Timer? _questionTimer;
  int _remainingTotalTime = 0;
  int _remainingQuestionTime = 0;

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
  IGameMode get gameMode => _gameMode;
  int get remainingTotalTime => _remainingTotalTime;
  int get remainingQuestionTime => _remainingQuestionTime;

  void setGameMode(IGameMode mode) {
    _gameMode = mode;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _isLoading = true;
    _error = null;
    _stopTimers();
    notifyListeners();

    try {
      _questions = await _questionService.getQuestions();
      _questions = _questions.take(_gameMode.questionCount).toList();
      _currentQuestionIndex = 0;
      _isGameFinished = false;
      _score = 0;
      _isHintVisible = false;
      _startTimers();
    } catch (e) {
      _error = 'Failed to load questions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startTimers() {
    if (_gameMode.totalTimeLimit != null) {
      _remainingTotalTime = _gameMode.totalTimeLimit!.inSeconds;
      _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTotalTime > 0) {
          _remainingTotalTime--;
          notifyListeners();
        } else {
          _finishGame();
        }
      });
    }

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    if (_gameMode.questionTimeLimit != null) {
      _remainingQuestionTime = _gameMode.questionTimeLimit!.inSeconds;
      _questionTimer?.cancel();
      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingQuestionTime > 0) {
          _remainingQuestionTime--;
          notifyListeners();
        } else {
          answerQuestion(-1); // Force move to next question on timeout
        }
      });
    }
  }

  void _stopTimers() {
    _totalTimer?.cancel();
    _questionTimer?.cancel();
    _totalTimer = null;
    _questionTimer = null;
  }

  void _finishGame() {
    _isGameFinished = true;
    _stopTimers();
    notifyListeners();
  }

  void answerQuestion(int selectedAnswer) {
    if (_questions.isEmpty || currentQuestion == null) return;

    if (selectedAnswer >= 0) {
      final isCorrect = currentQuestion!.isCorrect(selectedAnswer);
      _score = _gameMode.calculateScore(isCorrect, _score);
    }
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _isHintVisible = false;
      _startQuestionTimer();
      notifyListeners();
    } else {
      _finishGame();
    }
  }

  void resetQuiz() {
    _loadQuestions();
  }

  void toggleHint() {
    _isHintVisible = !_isHintVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
} 