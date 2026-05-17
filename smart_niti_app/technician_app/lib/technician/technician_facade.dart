import 'package:firebase_auth/firebase_auth.dart';
import '../auth/adapters/auth_adapter.dart';

class TechnicianFacade {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(AuthAdapter adapter) => adapter.login();
  Future<void> logout() => _auth.signOut();

  /// ดึง Firebase ID Token สำหรับส่ง Authorization header ไปยัง backend
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
}
