// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'question_model.dart';
import 'create_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuestionModel(),
      child: MaterialApp(
        title: 'Flutter Dark Theme Demo',
        theme: ThemeData.dark(),
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
  String _selectedQuestion = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregunta y Respuesta'),
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
        child: Column(
          children: <Widget>[
            Consumer<QuestionModel>(
              builder: (context, model, child) {
                return DropdownButton<String>(
                  value: _selectedQuestion.isEmpty && model.questions.isNotEmpty
                      ? model.questions.first['question']
                      : _selectedQuestion,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedQuestion = newValue!;
                    });
                  },
                  items: model.questions.map<DropdownMenuItem<String>>((question) {
                    return DropdownMenuItem<String>(
                      value: question['question'],
                      child: Text(question['question']!),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Respuesta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Provider.of<QuestionModel>(context, listen: false)
                    .compareAnswer(_selectedQuestion, _answerController.text);
              },
              child: const Text('Comprobar'),
            ),
            const SizedBox(height: 16.0),
            Consumer<QuestionModel>(
              builder: (context, model, child) {
                return Text(model.result);
              },
            ),
          ],
        ),
      ),
    );
  }
}