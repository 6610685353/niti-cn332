import 'package:flutter/material.dart';
import '../widgets/profile_widgets.dart';

class UpdateEmailScreen extends StatelessWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Update email",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Current Information",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CurrentInfoBox(
              icon: Icons.email_outlined,
              label: "Current Email",
              value: "alex.johnson@example.com",
            ),

            const SizedBox(height: 32),
            const Text(
              "New Email Address",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInputField(
              "alex.johnson@newmail.com",
              Icons.check_circle,
              Colors.green,
            ),

            const SizedBox(height: 24),
            const Text(
              "Password",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInputField(
              "XXXXXXXXXXXXXXX",
              Icons.check_circle,
              Colors.green,
              isPassword: true,
            ),

            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                "Save Changes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    IconData suffixIcon,
    Color iconColor, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(suffixIcon, color: iconColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
