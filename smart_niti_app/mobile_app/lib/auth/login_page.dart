import 'package:flutter/material.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == 'username' && password == 'password') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid username/email or password!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(26, 15, 102, 189),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      IconData(0xe089, fontFamily: 'MaterialIcons'),
                      size: 40,
                      color: Color.fromARGB(255, 15, 102, 189),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    'Smart Niti',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),

                const SizedBox(height: 8),

                const Text('Residential Management'),

                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(onPressed: login, child: const Text('Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
