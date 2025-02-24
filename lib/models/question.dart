class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? hint;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.hint,
  });

  bool isCorrect(int selectedAnswer) {
    return selectedAnswer == correctAnswerIndex;
  }
} 