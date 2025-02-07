// lib/main.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'create_page.dart';
import 'question_model.dart';

void main() async {
  await dotenv.load(fileName: "../.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuestionModel()..loadQuestions(),
      child: MaterialApp(
        title: 'Preguntas y Respuestas',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black87,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 10,
            shadowColor: Colors.black45,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  String _selectedQuestion = '';
  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Sustantivos',
    'Adjetivos',
    'Verbos',
    'Conjugaciones',
    'Preposiciones',
    'Adverbios'
  ];
  final List<String> _recentQuestions = [];

  void _selectRandomQuestion(QuestionModel model) {
    final filteredQuestions = _selectedCategory == 'Todos'
        ? model.questions
        : model.questions
            .where((question) => question['category'] == _selectedCategory)
            .toList();

    if (filteredQuestions.isEmpty) {
      setState(() {
        _selectedQuestion = 'No hay preguntas en esta categoría';
      });
      return;
    }

    final availableQuestions = filteredQuestions
        .where((question) => !_recentQuestions.contains(question['question']))
        .toList();

    if (availableQuestions.isEmpty) {
      _recentQuestions.clear();
      _selectRandomQuestion(model);
      return;
    }

    final random = Random();
    final randomQuestion =
        availableQuestions[random.nextInt(availableQuestions.length)]
            ['question'];

    setState(() {
      _selectedQuestion = randomQuestion;
      _recentQuestions.add(randomQuestion);

      if (_recentQuestions.length > 3) {
        _recentQuestions.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregunta y Respuesta Futurista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<QuestionModel>(
          builder: (context, model, child) {
            if (model.error.isNotEmpty) {
              return Center(
                child: Text(
                  model.error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (model.questions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: <Widget>[
                // Modo Estudio / Revisión
                const SizedBox(height: 16.0),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: const TextStyle(color: Colors.cyanAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                      _selectRandomQuestion(model);
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                // Flashcard - Pregunta
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    key: ValueKey<String>(_selectedQuestion),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _selectedQuestion.isEmpty
                            ? 'Selecciona una categoría'
                            : _selectedQuestion,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Respuesta
                TextField(
                  controller: _answerController,
                  focusNode: _answerFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Respuesta',
                    labelStyle: const TextStyle(color: Colors.greenAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.greenAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.greenAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onSubmitted: (value) {
                    bool isCorrect =
                        model.compareAnswer(_selectedQuestion, value);
                    if (isCorrect) {
                      _answerController.clear();
                      _selectRandomQuestion(model);
                    }
                    _answerFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: 16.0),

                // Botón Comprobar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    bool isCorrect = model.compareAnswer(
                        _selectedQuestion, _answerController.text);
                    if (isCorrect) {
                      _answerController.clear();
                      _selectRandomQuestion(model);
                    }
                    _answerFocusNode.requestFocus();
                  },
                  child: const Text('Comprobar',
                      style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 16.0),

                // Resultado
                Text(
                  model.result,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
