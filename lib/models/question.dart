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
  }) {
    // Input validation
    if (text.trim().isEmpty) {
      throw ArgumentError('Question text cannot be empty');
    }
    if (options.isEmpty) {
      throw ArgumentError('Options list cannot be empty');
    }
    if (correctAnswerIndex < 0 || correctAnswerIndex >= options.length) {
      throw ArgumentError('Invalid correct answer index');
    }
    if (options.any((option) => option.trim().isEmpty)) {
      throw ArgumentError('Options cannot be empty strings');
    }
  }

  bool isCorrect(int selectedAnswer) {
    if (selectedAnswer < 0 || selectedAnswer >= options.length) {
      return false;
    }
    return selectedAnswer == correctAnswerIndex;
  }

  // Immutable list to prevent external modifications
  List<String> get availableOptions => List.unmodifiable(options);
} 