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

  // Getters with null safety and validation
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
    if (mode == _gameMode) return; // Guard: prevent unnecessary updates
    _gameMode = mode;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (_isLoading) return; // Guard: prevent multiple simultaneous loads
    
    _isLoading = true;
    _error = null;
    _stopTimers();
    notifyListeners();

    try {
      final questions = await _questionService.getQuestions();
      if (questions.isEmpty) {
        throw Exception('No questions available');
      }

      _questions = questions.take(_gameMode.questionCount).toList();
      _resetGameState();
      _startTimers();
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

  void _startTimers() {
    _stopTimers(); // Guard: ensure no existing timers are running

    if (_gameMode.totalTimeLimit != null) {
      _remainingTotalTime = _gameMode.totalTimeLimit!.inSeconds;
      _totalTimer = Timer.periodic(const Duration(seconds: 1), _handleTotalTimer);
    }

    _startQuestionTimer();
  }

  void _handleTotalTimer(Timer timer) {
    if (_remainingTotalTime <= 0) {
      _finishGame();
      return;
    }
    _remainingTotalTime--;
    notifyListeners();
  }

  void _startQuestionTimer() {
    if (_gameMode.questionTimeLimit == null) return;

    _questionTimer?.cancel();
    _remainingQuestionTime = _gameMode.questionTimeLimit!.inSeconds;
    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      _handleQuestionTimer,
    );
  }

  void _handleQuestionTimer(Timer timer) {
    if (_remainingQuestionTime <= 0) {
      answerQuestion(-1);
      return;
    }
    _remainingQuestionTime--;
    notifyListeners();
  }

  void _stopTimers() {
    _totalTimer?.cancel();
    _questionTimer?.cancel();
    _totalTimer = null;
    _questionTimer = null;
  }

  void _finishGame() {
    if (_isGameFinished) return; // Guard: prevent multiple finish calls
    
    _isGameFinished = true;
    _stopTimers();
    notifyListeners();
  }

  void answerQuestion(int selectedAnswer) {
    if (_questions.isEmpty || 
        currentQuestion == null || 
        _isGameFinished) return; // Guard: validate game state

    if (selectedAnswer >= 0 && selectedAnswer < currentQuestion!.options.length) {
      final isCorrect = currentQuestion!.isCorrect(selectedAnswer);
      _score = _gameMode.calculateScore(isCorrect, _score);
    }
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _isHintVisible = false;
      _startQuestionTimer();
    } else {
      _finishGame();
    }
    
    notifyListeners();
  }

  void resetQuiz() {
    if (_isLoading) return; // Guard: prevent reset while loading
    _loadQuestions();
  }

  void toggleHint() {
    if (_isGameFinished || currentQuestion?.hint == null) return; // Guard: validate hint availability
    _isHintVisible = !_isHintVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
} 