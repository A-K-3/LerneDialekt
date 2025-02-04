import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionModel extends ChangeNotifier {
  List<Map<String, String>> _questions = [];
  String _result = '';
  final String _apiUrl = 'http://localhost:3000/questions';

  List<Map<String, String>> get questions => _questions;
  String get result => _result;

  QuestionModel() {
    _loadQuestions();
  }

  /// Cargar preguntas desde el backend
  Future<void> _loadQuestions() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _questions = data.map((q) => Map<String, String>.from(q)).toList();
      }
    } catch (e) {
      print('Error cargando preguntas: $e');
    }
    notifyListeners();
  }

  /// Agregar una nueva pregunta y guardarla en el backend
  Future<void> addQuestion(String question, String answer) async {
    final newQuestion = {'question': question, 'answer': answer};

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
      print('Error agregando pregunta: $e');
    }

    notifyListeners();
  }

  /// Comparar respuesta del usuario con la correcta
  void compareAnswer(String question, String userAnswer) {
    final matchingQuestion = _questions.firstWhere(
          (q) => q['question'] == question,
      orElse: () => {'answer': ''},
    );

    final correctAnswer = matchingQuestion['answer'] ?? '';

    if (userAnswer == correctAnswer) {
      _result = '¡Correcto!';
    } else {
      _result = 'Incorrecto. Inténtalo de nuevo.';
    }
    notifyListeners();
  }
}
