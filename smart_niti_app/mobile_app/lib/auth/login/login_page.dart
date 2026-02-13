import 'package:flutter/material.dart';
import 'login_controller.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoginHeader(),
                const SizedBox(height: 32),

                LoginForm(
                  usernameController: controller.usernameController,
                  passwordController: controller.passwordController,
                ),

                const SizedBox(height: 40),

                LoginButton(onPressed: controller.login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
