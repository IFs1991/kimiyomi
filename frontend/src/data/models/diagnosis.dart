import '../../domain/entities/diagnosis.dart' as entities;
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

  Diagnosis({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.isPublished,
    this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublished: json['is_published'] as bool,
      creator: json['creator'] != null
          ? User.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
      'is_published': isPublished,
      'creator': creator?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  entities.Diagnosis toEntity() {
    return entities.Diagnosis(
      id: id,
      title: title,
      description: description,
      questions: questions.map((q) => q.toEntity()).toList(),
      isPublished: isPublished,
      creator: creator?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Diagnosis.fromEntity(entities.Diagnosis entity) {
    return Diagnosis(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      questions: entity.questions.map((q) => Question.fromEntity(q)).toList(),
      isPublished: entity.isPublished,
      creator: entity.creator != null ? User.fromEntity(entity.creator!) : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<Choice> choices;
  final int order;

  Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.order,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'choices': choices.map((e) => e.toJson()).toList(),
      'order': order,
    };
  }

  entities.Question toEntity() {
    return entities.Question(
      id: id,
      text: text,
      choices: choices.map((c) => c.toEntity()).toList(),
      order: order,
    );
  }

  factory Question.fromEntity(entities.Question entity) {
    return Question(
      id: entity.id,
      text: entity.text,
      choices: entity.choices.map((c) => Choice.fromEntity(c)).toList(),
      order: entity.order,
    );
  }
}

class Choice {
  final String id;
  final String text;
  final int score;

  Choice({
    required this.id,
    required this.text,
    required this.score,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as String,
      text: json['text'] as String,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'score': score,
    };
  }

  entities.Choice toEntity() {
    return entities.Choice(
      id: id,
      text: text,
      score: score,
    );
  }

  factory Choice.fromEntity(entities.Choice entity) {
    return Choice(
      id: entity.id,
      text: entity.text,
      score: entity.score,
    );
  }
}