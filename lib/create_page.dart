import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'question_model.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final List<String> _answers = [];
  String _selectedCategory = 'Sustantivos';
  final List<String> _categories = [
    'Sustantivos',
    'Adjetivos',
    'Verbos',
    'Conjugaciones',
    'Preposiciones',
    'Adverbios'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Nueva Pregunta'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
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
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Pregunta',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _answerController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Respuesta',
                labelStyle: const TextStyle(color: Colors.greenAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.greenAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.greenAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                if (_answerController.text.trim().isNotEmpty) {
                  setState(() {
                    _answers.add(_answerController.text.trim());
                    _answerController.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('⚠️ La respuesta no puede estar vacía')),
                  );
                }
              },
              child: const Text('➕ Añadir Respuesta',
                  style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                final questionText = _questionController.text.trim();
                final answerText = _answerController.text.trim();

                if (questionText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ La pregunta no puede estar vacía')),
                  );
                  return;
                }

                if (answerText.isNotEmpty) {
                  _answers.add(answerText);
                }

                if (_answers.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Debes añadir al menos una respuesta')),
                  );
                  return;
                }

                Provider.of<QuestionModel>(context, listen: false)
                    .addQuestion(questionText, _answers, _selectedCategory);

                // Clear the input fields and show a confirmation message
                _questionController.clear();
                _answerController.clear();
                _answers.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Pregunta guardada correctamente')),
                );
              },
              child: const Text('💾 Guardar Pregunta', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: _answers
                  .map((answer) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.cyanAccent),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: ListTile(
                          title: Text(answer,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
