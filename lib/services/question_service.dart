import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

abstract class QuestionService {
  Future<List<Question>> getQuestions();
}

class RestQuestionService implements QuestionService {
  final String baseUrl = 'https://opentdb.com/api.php';

  @override
  Future<List<Question>> getQuestions() async {
    final response = await http.get(
      Uri.parse('$baseUrl?amount=10&type=multiple'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      
      return results.map((questionData) {
        final options = [
          ...questionData['incorrect_answers'],
          questionData['correct_answer'],
        ]..shuffle();

        return Question(
          text: questionData['question'],
          options: options.cast<String>(),
          correctAnswerIndex: options.indexOf(questionData['correct_answer']),
          hint: "Indice: ${questionData['category']}",
        );
      }).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

class LocalQuestionService implements QuestionService {
  @override
  Future<List<Question>> getQuestions() async {
    // Simulating async behavior
    return Future.value([
      Question(
        text: "Quelle est la capitale de la France?",
        options: ["Londres", "Paris", "Berlin"],
        correctAnswerIndex: 1,
        hint: "La ville avec la Tour Eiffel",
      ),
      Question(
        text: "Quel est le plus grand océan du monde?",
        options: ["Atlantique", "Indien", "Pacifique"],
        correctAnswerIndex: 2,
        hint: "Il borde l'Asie et les Amériques",
      ),
      // ... Add more questions as needed
    ]);
  }
} 