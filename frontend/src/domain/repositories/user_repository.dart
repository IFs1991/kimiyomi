import '../entities/user.dart';
import '../entities/profile.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<Profile> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, Profile profile);
  Future<void> updateUser(String userId, User user);
  Future<List<User>> searchUsers(String query);
  Future<void> deleteUser(String userId);
}