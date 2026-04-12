import 'package:flutter/material.dart';
import './../repair_history/repair_history_page.dart'; // ตรวจสอบ path อีกครั้งให้ถูกต้อง

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildPersonalDetails(),
            const SizedBox(height: 25),
            // ส่ง context เข้าไปเพื่อให้ Navigator ทำงานได้
            _buildActivityHistory(context),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. ส่วนหัว (Avatar, Name, Badges) ---
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const Text(
          "My Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            CircleAvatar(radius: 60, backgroundColor: Colors.grey.shade300),
            Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF137FEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          "Alex Johnson",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(
              "Unit 402B",
              const Color(0xFFDBEAFE),
              const Color(0xFF137FEC),
            ),
            const SizedBox(width: 8),
            _buildBadge(
              "Verified",
              const Color(0xFFFEE2E2),
              const Color(0xFFEF4444),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          "Member since January 2023",
          style: TextStyle(color: Color(0xFF4C739A), fontSize: 14),
        ),
      ],
    );
  }

  // --- 2. ส่วน Personal Details ---
  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Personal Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildListTile(Icons.email, "Email", "alex.johnson@example.com"),
              const Divider(height: 1, indent: 70),
              _buildListTile(
                Icons.phone_android,
                "Phone Number",
                "(+555) 01-234-5678",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. ส่วน Activity History ---
  Widget _buildActivityHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Activity History",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.build_outlined,
          "Repairs History",
          "2 active maintenance requests",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RepairHistoryPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.calendar_today_outlined,
          "Booking History",
          "Meeting room reservation",
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.account_balance_wallet_outlined,
          "Payment History",
          "View all rent & utility receipts",
        ),
      ],
    );
  }

  // --- 4. ปุ่ม Logout ---
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
        label: const Text(
          "Logout",
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFFEE2E2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4C739A),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: Color(0xFFCBD5E1),
      ),
    );
  }

  // แก้ไข: เพิ่ม parameter onTap และใช้ InkWell เพื่อให้กดได้
  Widget _buildHistoryCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
        // เพิ่ม Material เพื่อให้ InkWell แสดงผลได้สวยงาม
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF137FEC), size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4C739A)),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: const Color(0xFFF1F5F9)),
    );
  }
}
