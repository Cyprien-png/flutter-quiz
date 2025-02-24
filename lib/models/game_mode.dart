enum GameMode {
  rookie(
    name: 'Rookie',
    questionCount: 10,
    description: '10 questions, +1 point par bonne réponse',
    hasNegativePoints: false,
    totalTimeLimit: null,
    questionTimeLimit: null,
  ),
  journeyman(
    name: 'Journeyman',
    questionCount: 10,
    description: '10 questions, +1 point par bonne réponse, -1 point par mauvaise réponse',
    hasNegativePoints: true,
    totalTimeLimit: null,
    questionTimeLimit: null,
  ),
  warrior(
    name: 'Warrior',
    questionCount: 15,
    description: '15 questions, +1/-1 points, limite de temps de 30 secondes',
    hasNegativePoints: true,
    totalTimeLimit: Duration(seconds: 30),
    questionTimeLimit: null,
  ),
  ninja(
    name: 'Ninja',
    questionCount: 15,
    description: '15 questions, +1/-1 points, 30 secondes au total, 4 secondes par question',
    hasNegativePoints: true,
    totalTimeLimit: Duration(seconds: 30),
    questionTimeLimit: Duration(seconds: 4),
  );

  const GameMode({
    required this.name,
    required this.questionCount,
    required this.description,
    required this.hasNegativePoints,
    required this.totalTimeLimit,
    required this.questionTimeLimit,
  });

  final String name;
  final int questionCount;
  final String description;
  final bool hasNegativePoints;
  final Duration? totalTimeLimit;
  final Duration? questionTimeLimit;
} 