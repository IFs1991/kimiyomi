import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'content.g.dart';

@JsonSerializable()
class Content extends Equatable {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String contentType;
  final Map<String, dynamic> data;
  final List<String> tags;
  final int viewCount;
  final double rating;
  final bool isPublished;

  const Content({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.contentType,
    required this.data,
    required this.tags,
    required this.viewCount,
    required this.rating,
    required this.isPublished,
  });

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    createdAt,
    updatedAt,
    contentType,
    data,
    tags,
    viewCount,
    rating,
    isPublished,
  ];
}