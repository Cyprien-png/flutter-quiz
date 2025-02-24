import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/game_mode.dart';
import 'game_mode_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz - ${quizProvider.gameMode.name}'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBody(context, quizProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizProvider quizProvider) {
    if (quizProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (quizProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${quizProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => quizProvider.resetQuiz(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (quizProvider.currentQuestion == null) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    return quizProvider.isGameFinished
        ? _buildGameOverScreen(context, quizProvider)
        : _buildQuestionScreen(context, quizProvider);
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
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const GameModeScreen(),
                ),
              );
            },
            child: const Text(
              'Changer de mode de jeu',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(BuildContext context, QuizProvider quizProvider) {
    final currentQuestion = quizProvider.currentQuestion!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (quizProvider.gameMode.totalTimeLimit != null)
          Text(
            'Temps restant: ${quizProvider.remainingTotalTime}s',
            style: TextStyle(
              fontSize: 16,
              color: quizProvider.remainingTotalTime < 10 ? Colors.red : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        if (quizProvider.gameMode.questionTimeLimit != null)
          Text(
            'Temps pour cette question: ${quizProvider.remainingQuestionTime}s',
            style: TextStyle(
              fontSize: 16,
              color: quizProvider.remainingQuestionTime < 2 ? Colors.red : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                currentQuestion.text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (currentQuestion.hint != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => quizProvider.toggleHint(),
              ),
          ],
        ),
        if (quizProvider.isHintVisible && currentQuestion.hint != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentQuestion.hint!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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