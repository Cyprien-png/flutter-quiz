import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: quizProvider.isGameFinished
                ? _buildGameOverScreen(context, quizProvider)
                : _buildQuestionScreen(context, quizProvider),
          ),
        );
      },
    );
  }

  Widget _buildGameOverScreen(BuildContext context, QuizProvider quizProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz terminé!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: ${quizProvider.score} / ${quizProvider.totalQuestions}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => quizProvider.resetQuiz(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Nouvelle Partie',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(BuildContext context, QuizProvider quizProvider) {
    final currentQuestion = quizProvider.currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          currentQuestion.text,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...List.generate(
          currentQuestion.options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () => quizProvider.answerQuestion(index),
              child: Text(currentQuestion.options[index]),
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Question ${quizProvider.currentQuestionIndex + 1} / ${quizProvider.totalQuestions}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
} 