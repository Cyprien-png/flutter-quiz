import 'dart:async';
import '../models/quiz_state.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import '../services/question_service.dart';

abstract class QuizController {
  final QuestionService questionService;
  Timer? _totalTimer;
  Timer? _questionTimer;

  QuizController({
    required this.questionService,
  });

  QuizState get initialState => QuizState(
    questions: [],
    currentQuestionIndex: 0,
    isGameFinished: false,
    score: 0,
    isHintVisible: false,
    isLoading: false,
    gameMode: getDefaultGameMode(),
  );

  IGameMode getDefaultGameMode();

  Future<QuizState> loadQuestions(QuizState currentState) async {
    if (currentState.isLoading) {
      return currentState;
    }

    stopTimers();
    
    try {
      final questions = await questionService.getQuestions();
      if (questions.isEmpty) {
        return currentState.copyWith(
          error: 'No questions available',
          isLoading: false,
        );
      }

      final filteredQuestions = questions.take(currentState.gameMode.questionCount).toList();
      
      final newState = currentState.copyWith(
        questions: filteredQuestions,
        currentQuestionIndex: 0,
        isGameFinished: false,
        score: 0,
        isHintVisible: false,
        error: null,
        isLoading: false,
      );

      return startTimers(newState);
    } catch (e) {
      return currentState.copyWith(
        error: 'Failed to load questions: $e',
        questions: [],
        isLoading: false,
      );
    }
  }

  QuizState handleAnswer(QuizState currentState, int selectedAnswer) {
    if (currentState.questions.isEmpty || 
        currentState.currentQuestion == null || 
        currentState.isGameFinished) {
      return currentState;
    }

    var newScore = currentState.score;
    if (selectedAnswer >= 0 && selectedAnswer < currentState.currentQuestion!.options.length) {
      final isCorrect = currentState.currentQuestion!.isCorrect(selectedAnswer);
      newScore = currentState.gameMode.calculateScore(isCorrect, currentState.score);
    }

    if (currentState.isLastQuestion) {
      stopTimers();
      return currentState.copyWith(
        score: newScore,
        isGameFinished: true,
      );
    }

    final newState = currentState.copyWith(
      currentQuestionIndex: currentState.currentQuestionIndex + 1,
      score: newScore,
      isHintVisible: false,
    );

    return startQuestionTimer(newState);
  }

  QuizState toggleHint(QuizState currentState) {
    if (currentState.isGameFinished || currentState.currentQuestion?.hint == null) {
      return currentState;
    }
    return currentState.copyWith(isHintVisible: !currentState.isHintVisible);
  }

  QuizState startTimers(QuizState state) {
    stopTimers();
    
    var newState = state;
    if (state.gameMode.totalTimeLimit != null) {
      final totalSeconds = state.gameMode.totalTimeLimit!.inSeconds;
      newState = state.copyWith(remainingTotalTime: totalSeconds);
      _totalTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) => onTotalTimerTick(timer),
      );
    }

    return startQuestionTimer(newState);
  }

  QuizState startQuestionTimer(QuizState state) {
    _questionTimer?.cancel();
    
    if (state.gameMode.questionTimeLimit != null) {
      final questionSeconds = state.gameMode.questionTimeLimit!.inSeconds;
      _questionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) => onQuestionTimerTick(timer),
      );
      return state.copyWith(remainingQuestionTime: questionSeconds);
    }
    
    return state;
  }

  void stopTimers() {
    _totalTimer?.cancel();
    _questionTimer?.cancel();
    _totalTimer = null;
    _questionTimer = null;
  }

  void dispose() {
    stopTimers();
  }

  // These methods should be implemented by subclasses to handle timer ticks
  void onTotalTimerTick(Timer timer);
  void onQuestionTimerTick(Timer timer);
} 