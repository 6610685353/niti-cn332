import 'package:flutter/material.dart';
import 'package:mobile_app/resident/core/resident_main_page.dart';

class LoginController {
  final BuildContext context;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginController(this.context);

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == 'username' && password == 'password') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResidentMainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username/email or password!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
