import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_adapter.dart';

class FacebookAuthAdapter implements AuthAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<User?> login() async {
    final result = await FacebookAuth.instance.login(permissions: ['email']);

    if (result.status != LoginStatus.success) {
      if (result.status == LoginStatus.cancelled) return null;
      throw Exception("Facebook login failed: ${result.message}");
    }

    final AuthCredential credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userCredential = await currentUser.linkWithCredential(credential);
        return userCredential.user;
      } else {
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        throw Exception("Facebook ถูกเชื่อมบัญชีนี้อยู่แล้ว");
      }
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          "บัญชีนี้ลงทะเบียนด้วย Email/Password กรุณาเข้าสู่ระบบแบบปกติ",
        );
      }
      throw Exception(e.message ?? "Facebook login failed");
    }
  }

  @override
  Future<void> logout() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
