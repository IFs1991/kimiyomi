import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/diagnosis_provider.dart';
import '../../../domain/entities/diagnosis.dart';

class DiagnosisEditScreen extends ConsumerStatefulWidget {
  final Diagnosis? diagnosis;

  const DiagnosisEditScreen({
    Key? key,
    this.diagnosis,
  }) : super(key: key);

  @override
  ConsumerState<DiagnosisEditScreen> createState() => _DiagnosisEditScreenState();
}

class _DiagnosisEditScreenState extends ConsumerState<DiagnosisEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<QuestionFormField> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.diagnosis != null) {
      _titleController.text = widget.diagnosis!.title;
      _descriptionController.text = widget.diagnosis!.description;
      _questions.addAll(
        widget.diagnosis!.questions.map(
          (q) => QuestionFormField(
            initialQuestion: q,
            onRemove: () => _removeQuestion(q),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionFormField(
          onRemove: () => _removeQuestion(null),
        ),
      );
    });
  }

  void _removeQuestion(Question? question) {
    setState(() {
      if (question != null) {
        _questions.removeWhere((q) => q.initialQuestion?.id == question.id);
      } else {
        _questions.removeLast();
      }
    });
  }

  Future<void> _saveDiagnosis() async {
    if (!_formKey.currentState!.validate()) return;

    final questions = _questions
        .map((q) => Question(
              id: q.initialQuestion?.id ?? '',
              text: q.textController.text,
              choices: q.choices
                  .map((c) => Choice(
                        id: c.initialChoice?.id ?? '',
                        text: c.textController.text,
                        score: int.parse(c.scoreController.text),
                      ))
                  .toList(),
              order: _questions.indexOf(q),
            ))
        .toList();

    final diagnosis = Diagnosis(
      id: widget.diagnosis?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      questions: questions,
      isPublished: widget.diagnosis?.isPublished ?? false,
      creator: widget.diagnosis?.creator,
      createdAt: widget.diagnosis?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.diagnosis != null) {
        await ref
            .read(selectedDiagnosisProvider.notifier)
            .updateDiagnosis(diagnosis.id, diagnosis);
      } else {
        await ref.read(diagnosisListProvider.notifier).createDiagnosis(diagnosis);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diagnosis != null ? '診断を編集' : '新しい診断を作成'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDiagnosis,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '説明を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              '質問',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._questions,
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('質問を追加'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionFormField extends StatefulWidget {
  final Question? initialQuestion;
  final VoidCallback onRemove;

  const QuestionFormField({
    Key? key,
    this.initialQuestion,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<QuestionFormField> createState() => _QuestionFormFieldState();
}

class _QuestionFormFieldState extends State<QuestionFormField> {
  final textController = TextEditingController();
  final List<ChoiceFormField> choices = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null) {
      textController.text = widget.initialQuestion!.text;
      choices.addAll(
        widget.initialQuestion!.choices.map(
          (c) => ChoiceFormField(
            initialChoice: c,
            onRemove: () => _removeChoice(c),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _addChoice() {
    setState(() {
      choices.add(
        ChoiceFormField(
          onRemove: () => _removeChoice(null),
        ),
      );
    });
  }

  void _removeChoice(Choice? choice) {
    setState(() {
      if (choice != null) {
        choices.removeWhere((c) => c.initialChoice?.id == choice.id);
      } else {
        choices.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: '質問文',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '質問文を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '選択肢',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...choices,
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addChoice,
              icon: const Icon(Icons.add),
              label: const Text('選択肢を追加'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChoiceFormField extends StatefulWidget {
  final Choice? initialChoice;
  final VoidCallback onRemove;

  const ChoiceFormField({
    Key? key,
    this.initialChoice,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<ChoiceFormField> createState() => _ChoiceFormFieldState();
}

class _ChoiceFormFieldState extends State<ChoiceFormField> {
  final textController = TextEditingController();
  final scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialChoice != null) {
      textController.text = widget.initialChoice!.text;
      scoreController.text = widget.initialChoice!.score.toString();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '選択肢',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '選択肢を入力してください';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: scoreController,
              decoration: const InputDecoration(
                labelText: 'スコア',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '必須';
                }
                if (int.tryParse(value) == null) {
                  return '数値';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onRemove,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}