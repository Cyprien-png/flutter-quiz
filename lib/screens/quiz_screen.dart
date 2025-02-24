import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import 'game_mode_screen.dart';

class QuizScreen extends StatelessWidget {
  final QuizProvider quizProvider;

  const QuizScreen({super.key, required this.quizProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<GameMode>(
          valueListenable: quizProvider.gameModeListenable,
          builder: (context, gameMode, _) => Text('Quiz - ${gameMode.name}'),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(context, quizProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizProvider quizProvider) {
    return ValueListenableBuilder<bool>(
      valueListenable: quizProvider.isLoadingListenable,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ValueListenableBuilder<String?>(
          valueListenable: quizProvider.errorListenable,
          builder: (context, error, _) {
            if (error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $error',
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

            return ValueListenableBuilder<List<Question>>(
              valueListenable: quizProvider.questionsListenable,
              builder: (context, questions, _) {
                if (questions.isEmpty) {
                  return const Center(
                    child: Text('No questions available'),
                  );
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: quizProvider.isGameFinishedListenable,
                  builder: (context, isGameFinished, _) {
                    return isGameFinished
                        ? _buildGameOverScreen(context, quizProvider)
                        : _buildQuestionScreen(context, quizProvider);
                  },
                );
              },
            );
          },
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
          ValueListenableBuilder<int>(
            valueListenable: quizProvider.scoreListenable,
            builder: (context, score, _) {
              return Text(
                'Score: $score / ${quizProvider.totalQuestions}',
                style: const TextStyle(fontSize: 20),
              );
            },
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
                  builder: (context) => GameModeScreen(quizProvider: quizProvider),
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
    return ValueListenableBuilder<GameMode>(
      valueListenable: quizProvider.gameModeListenable,
      builder: (context, gameMode, _) {
        return ValueListenableBuilder<Question?>(
          valueListenable: ValueNotifier(quizProvider.currentQuestion),
          builder: (context, currentQuestion, _) {
            if (currentQuestion == null) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (gameMode.totalTimeLimit != null)
                  ValueListenableBuilder<int>(
                    valueListenable: quizProvider.remainingTotalTimeListenable,
                    builder: (context, remainingTime, _) {
                      return Text(
                        'Temps restant: ${remainingTime}s',
                        style: TextStyle(
                          fontSize: 16,
                          color: remainingTime < 10 ? Colors.red : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                if (gameMode.questionTimeLimit != null)
                  ValueListenableBuilder<int>(
                    valueListenable: quizProvider.remainingQuestionTimeListenable,
                    builder: (context, remainingTime, _) {
                      return Text(
                        'Temps pour cette question: ${remainingTime}s',
                        style: TextStyle(
                          fontSize: 16,
                          color: remainingTime < 2 ? Colors.red : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
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
                ValueListenableBuilder<bool>(
                  valueListenable: quizProvider.isHintVisibleListenable,
                  builder: (context, isHintVisible, _) {
                    if (!isHintVisible || currentQuestion.hint == null) {
                      return const SizedBox();
                    }
                    return Padding(
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
                    );
                  },
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
                ValueListenableBuilder<int>(
                  valueListenable: quizProvider.currentQuestionIndexListenable,
                  builder: (context, currentIndex, _) {
                    return Text(
                      'Question ${currentIndex + 1} / ${quizProvider.totalQuestions}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
} 