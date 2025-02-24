import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../models/game_mode.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class GameModeScreen extends StatelessWidget with WatchItMixin {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un mode de jeu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: GameMode.values.length,
        itemBuilder: (context, index) {
          final gameMode = GameMode.values[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                final quizProvider = di<QuizProvider>();
                quizProvider.setGameMode(gameMode);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const QuizScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameMode.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      gameMode.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 