// lib/auth/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;

  static const _kRememberMeKey = 'remember_me';
  static const _kSavedEmailKey = 'saved_email';
  static const _kSavedPasswordKey = 'saved_password';

  @override
  void initState() {
    super.initState();
    controller = LoginController();
    _loadRememberedCredentials();
  }

  /// โหลด email/password ที่บันทึกไว้จาก SharedPreferences
  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool(_kRememberMeKey) ?? false;
    if (remembered) {
      final savedEmail = prefs.getString(_kSavedEmailKey) ?? '';
      final savedPassword = prefs.getString(_kSavedPasswordKey) ?? '';
      if (mounted) {
        setState(() {
          _rememberMe = true;
          emailController.text = savedEmail;
          passwordController.text = savedPassword;
        });
      }
    }
  }

  /// บันทึกหรือลบ credentials ตาม flag
  Future<void> _saveRememberedCredentials({required bool remember}) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool(_kRememberMeKey, true);
      await prefs.setString(_kSavedEmailKey, emailController.text.trim());
      await prefs.setString(_kSavedPasswordKey, passwordController.text.trim());
    } else {
      await prefs.setBool(_kRememberMeKey, false);
      await prefs.remove(_kSavedEmailKey);
      await prefs.remove(_kSavedPasswordKey);
    }
  }

  void _handleLogin() async {
    await _saveRememberedCredentials(remember: _rememberMe);
    if (!mounted) return;
    controller.handleEmailLogin(
      context,
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 24),

                      /// ===== LOGIN FORM =====
                      LoginForm(
                        usernameController: emailController,
                        passwordController: passwordController,
                        rememberMe: _rememberMe,
                        onRememberMeChanged: (val) =>
                            setState(() => _rememberMe = val),
                        onForgotPassword: () =>
                            controller.handleForgotPassword(context),
                      ),

                      const SizedBox(height: 24),

                      /// ===== LOGIN BUTTON =====
                      LoginButton(onPressed: _handleLogin),

                      const SizedBox(height: 20),

                      const Text(
                        "Or sign in with",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),

                      const SizedBox(height: 16),

                      /// ===== GOOGLE =====
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            side: const BorderSide(color: Color(0xFFE6E6E6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            controller.handleGoogleLogin(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/google_logo.png", height: 22),
                              const SizedBox(width: 12),
                              const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ===== FACEBOOK =====
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            controller.handleFacebookLogin(context);
                          },
                          icon: const Icon(Icons.facebook),
                          label: const Text(
                            "Sign in with Facebook",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
