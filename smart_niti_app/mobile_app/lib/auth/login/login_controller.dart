import 'package:flutter/material.dart';
import 'package:mobile_app/resident/core/resident_main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mobile_app/auth_service.dart';
import 'package:mobile_app/resident/resident_facade.dart';
import 'package:mobile_app/auth/adapters/google_auth_adapter.dart';
import 'package:mobile_app/auth/adapters/facebook_auth_adapter.dart';
import 'package:mobile_app/auth/adapters/email_auth_adapter.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final ResidentFacade _residentFacade = ResidentFacade();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= ตรวจสอบสิทธิ์หลัง Login =================
  Future<void> _checkAdminApproval(BuildContext context, User user) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.email)
          .get();

      if (!context.mounted) return;

      if (!userDoc.exists) {
        await _authService.logout();
        _showErrorDialog(
          context,
          "ไม่พบข้อมูลในระบบ",
          "กรุณาติดต่อนิติบุคคลเพื่อลงทะเบียนเข้าใช้งาน",
        );
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      bool isResident = data['role'] == 'resident';
      bool isActive = data['is_active'] == true;

      if (isResident && isActive) {
        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResidentMainPage()),
        );
      } else {
        await _authService.logout();
        if (!context.mounted) return;

        _showErrorDialog(
          context,
          "เข้าสู่ระบบไม่ได้",
          "บัญชีของคุณยังไม่ได้รับอนุมัติ หรือถูกระงับการใช้งาน",
        );
      }
    } catch (e) {
      await _authService.logout();
      if (!context.mounted) return;

      _showErrorDialog(context, "Error", "เกิดข้อผิดพลาดในการตรวจสอบข้อมูล");
    }
  }

  // ================= GOOGLE =================
  void handleGoogleLogin(BuildContext context) async {
    try {
      User? user = await _residentFacade.login(GoogleAuthAdapter());

      if (user != null) {
        if (!context.mounted) return;
        await _checkAdminApproval(context, user);
      }
    } catch (e) {
      if (!context.mounted) return;

      _showErrorDialog(context, "เข้าสู่ระบบไม่ได้", e.toString());
    }
  }

  // ================= FACEBOOK =================
  void handleFacebookLogin(BuildContext context) async {
    try {
      User? user = await _residentFacade.login(FacebookAuthAdapter());

      if (user != null) {
        if (!context.mounted) return;
        await _checkAdminApproval(context, user);
      }
    } catch (e) {
      if (!context.mounted) return;

      _showErrorDialog(context, "เข้าสู่ระบบไม่ได้", e.toString());
    }
  }

  // ================= EMAIL =================
  void handleEmailLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      User? user = await _residentFacade.login(
        EmailAuthAdapter(email: email, password: password),
      );

      if (user != null) {
        if (!context.mounted) return;
        await _checkAdminApproval(context, user);
      }
    } catch (e) {
      if (!context.mounted) return;

      _showErrorDialog(context, "Login Failed", "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
    }
  }

  // ================= ERROR DIALOG =================
  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }
}
