import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthAdapter {
  Future<User?> login();
  Future<void> logout();
}
