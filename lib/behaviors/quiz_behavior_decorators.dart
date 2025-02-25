import 'dart:async';
import 'quiz_behavior.dart';
import '../models/question.dart';

class NegativeScoreDecorator extends QuizBehaviorDecorator {
  NegativeScoreDecorator(QuizBehavior behavior) : super(behavior);

  @override
  int calculateScore(bool isCorrect, int currentScore) {
    return currentScore + (isCorrect ? 1 : -1);
  }
}

class TimeLimitDecorator extends QuizBehaviorDecorator {
  final Duration timeLimit;
  final void Function() onTimeExpired;
  Timer? _timer;
  int _remainingTime = 0;

  TimeLimitDecorator({
    required QuizBehavior behavior,
    required this.timeLimit,
    required this.onTimeExpired,
  }) : super(behavior);

  int get remainingTime => _remainingTime;

  @override
  void onQuizStarted() {
    super.onQuizStarted();
    _startTimer();
  }

  @override
  void onQuizFinished() {
    super.onQuizFinished();
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _remainingTime = timeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTick(Timer timer) {
    if (_remainingTime <= 0) {
      _stopTimer();
      onTimeExpired();
      return;
    }
    _remainingTime--;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

class QuestionTimeLimitDecorator extends QuizBehaviorDecorator {
  final Duration timeLimit;
  final void Function() onTimeExpired;
  Timer? _timer;
  int _remainingTime = 0;

  QuestionTimeLimitDecorator({
    required QuizBehavior behavior,
    required this.timeLimit,
    required this.onTimeExpired,
  }) : super(behavior);

  int get remainingTime => _remainingTime;

  @override
  void onQuestionAnswered(Question question, int? selectedAnswer) {
    super.onQuestionAnswered(question, selectedAnswer);
    _startTimer();
  }

  @override
  void onQuizStarted() {
    super.onQuizStarted();
    _startTimer();
  }

  @override
  void onQuizFinished() {
    super.onQuizFinished();
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _remainingTime = timeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTick(Timer timer) {
    if (_remainingTime <= 0) {
      _stopTimer();
      onTimeExpired();
      return;
    }
    _remainingTime--;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
} 