import 'dart:async';
import '../models/game_mode.dart';
import '../models/quiz_state.dart';
import 'quiz_controller.dart';

class RookieQuizController extends QuizController {
  RookieQuizController({required super.questionService});

  @override
  IGameMode getDefaultGameMode() => RookieMode();

  @override
  void onTotalTimerTick(Timer timer) {
    // No total timer in rookie mode
  }

  @override
  void onQuestionTimerTick(Timer timer) {
    // No question timer in rookie mode
  }
}

class JourneymanQuizController extends QuizController {
  JourneymanQuizController({required super.questionService});

  @override
  IGameMode getDefaultGameMode() => JourneymanMode();

  @override
  void onTotalTimerTick(Timer timer) {
    // No total timer in journeyman mode
  }

  @override
  void onQuestionTimerTick(Timer timer) {
    // No question timer in journeyman mode
  }
}

class WarriorQuizController extends QuizController {
  QuizState? _currentState;
  final void Function(QuizState) onStateChanged;

  WarriorQuizController({
    required super.questionService,
    required this.onStateChanged,
  });

  @override
  IGameMode getDefaultGameMode() => WarriorMode();

  @override
  void onTotalTimerTick(Timer timer) {
    if (_currentState == null) return;

    if (_currentState!.remainingTotalTime <= 0) {
      timer.cancel();
      onStateChanged(_currentState!.copyWith(isGameFinished: true));
      return;
    }

    onStateChanged(_currentState!.copyWith(
      remainingTotalTime: _currentState!.remainingTotalTime - 1,
    ));
  }

  @override
  void onQuestionTimerTick(Timer timer) {
    // No question timer in warrior mode
  }

  void updateState(QuizState newState) {
    _currentState = newState;
  }
}

class NinjaQuizController extends QuizController {
  QuizState? _currentState;
  final void Function(QuizState) onStateChanged;

  NinjaQuizController({
    required super.questionService,
    required this.onStateChanged,
  });

  @override
  IGameMode getDefaultGameMode() => NinjaMode();

  @override
  void onTotalTimerTick(Timer timer) {
    if (_currentState == null) return;

    if (_currentState!.remainingTotalTime <= 0) {
      timer.cancel();
      onStateChanged(_currentState!.copyWith(isGameFinished: true));
      return;
    }

    onStateChanged(_currentState!.copyWith(
      remainingTotalTime: _currentState!.remainingTotalTime - 1,
    ));
  }

  @override
  void onQuestionTimerTick(Timer timer) {
    if (_currentState == null) return;

    if (_currentState!.remainingQuestionTime <= 0) {
      timer.cancel();
      final newState = handleAnswer(_currentState!, -1);
      onStateChanged(newState);
      return;
    }

    onStateChanged(_currentState!.copyWith(
      remainingQuestionTime: _currentState!.remainingQuestionTime - 1,
    ));
  }

  void updateState(QuizState newState) {
    _currentState = newState;
  }
} 