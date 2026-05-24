import 'package:flutter/material.dart';
import 'package:mobile_app/resident/core/resident_main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobile_app/resident/resident_facade.dart';
import 'package:mobile_app/auth/adapters/google_auth_adapter.dart';
import 'package:mobile_app/auth/adapters/facebook_auth_adapter.dart';
import 'package:mobile_app/auth/adapters/email_auth_adapter.dart';

class LoginController {
  final ResidentFacade _residentFacade = ResidentFacade();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ResidentMainPage()),
    );
  }

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

  // ================= GOOGLE =================
  void handleGoogleLogin(BuildContext context) async {
    try {
      User? user = await _residentFacade.login(GoogleAuthAdapter());
      if (user != null && context.mounted) _navigateToHome(context);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(context, "เข้าสู่ระบบไม่ได้", e.toString());
    }
  }

  // ================= FACEBOOK =================
  void handleFacebookLogin(BuildContext context) async {
    try {
      User? user = await _residentFacade.login(FacebookAuthAdapter());
      if (user != null && context.mounted) _navigateToHome(context);
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
      if (user != null && context.mounted) _navigateToHome(context);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(context, "Login Failed", "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
    }
  }

  // ================= FORGOT PASSWORD =================
  void handleForgotPassword(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("รีเซ็ตรหัสผ่าน"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ใส่อีเมลที่ลงทะเบียนไว้ ระบบจะส่งลิงก์รีเซ็ตรหัสผ่านให้",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "อีเมล",
                hintText: "example@email.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF137FEC),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.of(ctx).pop();
              await _sendResetEmail(context, email);
            },
            child: const Text("ส่งอีเมล"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      _showErrorDialog(context, "ข้อผิดพลาด", "กรุณาใส่อีเมล");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("ส่งอีเมลแล้ว"),
            ],
          ),
          content: Text(
            "ระบบส่งลิงก์รีเซ็ตรหัสผ่านไปที่\n$email\nแล้ว กรุณาตรวจสอบอีเมล",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("ตกลง"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final message = switch (e.code) {
        'user-not-found' => "ไม่พบอีเมลนี้ในระบบ",
        'invalid-email' => "รูปแบบอีเมลไม่ถูกต้อง",
        _ => "เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง",
      };
      _showErrorDialog(context, "ส่งอีเมลไม่ได้", message);
    }
  }
}
