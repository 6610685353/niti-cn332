import 'package:firebase_auth/firebase_auth.dart';
import '../auth/adapters/auth_adapter.dart';

class TechnicianFacade {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(AuthAdapter adapter) => adapter.login();
  Future<void> logout() => _auth.signOut();
}
