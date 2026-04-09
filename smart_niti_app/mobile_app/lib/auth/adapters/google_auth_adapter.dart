import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_adapter.dart';

class GoogleAuthAdapter implements AuthAdapter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  Future<User?> login() async {
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final providers = currentUser.providerData
            .map((e) => e.providerId)
            .toList();

        if (providers.contains('google.com')) {
          return (await _auth.signInWithCredential(credential)).user;
        }

        return (await currentUser.linkWithCredential(credential)).user;
      }

      return (await _auth.signInWithCredential(credential)).user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return (await _auth.signInWithCredential(credential)).user;
      }

      throw Exception(e.message ?? "Google login failed");
    }
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }
}
