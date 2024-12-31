import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<User> signInWithEmailAndPassword(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<User> signUpWithEmailAndPassword(String email, String password) {
    return _authRepository.signUpWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }

  Future<User?> getCurrentUser() {
    return _authRepository.getCurrentUser();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> updatePassword(String newPassword) {
    return _authRepository.updatePassword(newPassword);
  }

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;
}