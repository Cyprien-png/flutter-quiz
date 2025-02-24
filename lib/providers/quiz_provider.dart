import 'package:flutter/foundation.dart';
import '../models/question.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [
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
    Question(
      text: "Qui a peint la Joconde?",
      options: ["Van Gogh", "Leonard de Vinci", "Picasso"],
      correctAnswerIndex: 1,
      hint: "Un artiste italien de la Renaissance",
    ),
    Question(
      text: "Quelle est la planète la plus proche du soleil?",
      options: ["Venus", "Mars", "Mercure"],
      correctAnswerIndex: 2,
      hint: "La plus petite planète du système solaire",
    ),
    Question(
      text: "Quel est l'élément chimique le plus abondant dans l'univers?",
      options: ["Oxygène", "Hydrogène", "Carbone"],
      correctAnswerIndex: 1,
      hint: "Le plus léger des éléments",
    ),
    Question(
      text: "Quelle est la plus haute montagne du monde?",
      options: ["Mont Blanc", "Kilimandjaro", "Mont Everest"],
      correctAnswerIndex: 2,
      hint: "Située dans l'Himalaya",
    ),
    Question(
      text: "Quel est le plus grand pays du monde?",
      options: ["Russie", "Canada", "Chine"],
      correctAnswerIndex: 0,
      hint: "S'étend sur deux continents",
    ),
    Question(
      text: "Qui a écrit 'Les Misérables'?",
      options: ["Victor Hugo", "Émile Zola", "Gustave Flaubert"],
      correctAnswerIndex: 0,
      hint: "Un grand écrivain français du 19e siècle",
    ),
    Question(
      text: "Quel est le symbole chimique de l'or?",
      options: ["Ag", "Au", "Fe"],
      correctAnswerIndex: 1,
      hint: "Vient du latin 'Aurum'",
    ),
    Question(
      text: "Dans quel pays se trouve la Grande Barrière de Corail?",
      options: ["Brésil", "Indonésie", "Australie"],
      correctAnswerIndex: 2,
      hint: "Dans l'hémisphère sud",
    ),
  ];

  int _currentQuestionIndex = 0;
  bool _isGameFinished = false;

  Question get currentQuestion => _questions[_currentQuestionIndex];
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isGameFinished => _isGameFinished;
  int get totalQuestions => _questions.length;

  void answerQuestion(int selectedAnswer) {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      _isGameFinished = true;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _isGameFinished = false;
    notifyListeners();
  }
} 