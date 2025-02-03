// lib/question_model.dart
import 'package:flutter/material.dart';

class QuestionModel extends ChangeNotifier {
  List<Map<String, String>> _questions = [];
  String _result = '';

  List<Map<String, String>> get questions => _questions;
  String get result => _result;

  void addQuestion(String question, String answer) {
    _questions.add({'question': question, 'answer': answer});
    notifyListeners();
  }

  void compareAnswer(String question, String userAnswer) {
    final correctAnswer = _questions.firstWhere((q) => q['question'] == question)['answer'];
    if (userAnswer == correctAnswer) {
      _result = '¡Correcto!';
    } else {
      _result = 'Incorrecto. Inténtalo de nuevo.';
    }
    notifyListeners();
  }
}