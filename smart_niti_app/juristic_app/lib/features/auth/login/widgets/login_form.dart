import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/features/auth/login/controllers/login_controller.dart';
import 'package:juristic_app/features/auth/login/widgets/login_text_field.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller;

  const LoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ใช้ ListenableBuilder หรือ AnimatedBuilder เพื่ออัปเดต UI เฉพาะส่วนนี้เมื่อ State เปลี่ยน
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Username Field
            LoginTextField(
              label: 'Username',
              hintText: 'e.g. admin@example.com',
              controller: controller.identifierController,
            ),
            const SizedBox(height: 20),

            // 2. Password Field & Forgot Password
            LoginTextField(
              label: 'Password',
              hintText: '••••••••',
              controller: controller.passwordController,
              obscureText: controller.obscurePassword,
              topRightWidget: TextButton(
                onPressed: () {
                  // TODO: นำทางไปหน้าลืมรหัสผ่าน
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 32),

            // 3. Login Button
            ElevatedButton(
              onPressed: controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
