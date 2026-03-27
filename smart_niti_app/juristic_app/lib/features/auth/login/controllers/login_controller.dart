import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juristic_app/features/dashboard/views/dashboard_page.dart';
import 'package:juristic_app/features/home/view/home_page.dart';

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
    Get.off(() => HomePage());
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
