// lib/resident/features/profile/profile_page.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../repair_history/repair_history_page.dart';
import '../../core/app_config.dart';
import '../../core/user_avatar_notifier.dart';
import '../../../auth/login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ── Auth headers ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    final token = await user.getIdToken();
    return {'Authorization': 'Bearer $token'};
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final uid = _firebaseUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/users/$uid'));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _userData = data;
          _isLoading = false;
        });
        // sync avatar notifier เพื่ออัพเดต HomeHeader
        userAvatarNotifier.value = data['image_url'] as String? ?? '';
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // ── Avatar: pick → confirm dialog → upload ────────────────────────────────

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    // ── Confirm dialog ──────────────────────────────────────────────────
    final confirmed = await _showConfirmAvatarDialog(picked.path);
    if (confirmed != true) return;

    await _uploadAvatar(File(picked.path));
  }

  Future<bool?> _showConfirmAvatarDialog(String imagePath) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ใช้รูปนี้เป็นโปรไฟล์?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              // Preview
              CircleAvatar(
                radius: 64,
                backgroundImage: FileImage(File(imagePath)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFF137FEC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isUploadingAvatar = true);
    try {
      final headers = await _authHeaders();
      if (headers.isEmpty) return;

      final request =
          http.MultipartRequest(
              'PATCH',
              Uri.parse('${AppConfig.baseUrl}/users/me'),
            )
            ..headers.addAll(headers)
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      if (streamed.statusCode == 200) {
        // refetch เพื่อได้ signed URL ใหม่ พร้อม sync notifier
        await _fetchUserData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อัปโหลดรูปไม่สำเร็จ กรุณาลองใหม่')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  // ── Delete avatar ─────────────────────────────────────────────────────────

  Future<void> _deleteAvatar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ลบรูปโปรไฟล์',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('คุณต้องการลบรูปโปรไฟล์ใช่หรือไม่?'),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final headers = await _authHeaders();
      if (headers.isEmpty) return;

      // เรียก DELETE /users/me/avatar เพื่อลบรูปโปรไฟล์
      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/users/me/avatar'),
        headers: headers,
      );

      if (res.statusCode == 200 && mounted) {
        setState(() => _userData = {...?_userData, 'image_url': null});
        // sync notifier: "" = ไม่มีรูป → HomeHeader แสดง initial แทน
        userAvatarNotifier.value = '';
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบรูปไม่สำเร็จ กรุณาลองใหม่')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  // ── Display helpers ───────────────────────────────────────────────────────

  String get _displayName {
    if (_userData != null) {
      final fn = _userData!['first_name'] ?? '';
      final ln = _userData!['last_name'] ?? '';
      return '$fn $ln'.trim();
    }
    return _firebaseUser?.displayName ?? 'User';
  }

  String get _initial {
    final name = _displayName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get _email =>
      _firebaseUser?.email ?? _userData?['email'] ?? 'ไม่มีข้อมูล';

  String get _building => _userData?['building'] ?? '';
  String get _roomNo => _userData?['room_no'] ?? '';

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

  // ── Logout ────────────────────────────────────────────────────────────────

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
    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();
    // reset avatar notifier
    userAvatarNotifier.value = null;

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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

  // ── 1. Profile Header ─────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    final imageUrl = _userData?['image_url'] as String?;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      children: [
        const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Avatar + action buttons
        Stack(
          children: [
            // Avatar circle
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFDBEAFE),
              backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
              child: !hasImage
                  ? Text(
                      _initial,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF137FEC),
                      ),
                    )
                  : null,
            ),

            // Loading overlay
            if (_isUploadingAvatar)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),

            // Edit (camera) button — bottom-right
            if (!_isUploadingAvatar)
              Positioned(
                bottom: 0,
                right: 5,
                child: GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFF137FEC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

            // Delete button — bottom-left (เฉพาะตอนมีรูป)
            if (!_isUploadingAvatar && hasImage)
              Positioned(
                bottom: 0,
                left: 5,
                child: GestureDetector(
                  onTap: _deleteAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
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

        // Badges — Building + Room No
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_building.isNotEmpty)
              _buildBadge(
                _building,
                const Color(0xFFDBEAFE),
                const Color(0xFF137FEC),
                Icons.apartment_outlined,
              ),
            if (_building.isNotEmpty && _roomNo.isNotEmpty)
              const SizedBox(width: 8),
            if (_roomNo.isNotEmpty)
              _buildBadge(
                'Room $_roomNo',
                const Color(0xFFDCFCE7),
                const Color(0xFF16A34A),
                Icons.door_front_door_outlined,
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

  // ── 2. Personal Details ───────────────────────────────────────────────────

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

  // ── 3. Activity History ───────────────────────────────────────────────────

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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RepairHistoryPage()),
          ),
        ),
      ],
    );
  }

  // ── 4. Logout ─────────────────────────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildBadge(
    String text,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
