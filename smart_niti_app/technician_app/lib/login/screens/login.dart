import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../../../core/widgets/navbar.dart';
import '../../core/constants/app_color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TechnicianFacade _technicianFacade = TechnicianFacade();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleLogin() async {
    final email = _staffIdController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('กรุณากรอก Staff ID และรหัสผ่าน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _technicianFacade.login(
        EmailAuthAdapter(email: email, password: password),
      );

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.email)
            .get();

        if (!userDoc.exists) {
          await _technicianFacade.logout();
          _showError('ไม่พบข้อมูลผู้ใช้ในระบบ');
          return;
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['role'] == 'technician') {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavWrapper()),
            (route) => false,
          );
        } else {
          await _technicianFacade.logout();
          _showError('คุณไม่มีสิทธิ์เข้าถึงระบบช่างซ่อม');
        }
      }
    } catch (e) {
      _showError('เข้าสู่ระบบไม่ได้: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),

                          // --- Minimalist Logo Section ---
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.construction_rounded,
                                    size: 42,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'SMART NITI',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const Text(
                                  'TECHNICIAN PORTAL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          // --- Modern Login Header ---
                          const Text(
                            'Technician Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your credentials to access your workspace.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 35),

                          // --- Input Fields ---
                          CustomInputField(
                            label: 'Email',
                            hint: 'e.g. technician@example.com',
                            icon: Icons.badge_outlined,
                            controller: _staffIdController,
                          ),
                          const SizedBox(height: 20),

                          CustomInputField(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _passwordController,
                          ),

                          const SizedBox(height: 12),

                          // --- Options ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      activeColor: AppColors.primary,
                                      onChanged: (val) =>
                                          setState(() => _rememberMe = val!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // --- Primary Button ---
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainNavWrapper(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      // --- Footer ---
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          '© 2026 Smart Niti Systems v1.0',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
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
