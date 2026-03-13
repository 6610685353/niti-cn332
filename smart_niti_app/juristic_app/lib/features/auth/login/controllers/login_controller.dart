import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void login() {
    // TODO: ใส่ Logic การตรวจสอบข้อมูล (Validation) และการเรียก API ที่นี่
    debugPrint("Login with: ${identifierController.text}");
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
