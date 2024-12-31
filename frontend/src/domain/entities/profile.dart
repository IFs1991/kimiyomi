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

  const Profile({
    required this.userId,
    required this.nickname,
    this.bio,
    required this.age,
    required this.gender,
    required this.interests,
    required this.birthDate,
    this.user,
  });
}