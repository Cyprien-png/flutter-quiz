import '../models/question.dart';
import '../models/game_mode.dart';

class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final bool isGameFinished;
  final int score;
  final bool isHintVisible;
  final bool isLoading;
  final String? error;
  final IGameMode gameMode;
  final int remainingTotalTime;
  final int remainingQuestionTime;

  const QuizState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.isGameFinished,
    required this.score,
    required this.isHintVisible,
    required this.isLoading,
    required this.gameMode,
    this.error,
    this.remainingTotalTime = 0,
    this.remainingQuestionTime = 0,
  });

  Question? get currentQuestion => 
      questions.isEmpty ? null : questions[currentQuestionIndex];

  int get totalQuestions => questions.length;

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    bool? isGameFinished,
    int? score,
    bool? isHintVisible,
    bool? isLoading,
    String? error,
    IGameMode? gameMode,
    int? remainingTotalTime,
    int? remainingQuestionTime,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      score: score ?? this.score,
      isHintVisible: isHintVisible ?? this.isHintVisible,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      gameMode: gameMode ?? this.gameMode,
      remainingTotalTime: remainingTotalTime ?? this.remainingTotalTime,
      remainingQuestionTime: remainingQuestionTime ?? this.remainingQuestionTime,
    );
  }
} 