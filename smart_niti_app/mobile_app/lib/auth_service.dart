import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ================= EMAIL LOGIN =================

  Future<User?> loginWithEmail(String email, String password) async {
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

  // ================= GOOGLE LOGIN =================

  Future<User?> loginWithGoogle() async {
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final providers = currentUser.providerData
            .map((e) => e.providerId)
            .toList();

        // 🔥 ถ้าเคย link แล้ว → sign in แทน
        if (providers.contains('google.com')) {
          return (await _auth.signInWithCredential(credential)).user;
        }

        // ยังไม่เคย link → link
        return (await currentUser.linkWithCredential(credential)).user;
      }

      // ยังไม่มี user login
      return (await _auth.signInWithCredential(credential)).user;
    } on FirebaseAuthException catch (e) {
      // 🔥 ถ้า provider ถูก link แล้ว ให้ sign in แทน
      if (e.code == 'provider-already-linked') {
        return (await _auth.signInWithCredential(credential)).user;
      }

      throw Exception(e.message ?? "Google login failed");
    }
  }

  // ================= FACEBOOK LOGIN =================

  Future<User?> loginWithFacebook() async {
    final result = await FacebookAuth.instance.login(permissions: ['email']);

    if (result.status != LoginStatus.success) {
      throw Exception("Facebook login failed");
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        // 🔥 ถ้า login email อยู่ → link account
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

  // ================= LOGOUT =================

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
  }
}
