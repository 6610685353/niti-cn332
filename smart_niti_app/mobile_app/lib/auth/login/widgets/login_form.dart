import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Secure Login',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please enter your login credentials to access the portal.',
          style: TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(97, 117, 137, 1),
          ),
        ),
        const SizedBox(height: 32),

        const Text('Username/Email'),
        const SizedBox(height: 8),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter your username or email',
          ),
        ),

        const SizedBox(height: 24),

        const Text('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter your password',
          ),
        ),
      ],
    );
  }
}
