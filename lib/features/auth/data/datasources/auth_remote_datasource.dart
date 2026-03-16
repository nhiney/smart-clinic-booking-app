import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  /// REGISTER
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user!.updateDisplayName(name);

      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// CURRENT USER
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// ERROR HANDLER
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return "User not found";

      case 'wrong-password':
        return "Wrong password";

      case 'email-already-in-use':
        return "Email already in use";

      case 'weak-password':
        return "Password is too weak";

      case 'invalid-email':
        return "Invalid email";

      default:
        return "Authentication error";
    }
  }
}
