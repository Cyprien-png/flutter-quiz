abstract class IGameMode {
  String get name;
  int get questionCount;
  String get description;
  bool get hasNegativePoints;
  Duration? get totalTimeLimit;
  Duration? get questionTimeLimit;
  int calculateScore(bool isCorrect, int currentScore);
}

class BaseGameMode implements IGameMode {
  @override
  final String name;
  @override
  final int questionCount;
  @override
  final String description;
  @override
  final bool hasNegativePoints;
  @override
  final Duration? totalTimeLimit;
  @override
  final Duration? questionTimeLimit;

  const BaseGameMode({
    required this.name,
    required this.questionCount,
    required this.description,
    required this.hasNegativePoints,
    this.totalTimeLimit,
    this.questionTimeLimit,
  });

  @override
  int calculateScore(bool isCorrect, int currentScore) {
    if (!isCorrect && !hasNegativePoints) return currentScore;
    return currentScore + (isCorrect ? 1 : -1);
  }
}

class RookieMode extends BaseGameMode {
  RookieMode()
      : super(
          name: 'Rookie',
          questionCount: 10,
          description: '10 questions, +1 point par bonne réponse',
          hasNegativePoints: false,
        );

  @override
  int calculateScore(bool isCorrect, int currentScore) {
    return isCorrect ? currentScore + 1 : currentScore;
  }
}

class JourneymanMode extends BaseGameMode {
  JourneymanMode()
      : super(
          name: 'Journeyman',
          questionCount: 10,
          description: '10 questions, +1 point par bonne réponse, -1 point par mauvaise réponse',
          hasNegativePoints: true,
        );
}

class WarriorMode extends BaseGameMode {
  WarriorMode()
      : super(
          name: 'Warrior',
          questionCount: 15,
          description: '15 questions, +1/-1 points, limite de temps de 30 secondes',
          hasNegativePoints: true,
          totalTimeLimit: const Duration(seconds: 30),
        );
}

class NinjaMode extends BaseGameMode {
  NinjaMode()
      : super(
          name: 'Ninja',
          questionCount: 15,
          description: '15 questions, +1/-1 points, 30 secondes au total, 4 secondes par question',
          hasNegativePoints: true,
          totalTimeLimit: const Duration(seconds: 30),
          questionTimeLimit: const Duration(seconds: 4),
        );
}

class GameModeFactory {
  static final List<IGameMode> allModes = [
    RookieMode(),
    JourneymanMode(),
    WarriorMode(),
    NinjaMode(),
  ];

  static IGameMode getDefaultMode() => RookieMode();
} 