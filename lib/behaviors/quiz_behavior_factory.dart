import 'quiz_behavior.dart';
import 'quiz_behavior_decorators.dart';

class QuizBehaviorFactory {
  static QuizBehavior createRookieMode() {
    return BaseQuizBehavior(
      name: 'Rookie',
      description: '10 questions, +1 point par bonne réponse',
      questionCount: 10,
    );
  }

  static QuizBehavior createJourneymanMode() {
    return NegativeScoreDecorator(
      BaseQuizBehavior(
        name: 'Journeyman',
        description: '10 questions, +1/-1 points',
        questionCount: 10,
      ),
    );
  }

  static QuizBehavior createWarriorMode({
    required void Function() onTimeExpired,
  }) {
    return TimeLimitDecorator(
      behavior: NegativeScoreDecorator(
        BaseQuizBehavior(
          name: 'Warrior',
          description: '15 questions, +1/-1 points, limite de temps de 30 secondes',
          questionCount: 15,
        ),
      ),
      timeLimit: const Duration(seconds: 30),
      onTimeExpired: onTimeExpired,
    );
  }

  static QuizBehavior createNinjaMode({
    required void Function() onTotalTimeExpired,
    required void Function() onQuestionTimeExpired,
  }) {
    final base = BaseQuizBehavior(
      name: 'Ninja',
      description: '15 questions, +1/-1 points, 30 secondes au total, 4 secondes par question',
      questionCount: 15,
    );

    return QuestionTimeLimitDecorator(
      behavior: TimeLimitDecorator(
        behavior: NegativeScoreDecorator(base),
        timeLimit: const Duration(seconds: 30),
        onTimeExpired: onTotalTimeExpired,
      ),
      timeLimit: const Duration(seconds: 4),
      onTimeExpired: onQuestionTimeExpired,
    );
  }

  static List<QuizBehavior> get allModes => [
    createRookieMode(),
    createJourneymanMode(),
    createWarriorMode(onTimeExpired: () {}),
    createNinjaMode(
      onTotalTimeExpired: () {},
      onQuestionTimeExpired: () {},
    ),
  ];
} 