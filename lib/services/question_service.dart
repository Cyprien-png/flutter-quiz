import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import '../models/question.dart';

abstract class QuestionService {
  Future<List<Question>> getQuestions();
}

class QuestionServiceException implements Exception {
  final String message;
  final dynamic originalError;

  QuestionServiceException(this.message, [this.originalError]);

  @override
  String toString() => 'QuestionServiceException: $message${originalError != null ? ' ($originalError)' : ''}';
}

class RestQuestionService implements QuestionService {
  final String baseUrl;
  final http.Client _client;
  final HtmlUnescape _htmlUnescape;

  RestQuestionService({
    String? baseUrl,
    http.Client? client,
    HtmlUnescape? htmlUnescape,
  }) : baseUrl = baseUrl ?? 'https://opentdb.com/api.php',
       _client = client ?? http.Client(),
       _htmlUnescape = htmlUnescape ?? HtmlUnescape();

  @override
  Future<List<Question>> getQuestions() async {
    try {
      final response = await _fetchQuestions();
      final data = _parseResponse(response);
      return _transformToQuestions(data);
    } catch (e) {
      throw QuestionServiceException('Failed to fetch questions', e);
    }
  }

  Future<http.Response> _fetchQuestions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl?amount=10&type=multiple'),
      );

      if (response.statusCode != 200) {
        throw QuestionServiceException(
          'Server returned status code: ${response.statusCode}',
        );
      }

      return response;
    } catch (e) {
      throw QuestionServiceException('Network error while fetching questions', e);
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw QuestionServiceException('Invalid response format', e);
    }
  }

  String _decodeHtmlEntities(String text) {
    return _htmlUnescape.convert(text);
  }

  List<Question> _transformToQuestions(Map<String, dynamic> data) {
    final results = data['results'] as List? ?? [];
    
    if (results.isEmpty) {
      throw QuestionServiceException('No questions received from the server');
    }

    return results.map((questionData) {
      try {
        final List<String> incorrectAnswers = 
            (questionData['incorrect_answers'] as List? ?? [])
            .map((answer) => _decodeHtmlEntities(answer.toString()))
            .toList();
        final String correctAnswer = _decodeHtmlEntities(
          questionData['correct_answer']?.toString() ?? ''
        );
        
        if (incorrectAnswers.isEmpty || correctAnswer.isEmpty) {
          throw QuestionServiceException('Invalid question data format');
        }

        final options = [...incorrectAnswers, correctAnswer]..shuffle();

        return Question(
          text: _decodeHtmlEntities(questionData['question']?.toString() ?? ''),
          options: options,
          correctAnswerIndex: options.indexOf(correctAnswer),
          hint: "Indice: ${_decodeHtmlEntities(questionData['category']?.toString() ?? 'General')}",
        );
      } catch (e) {
        throw QuestionServiceException('Error transforming question data', e);
      }
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}

class LocalQuestionService implements QuestionService {
  @override
  Future<List<Question>> getQuestions() async {
    // Simulating async behavior
    return Future.value([
      Question(
        text: "Quelle est la capitale de la France?",
        options: ["Londres", "Paris", "Berlin", "Madrid"],
        correctAnswerIndex: 1,
        hint: "La ville avec la Tour Eiffel",
      ),
      Question(
        text: "Quel est le plus grand océan du monde?",
        options: ["Atlantique", "Indien", "Pacifique", "Arctique"],
        correctAnswerIndex: 2,
        hint: "Il borde l'Asie et les Amériques",
      ),
    ]);
  }
} 