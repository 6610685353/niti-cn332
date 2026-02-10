import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true; // 👁 state เปิด–ปิดรหัส
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Secure Login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        const Text(
          'Please enter your login credentials to access the portal.',
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(97, 117, 137, 1),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // ================= USERNAME =================
        const Text(
          'Username/Email',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(219, 224, 230, 1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: Color.fromRGBO(97, 117, 137, 1),
                  size: 24,
                ),
              ),

              Container(
                width: 1,
                height: 56,
                color: Color.fromRGBO(219, 224, 230, 1),
              ),

              Expanded(
                child: TextField(
                  controller: widget.usernameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your username or email',
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(97, 117, 137, 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ================= PASSWORD =================
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),

        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(219, 224, 230, 1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock,
                  color: Color.fromRGBO(97, 117, 137, 1),
                  size: 24,
                ),
              ),

              Container(
                width: 1,
                height: 56,
                color: Color.fromRGBO(219, 224, 230, 1),
              ),

              Expanded(
                child: TextField(
                  controller: widget.passwordController,
                  obscureText: obscurePassword,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(97, 117, 137, 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 56,
                color: Color.fromRGBO(219, 224, 230, 1),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color.fromRGBO(97, 117, 137, 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),

                const Text(
                  'Remember Me',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forgot Password Clicked')),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(15, 102, 189, 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
