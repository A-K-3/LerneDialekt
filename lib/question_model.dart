// lib/question_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuestionModel extends ChangeNotifier {
  List<Map<String, dynamic>> _questions = [];
  String _result = '';
  String _error = '';
  final String _apiUrl = 'http://localhost:3000/questions';

  List<Map<String, dynamic>> get questions => _questions;

  String get result => _result;

  String get error => _error;

  QuestionModel() {
    loadQuestions(); // Cargar preguntas al crear el modelo
  }

  Future<void> loadQuestions() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _questions = data.map((q) => Map<String, dynamic>.from(q)).toList();
      } else {
        _error = 'Error loading questions: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading questions: $e';
    }
    notifyListeners();
  }

  Future<void> addQuestion(
      String question, List<String> answers, String category) async {
    if (answers.isEmpty) {
      print('Error: The answers list cannot be empty.');
      return;
    }

    final newQuestion = {
      'question': question,
      'answers': answers,
      'category': category
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newQuestion),
      );

      if (response.statusCode == 200) {
        _questions.add(newQuestion);
      }
    } catch (e) {
      print('Error adding question: $e');
    }

    notifyListeners();
  }

  bool compareAnswer(String question, String userAnswer) {
    final matchingQuestion = _questions.firstWhere(
      (q) => q['question'] == question,
      orElse: () => {'answers': []},
    );

    final correctAnswers = List<String>.from(matchingQuestion['answers'] ?? []);

    if (correctAnswers.contains(userAnswer)) {
      _result = 'Correcto!';
      notifyListeners();
      return true;
    } else {
      _result =
          'Incorrecto, las respuestas correctas son: ${correctAnswers.join(', ')}';
      notifyListeners();
      return false;
    }
  }
}
