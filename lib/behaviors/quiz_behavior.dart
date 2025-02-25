import 'dart:async';
import '../models/question.dart';

abstract class QuizBehavior {
  String get name;
  String get description;
  int get questionCount;
  
  Duration? get totalTimeLimit => null;
  Duration? get questionTimeLimit => null;
  
  int calculateScore(bool isCorrect, int currentScore);
  void onQuestionAnswered(Question question, int? selectedAnswer) {}
  void onQuizStarted() {}
  void onQuizFinished() {}
  void dispose() {}
}

class BaseQuizBehavior implements QuizBehavior {
  @override
  final String name;
  @override
  final String description;
  @override
  final int questionCount;

  const BaseQuizBehavior({
    required this.name,
    required this.description,
    required this.questionCount,
  });

  @override
  Duration? get totalTimeLimit => null;

  @override
  Duration? get questionTimeLimit => null;

  @override
  int calculateScore(bool isCorrect, int currentScore) {
    return currentScore + (isCorrect ? 1 : 0);
  }

  @override
  void onQuestionAnswered(Question question, int? selectedAnswer) {}

  @override
  void onQuizStarted() {}

  @override
  void onQuizFinished() {}

  @override
  void dispose() {}
}

abstract class QuizBehaviorDecorator implements QuizBehavior {
  final QuizBehavior behavior;

  QuizBehaviorDecorator(this.behavior);

  @override
  String get name => behavior.name;

  @override
  String get description => behavior.description;

  @override
  int get questionCount => behavior.questionCount;

  @override
  Duration? get totalTimeLimit => behavior.totalTimeLimit;

  @override
  Duration? get questionTimeLimit => behavior.questionTimeLimit;

  @override
  int calculateScore(bool isCorrect, int currentScore) {
    return behavior.calculateScore(isCorrect, currentScore);
  }

  @override
  void onQuestionAnswered(Question question, int? selectedAnswer) {
    behavior.onQuestionAnswered(question, selectedAnswer);
  }

  @override
  void onQuizStarted() {
    behavior.onQuizStarted();
  }

  @override
  void onQuizFinished() {
    behavior.onQuizFinished();
  }

  @override
  void dispose() {
    behavior.dispose();
  }
} 