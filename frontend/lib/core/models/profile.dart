import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? bio,
    @Default([]) List<String> interests,
    @Default([]) List<String> favoriteGenres,
    @JsonKey(name: 'reading_speed') double? readingSpeed,
    @JsonKey(name: 'books_read') int? booksRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default(false) bool isPublic,
    Map<String, dynamic>? preferences,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  static Profile empty() => Profile(
        id: '',
        userId: '',
        displayName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}