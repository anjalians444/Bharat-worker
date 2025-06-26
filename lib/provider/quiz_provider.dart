import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  final List<QuizQuestion> _questions = sampleQuizQuestions;
  int _currentIndex = 0;
  final List<int?> _selectedAnswers = List.filled(sampleQuizQuestions.length, null);
  bool _submitted = false;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  List<int?> get selectedAnswers => _selectedAnswers;
  bool get submitted => _submitted;

  int get score {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctIndex) correct++;
    }
    return correct;
  }

  void selectAnswer(int answerIndex) {
    _selectedAnswers[_currentIndex] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void submitQuiz({VoidCallback? onPassed}) {
    _submitted = true;
    notifyListeners();
   // if (onPassed != null && score / _questions.length >= 0.8) {
      onPassed!();
   // }
  }

  void resetQuiz() {
    _currentIndex = 0;
    for (int i = 0; i < _selectedAnswers.length; i++) {
      _selectedAnswers[i] = null;
    }
    _submitted = false;
    notifyListeners();
  }
} 