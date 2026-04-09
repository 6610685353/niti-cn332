import 'package:firebase_auth/firebase_auth.dart';
import 'auth_adapter.dart';

class EmailAuthAdapter implements AuthAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String email;
  final String password;

  EmailAuthAdapter({required this.email, required this.password});

  @override
  Future<User?> login() async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Email login failed");
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
