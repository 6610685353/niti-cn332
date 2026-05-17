// lib/resident/features/profile/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../repair_history/repair_history_page.dart';
import '../../core/app_config.dart';
import '../../core/user_data_notifier.dart';

class ProfilePage extends StatefulWidget {
  final UserDataNotifier userNotifier;

  const ProfilePage({super.key, required this.userNotifier});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploadingImage = false;

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  UserDataNotifier get _notifier => widget.userNotifier;

  // ---- อัพโหลดรูปโปรไฟล์ ----
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final token = await _firebaseUser?.getIdToken();
      if (token == null) throw Exception('ไม่พบ token');

      final uri = Uri.parse('${AppConfig.baseUrl}/users/me/avatar');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', picked.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // อัพเดต notifier → ทั้ง header และ profile rebuild ทันที
        _notifier.updateImageUrl(data['image_url'] as String);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัพเดทรูปโปรไฟล์สำเร็จ'),
              backgroundColor: Color(0xFF137FEC),
            ),
          );
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัพโหลดรูปไม่สำเร็จ: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'เปลี่ยนรูปโปรไฟล์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSourceTile(
              ctx,
              Icons.camera_alt_outlined,
              'ถ่ายรูปใหม่',
              ImageSource.camera,
            ),
            const SizedBox(height: 12),
            _buildSourceTile(
              ctx,
              Icons.photo_library_outlined,
              'เลือกจากคลังรูป',
              ImageSource.gallery,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTile(
    BuildContext ctx,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, source),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF137FEC), size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
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
      body: ListenableBuilder(
        listenable: _notifier,
        builder: (context, _) {
          if (_notifier.isLoading && _notifier.userData == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF137FEC)),
            );
          }

          return RefreshIndicator(
            onRefresh: _notifier.fetchUserData,
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
          );
        },
      ),
    );
  }

  // ---- 1. Profile Header ----
  Widget _buildProfileHeader() {
    final imageUrl = _notifier.imageUrl;
    final building = _notifier.building;
    final roomNo = _notifier.roomNo;
    final name = _notifier.displayName;
    final memberSince = _notifier.memberSince;

    return Column(
      children: [
        const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Avatar with edit button
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF137FEC).withOpacity(0.25),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 57,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageUrl != null
                    ? NetworkImage('${AppConfig.baseUrl}$imageUrl')
                    : null,
                child: imageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF94A3B8),
                      )
                    : null,
              ),
            ),

            // Loading overlay ขณะอัพโหลด
            if (_isUploadingImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            // ปุ่ม edit
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: _isUploadingImage ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _isUploadingImage
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF137FEC),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF137FEC).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
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
          name.isEmpty ? 'Loading...' : name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),

        // ── Badges: ตึก + เลขห้อง จากข้อมูลจริง ────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge ตึก (building)
            if (building != null && building.isNotEmpty)
              _buildBadge(
                'Building $building',
                const Color(0xFFDBEAFE),
                const Color(0xFF137FEC),
              ),
            if (building != null &&
                building.isNotEmpty &&
                roomNo != null &&
                roomNo.isNotEmpty)
              const SizedBox(width: 8),
            // Badge เลขห้อง (room_no)
            if (roomNo != null && roomNo.isNotEmpty)
              _buildBadge(
                'Room $roomNo',
                const Color(0xFFDCFCE7),
                const Color(0xFF16A34A),
              ),
            // Fallback ถ้ายังไม่มีข้อมูล
            if ((building == null || building.isEmpty) &&
                (roomNo == null || roomNo.isEmpty))
              _buildBadge(
                'Resident',
                const Color(0xFFDBEAFE),
                const Color(0xFF137FEC),
              ),
          ],
        ),

        if (memberSince.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            memberSince,
            style: const TextStyle(color: Color(0xFF4C739A), fontSize: 14),
          ),
        ],
      ],
    );
  }

  // ---- 2. Personal Details ----
  Widget _buildPersonalDetails() {
    final email =
        _firebaseUser?.email ?? _notifier.userData?['email'] ?? 'ไม่มีข้อมูล';
    final phone = _firebaseUser?.phoneNumber ?? '(+66) 00-000-0000';
    final role = _notifier.role;
    final building = _notifier.building;
    final roomNo = _notifier.roomNo;

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
              _buildListTile(Icons.email_outlined, 'Email', email),
              const Divider(height: 1, indent: 70),
              _buildListTile(
                Icons.phone_android_outlined,
                'Phone Number',
                phone,
              ),
              if (role != null) ...[
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  Icons.badge_outlined,
                  'Role',
                  role.toUpperCase(),
                ),
              ],
              // แสดงตึก + ห้องใน personal details ด้วย
              if (building != null && building.isNotEmpty) ...[
                const Divider(height: 1, indent: 70),
                _buildListTile(Icons.apartment_outlined, 'Building', building),
              ],
              if (roomNo != null && roomNo.isNotEmpty) ...[
                const Divider(height: 1, indent: 70),
                _buildListTile(
                  Icons.door_front_door_outlined,
                  'Room No.',
                  roomNo,
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
