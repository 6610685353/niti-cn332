import 'package:firebase_auth/firebase_auth.dart';
import '../auth/adapters/auth_adapter.dart';

class ResidentFacade {
  Future<User?> login(AuthAdapter adapter) => adapter.login();
  Future<void> logout(AuthAdapter adapter) => adapter.logout();
}
