import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/game_mode.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/game_mode_controllers.dart';
import '../services/question_service.dart';

class QuizProvider with ChangeNotifier {
  QuizController _controller;
  QuizState _state;

  QuizProvider({required QuestionService questionService})
      : _controller = RookieQuizController(questionService: questionService),
        _state = RookieQuizController(questionService: questionService).initialState {
    _loadQuestions();
  }

  // Getters
  Question? get currentQuestion => _state.currentQuestion;
  int get currentQuestionIndex => _state.currentQuestionIndex;
  bool get isGameFinished => _state.isGameFinished;
  int get totalQuestions => _state.totalQuestions;
  int get score => _state.score;
  bool get isHintVisible => _state.isHintVisible;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  IGameMode get gameMode => _state.gameMode;
  int get remainingTotalTime => _state.remainingTotalTime;
  int get remainingQuestionTime => _state.remainingQuestionTime;

  void setGameMode(IGameMode mode) {
    if (mode == _state.gameMode) return;

    // Create appropriate controller based on game mode
    final QuizController newController = _createControllerForMode(mode);
    
    // Dispose old controller
    _controller.dispose();
    
    // Set new controller and initial state
    _controller = newController;
    _state = newController.initialState;
    
    // Load questions with new game mode
    _loadQuestions();
  }

  QuizController _createControllerForMode(IGameMode mode) {
    if (mode is RookieMode) {
      return RookieQuizController(questionService: _controller.questionService);
    } else if (mode is JourneymanMode) {
      return JourneymanQuizController(questionService: _controller.questionService);
    } else if (mode is WarriorMode) {
      return WarriorQuizController(
        questionService: _controller.questionService,
        onStateChanged: _updateState,
      );
    } else if (mode is NinjaMode) {
      return NinjaQuizController(
        questionService: _controller.questionService,
        onStateChanged: _updateState,
      );
    }
    throw ArgumentError('Unsupported game mode: ${mode.runtimeType}');
  }

  void _updateState(QuizState newState) {
    _state = newState;
    if (_controller is WarriorQuizController) {
      (_controller as WarriorQuizController).updateState(newState);
    } else if (_controller is NinjaQuizController) {
      (_controller as NinjaQuizController).updateState(newState);
    }
    notifyListeners();
  }

  Future<void> _loadQuestions() async {
    _updateState(_state.copyWith(isLoading: true));
    final newState = await _controller.loadQuestions(_state);
    _updateState(newState);
  }

  void answerQuestion(int selectedAnswer) {
    final newState = _controller.handleAnswer(_state, selectedAnswer);
    _updateState(newState);
  }

  void resetQuiz() {
    if (_state.isLoading) return;
    _loadQuestions();
  }

  void toggleHint() {
    final newState = _controller.toggleHint(_state);
    _updateState(newState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 