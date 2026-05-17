import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/profile_widgets.dart';
import '../../core/services/user_service.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _newEmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  String get _currentEmail => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateForm() {
    final email = _newEmailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) return 'Please enter a new email address';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (email == _currentEmail) {
      return 'New email must be different from current email';
    }
    if (password.isEmpty) return 'Please enter your password';
    return null;
  }

  Future<void> _saveChanges() async {
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Email Change'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Change your email to\n'),
              TextSpan(
                text: _newEmailCtrl.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1677FF),
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Color(0xFF1677FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final newEmail = _newEmailCtrl.text.trim();
      final user = FirebaseAuth.instance.currentUser!;

      // reload ก่อนเพื่อให้ได้ email ล่าสุดจาก Firebase Auth (ไม่ใช่ cache)
      await user.reload();
      final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // 1. เช็คว่า email ซ้ำในระบบหรือไม่
      final emailTaken = await UserService.checkEmailExists(newEmail);
      if (emailTaken) {
        if (!mounted) return;
        setState(() => _loading = false);
        _showError('This email is already in use by another account.');
        return;
      }

      // 2. Re-authenticate ก่อนแก้ไข
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: _passwordCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // 3. ให้ backend อัปเดต email ทั้งใน DB และ Firebase Auth (ผ่าน Admin SDK)
      await UserService.updateMyEmail(newEmail);

      // 4. ย้าย Firestore document จาก key เดิม (email เก่า) ไป key ใหม่ (email ใหม่)
      //    พร้อมอัพเดต email field ข้างในด้วย
      final firestore = FirebaseFirestore.instance;
      final oldDoc = await firestore
          .collection('users')
          .doc(currentEmail)
          .get();
      if (oldDoc.exists) {
        final newData = Map<String, dynamic>.from(oldDoc.data()!);
        newData['email'] = newEmail;
        await firestore.collection('users').doc(newEmail).set(newData);
        await firestore.collection('users').doc(currentEmail).delete();
      }

      // 5. Admin SDK revoke session เดิมทันที → sign out แล้ว sign in ด้วย email ใหม่
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: newEmail,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
              SizedBox(width: 10),
              Text('Email Updated'),
            ],
          ),
          content: const Text(
            'Your email address has been updated successfully.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF1677FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Incorrect password. Please try again.';
          break;
        case 'email-already-in-use':
          msg = 'This email is already in use by another account.';
          break;
        case 'invalid-email':
          msg = 'Invalid email address format.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Please try again later.';
          break;
        default:
          msg = e.message ?? 'An error occurred. Please try again.';
      }
      _showError(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Update Email',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Information',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CurrentInfoBox(
              icon: Icons.mail_outline_rounded,
              label: 'Current Email',
              value: _currentEmail,
            ),
            const SizedBox(height: 32),
            const Text(
              'New Email Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _newEmailCtrl,
              hint: 'Enter new email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Text(
              'Current Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _passwordCtrl,
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: _loading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1677FF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
