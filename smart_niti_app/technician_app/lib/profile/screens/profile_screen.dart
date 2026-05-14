import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/profile_widgets.dart';
import './update_email_screen.dart';
import './update_phone_screen.dart';
import '../../work_order/screens/repair_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "My Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 30),

            // Avatar Section
            Stack(
              children: [
                CircleAvatar(radius: 60, backgroundColor: Colors.grey.shade300),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1677FF),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              mockUser.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge(
                  mockUser.unit,
                  const Color(0xFFE6F4FF),
                  const Color(0xFF1677FF),
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  "Verified",
                  const Color(0xFFFFF1F0),
                  const Color(0xFFFF4D4F),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mockUser.joinDate,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

            const SizedBox(height: 30),
            _buildSection("Personal Details", [
              ProfileInfoTile(
                icon: Icons.email_outlined,
                iconBgColor: Colors.blue,
                title: "Email",
                value: mockUser.email,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdateEmailScreen()),
                ),
              ),
              ProfileInfoTile(
                icon: Icons.phone_android_outlined,
                iconBgColor: Colors.blue,
                title: "Phone Number",
                value: mockUser.phone,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdatePhoneScreen()),
                ),
              ),
            ]),

            _buildSection("Activity History", [
              ProfileInfoTile(
                icon: Icons.build_outlined,
                iconBgColor: Colors.blue,
                title: "Repairs History",
                value: "2 active maintenance requests",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RepairHistoryScreen(initialTab: 'All'),
                    ),
                  );
                },
              ),
            ]),

            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
