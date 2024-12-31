import 'user.dart';

class Diagnosis {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final bool isPublished;
  final User? creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Diagnosis({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.isPublished,
    this.creator,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Question {
  final String id;
  final String text;
  final List<Choice> choices;
  final int order;

  const Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.order,
  });
}

class Choice {
  final String id;
  final String text;
  final int score;

  const Choice({
    required this.id,
    required this.text,
    required this.score,
  });
}