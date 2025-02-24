import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:watch_it/watch_it.dart';
import '../models/question.dart';
import '../models/game_mode.dart';
import '../services/question_service.dart';

class QuizProvider {
  final QuestionService _questionService;
  final _questions = ValueNotifier<List<Question>>([]);
  final _currentQuestionIndex = ValueNotifier<int>(0);
  final _isGameFinished = ValueNotifier<bool>(false);
  final _score = ValueNotifier<int>(0);
  final _isHintVisible = ValueNotifier<bool>(false);
  final _isLoading = ValueNotifier<bool>(false);
  final _error = ValueNotifier<String?>(null);
  final _gameMode = ValueNotifier<GameMode>(GameMode.rookie);
  final _remainingTotalTime = ValueNotifier<int>(0);
  final _remainingQuestionTime = ValueNotifier<int>(0);
  Timer? _totalTimer;
  Timer? _questionTimer;

  QuizProvider({required QuestionService questionService}) 
      : _questionService = questionService {
    _loadQuestions();
  }

  ValueListenable<List<Question>> get questionsListenable => _questions;
  List<Question> get questions => _questions.value;
  
  ValueListenable<int> get currentQuestionIndexListenable => _currentQuestionIndex;
  int get currentQuestionIndex => _currentQuestionIndex.value;
  
  Question? get currentQuestion => 
      questions.isEmpty ? null : questions[currentQuestionIndex];
  
  ValueListenable<bool> get isGameFinishedListenable => _isGameFinished;
  bool get isGameFinished => _isGameFinished.value;
  
  int get totalQuestions => questions.length;
  
  ValueListenable<int> get scoreListenable => _score;
  int get score => _score.value;
  
  ValueListenable<bool> get isHintVisibleListenable => _isHintVisible;
  bool get isHintVisible => _isHintVisible.value;
  
  ValueListenable<bool> get isLoadingListenable => _isLoading;
  bool get isLoading => _isLoading.value;
  
  ValueListenable<String?> get errorListenable => _error;
  String? get error => _error.value;
  
  ValueListenable<GameMode> get gameModeListenable => _gameMode;
  GameMode get gameMode => _gameMode.value;
  
  ValueListenable<int> get remainingTotalTimeListenable => _remainingTotalTime;
  int get remainingTotalTime => _remainingTotalTime.value;
  
  ValueListenable<int> get remainingQuestionTimeListenable => _remainingQuestionTime;
  int get remainingQuestionTime => _remainingQuestionTime.value;

  void setGameMode(GameMode mode) {
    _gameMode.value = mode;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _isLoading.value = true;
    _error.value = null;
    _stopTimers();

    try {
      final allQuestions = await _questionService.getQuestions();
      _questions.value = allQuestions.take(gameMode.questionCount).toList();
      _currentQuestionIndex.value = 0;
      _isGameFinished.value = false;
      _score.value = 0;
      _isHintVisible.value = false;
      _startTimers();
    } catch (e) {
      _error.value = 'Failed to load questions: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _startTimers() {
    if (gameMode.totalTimeLimit != null) {
      _remainingTotalTime.value = gameMode.totalTimeLimit!.inSeconds;
      _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTotalTime.value > 0) {
          _remainingTotalTime.value--;
        } else {
          _finishGame();
        }
      });
    }

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    if (gameMode.questionTimeLimit != null) {
      _remainingQuestionTime.value = gameMode.questionTimeLimit!.inSeconds;
      _questionTimer?.cancel();
      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingQuestionTime.value > 0) {
          _remainingQuestionTime.value--;
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
    _isGameFinished.value = true;
    _stopTimers();
  }

  void answerQuestion(int selectedAnswer) {
    if (questions.isEmpty || currentQuestion == null) return;

    if (selectedAnswer >= 0) {
      if (currentQuestion!.isCorrect(selectedAnswer)) {
        _score.value++;
      } else if (gameMode.hasNegativePoints) {
        _score.value--;
      }
    }
    
    if (currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex.value++;
      _isHintVisible.value = false;
      _startQuestionTimer();
    } else {
      _finishGame();
    }
  }

  void resetQuiz() {
    _loadQuestions();
  }

  void toggleHint() {
    _isHintVisible.value = !_isHintVisible.value;
  }

  void dispose() {
    _stopTimers();
    _questions.dispose();
    _currentQuestionIndex.dispose();
    _isGameFinished.dispose();
    _score.dispose();
    _isHintVisible.dispose();
    _isLoading.dispose();
    _error.dispose();
    _gameMode.dispose();
    _remainingTotalTime.dispose();
    _remainingQuestionTime.dispose();
  }
} 