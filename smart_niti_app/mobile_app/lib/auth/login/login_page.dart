// import 'package:flutter/material.dart';
// import 'login_controller.dart';
// import 'widgets/login_header.dart';
// import 'widgets/login_form.dart';
// import 'widgets/login_button.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   late LoginController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = LoginController(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 360),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const LoginHeader(),
//                 const SizedBox(height: 32),

//                 LoginForm(
//                   usernameController: controller.usernameController,
//                   passwordController: controller.passwordController,
//                 ),

//                 const SizedBox(height: 40),

//                 LoginButton(onPressed: controller.login),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'login_controller.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final LoginController _controller = LoginController();
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _passCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               "Smart Niti",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//             ),
//             const SizedBox(height: 40),

//             // Email Input
//             TextField(
//               controller: _emailCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Password Input
//             TextField(
//               controller: _passCtrl,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Login Button (Email)
//             ElevatedButton(
//               onPressed: () => _controller.handleEmailLogin(
//                 context,
//                 _emailCtrl.text,
//                 _passCtrl.text,
//               ),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text("เข้าสู่ระบบ"),
//             ),

//             const SizedBox(height: 24),
//             const Text(
//               "หรือเข้าสู่ระบบด้วย",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 16),

//             // Social Buttons Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _socialButton(
//                   label: "Google",
//                   color: Colors.red,
//                   icon: Icons.g_mobiledata,
//                   onPressed: () => _controller.handleGoogleLogin(context),
//                 ),
//                 _socialButton(
//                   label: "Facebook",
//                   color: Colors.blue.shade900,
//                   icon: Icons.facebook,
//                   onPressed: () => _controller.handleFacebookLogin(context),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _socialButton({
//     required String label,
//     required Color color,
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, color: Colors.white),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//       ),
//     );
//   }
// }

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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = LoginController();
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
                      ),

                      const SizedBox(height: 24),

                      /// ===== LOGIN BUTTON =====
                      LoginButton(
                        onPressed: () {
                          controller.handleEmailLogin(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                      ),

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
