// lib/resident/features/profile/profile_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../repair_history/repair_history_page.dart';
import '../../core/app_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  // Firebase Auth user
  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = _firebaseUser?.uid;
      if (uid == null) {
        setState(() {
          _error = 'ไม่พบข้อมูล User';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/users/$uid'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'โหลดข้อมูลไม่สำเร็จ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // ถ้า offline ให้แสดงข้อมูลจาก Firebase แทน
        _isLoading = false;
      });
    }
  }

  String get _displayName {
    if (_userData != null) {
      final fn = _userData!['first_name'] ?? '';
      final ln = _userData!['last_name'] ?? '';
      return '$fn $ln'.trim();
    }
    return _firebaseUser?.displayName ?? 'User';
  }

  String get _email =>
      _firebaseUser?.email ?? _userData?['email'] ?? 'ไม่มีข้อมูล';

  String get _memberSince {
    final createdAt = _userData?['created_at'];
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ออกจากระบบ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF137FEC)),
            )
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              color: const Color(0xFF137FEC),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
                    _buildPersonalDetails(),
                    const SizedBox(height: 25),
                    _buildActivityHistory(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }

  // ---- 1. Profile Header ----
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _userData?['image_url'] != null
                  ? NetworkImage(_userData!['image_url'])
                  : null,
              child: _userData?['image_url'] == null
                  ? const Icon(Icons.person, size: 60, color: Color(0xFF94A3B8))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 5,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Color(0xFF137FEC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Name
        Text(
          _displayName.isEmpty ? 'Loading...' : _displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),

        // Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(
              'Unit 402B',
              const Color(0xFFDBEAFE),
              const Color(0xFF137FEC),
            ),
            const SizedBox(width: 8),
            _buildBadge(
              'Verified',
              const Color(0xFFFEE2E2),
              const Color(0xFFEF4444),
            ),
          ],
        ),
        if (_memberSince.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _memberSince,
            style: const TextStyle(color: Color(0xFF4C739A), fontSize: 14),
          ),
        ],
      ],
    );
  }

  // ---- 2. Personal Details ----
  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildListTile(Icons.email_outlined, 'Email', _email),
              const Divider(height: 1, indent: 70),
              _buildListTile(
                Icons.phone_android_outlined,
                'Phone Number',
                _firebaseUser?.phoneNumber ?? '(+66) 00-000-0000',
              ),
              if (_userData?['role'] != null) ...[
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  Icons.badge_outlined,
                  'Role',
                  (_userData!['role'] as String).toUpperCase(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---- 3. Activity History ----
  Widget _buildActivityHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.build_outlined,
          'Repairs History',
          'View all repair requests',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RepairHistoryPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.calendar_today_outlined,
          'Booking History',
          'Meeting room reservation',
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          Icons.account_balance_wallet_outlined,
          'Payment History',
          'View all rent & utility receipts',
        ),
      ],
    );
  }

  // ---- 4. Logout Button ----
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
        label: const Text(
          'Logout',
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

  // ---- Helper Widgets ----
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

  Widget _buildHistoryCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
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
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: onTap != null
                  ? const Color(0xFF137FEC)
                  : const Color(0xFFCBD5E1),
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
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: const Color(0xFFF1F5F9)),
    );
  }
}
