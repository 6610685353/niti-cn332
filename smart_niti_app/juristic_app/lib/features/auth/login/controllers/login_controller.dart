import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juristic_app/features/dashboard/views/dashboard_page.dart';
import 'package:juristic_app/features/home/view/home_page.dart';
import 'package:juristic_app/features/juristic/juristic_facade.dart';
import 'package:juristic_app/features/auth/adapters/email_auth_adapter.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final JuristicFacade _juristicFacade = JuristicFacade();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login() async {
    final email = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "กรุณากรอกอีเมลและรหัสผ่าน");
      return;
    }

    try {
      User? user = await _juristicFacade.login(
        EmailAuthAdapter(email: email, password: password),
      );

      if (user != null) {
        // ตรวจสอบบทบาทใน Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.email)
            .get();

        if (!userDoc.exists) {
          await _juristicFacade.logout();
          Get.snackbar("Error", "ไม่พบข้อมูลผู้ใช้ในระบบ");
          return;
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['role'] == 'juristic' || data['role'] == 'admin') {
          Get.offAll(() => HomePage());
        } else {
          await _juristicFacade.logout();
          Get.snackbar("Error", "คุณไม่มีสิทธิ์เข้าถึงระบบนิติบุคคล");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "เข้าสู่ระบบไม่ได้: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
