import '../../domain/entities/profile.dart' as entities;
import 'user.dart';

class Profile {
  final String userId;
  final String nickname;
  final String? bio;
  final int age;
  final String gender;
  final List<String> interests;
  final DateTime birthDate;
  final User? user;

  Profile({
    required this.userId,
    required this.nickname,
    this.bio,
    required this.age,
    required this.gender,
    required this.interests,
    required this.birthDate,
    this.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      bio: json['bio'] as String?,
      age: json['age'] as int,
      gender: json['gender'] as String,
      interests: (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      birthDate: DateTime.parse(json['birth_date'] as String),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'bio': bio,
      'age': age,
      'gender': gender,
      'interests': interests,
      'birth_date': birthDate.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  entities.Profile toEntity() {
    return entities.Profile(
      userId: userId,
      nickname: nickname,
      bio: bio,
      age: age,
      gender: gender,
      interests: interests,
      birthDate: birthDate,
      user: user?.toEntity(),
    );
  }

  factory Profile.fromEntity(entities.Profile entity) {
    return Profile(
      userId: entity.userId,
      nickname: entity.nickname,
      bio: entity.bio,
      age: entity.age,
      gender: entity.gender,
      interests: entity.interests,
      birthDate: entity.birthDate,
      user: entity.user != null ? User.fromEntity(entity.user!) : null,
    );
  }
}