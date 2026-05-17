import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/user_service.dart';
import '../../core/services/api_service.dart';
import '../../profile/models/user_model.dart';
import '../../profile/widgets/profile_widgets.dart';
import './update_email_screen.dart';
import '../../work_order/screens/repair_history_screen.dart';
import '../../technician/technician_facade.dart';
import '../../login/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _uploadingAvatar = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await UserService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error ${e.statusCode}: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Avatar Upload ──────────────────────────────────────────────────────────
  Future<void> _changeAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Profile Photo'),
        content: const Text('Choose a new photo from your gallery?'),
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
              'Choose Photo',
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

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      final updated = await UserService.uploadAvatar(bytes, picked.name);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _uploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile photo updated'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await TechnicianFacade().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayEmail = firebaseUser?.email ?? '';
    final joinDate = _user?.createdAt != null
        ? 'Member since ${_formatDate(_user!.createdAt!)}'
        : 'Member';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 30),

              // ── Avatar ───────────────────────────────────────────────────
              GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          (_user?.imageUrl != null &&
                              _user!.imageUrl!.isNotEmpty)
                          ? NetworkImage(_user!.imageUrl!)
                          : null,
                      child: _uploadingAvatar
                          ? const CircularProgressIndicator(color: Colors.white)
                          : (_user?.imageUrl == null ||
                                _user!.imageUrl!.isEmpty)
                          ? Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1677FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _user?.fullName ?? 'Technician',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(
                    _user?.role.toUpperCase() ?? 'TECHNICIAN',
                    const Color(0xFFE6F4FF),
                    const Color(0xFF1677FF),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    _user?.status == 'active' ? 'Active' : 'Inactive',
                    _user?.status == 'active'
                        ? const Color(0xFFF0FFF4)
                        : const Color(0xFFFFF1F0),
                    _user?.status == 'active'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFFF4D4F),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                joinDate,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),

              const SizedBox(height: 30),

              // ── Personal Details ─────────────────────────────────────────
              _buildSection('Personal Details', [
                // Full Name อยู่บนสุด ไม่มี chevron
                ProfileInfoTile(
                  icon: Icons.person_outline_rounded,
                  iconBgColor: const Color(0xFF8B5CF6),
                  title: 'Full Name',
                  value: _user?.fullName ?? '-',
                  onTap: () {},
                  showChevron: false,
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey.shade100,
                ),
                // Email อยู่ล่าง มี chevron (กดเพื่อแก้ไข)
                ProfileInfoTile(
                  icon: Icons.mail_outline_rounded,
                  iconBgColor: const Color(0xFF1677FF),
                  title: 'Email',
                  value: displayEmail,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UpdateEmailScreen(),
                      ),
                    );
                    if (result == true) _loadProfile();
                  },
                ),
              ]),

              // ── Activity History ─────────────────────────────────────────
              _buildSection('Activity History', [
                ProfileInfoTile(
                  icon: Icons.history_rounded,
                  iconBgColor: const Color(0xFF0EA5E9),
                  title: 'Repair History',
                  value: 'View all my work orders',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RepairHistoryScreen(initialTab: 'All'),
                    ),
                  ),
                ),
              ]),

              // ── Logout Button ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    'Logout',
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
              fontSize: 15,
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

  String _formatDate(DateTime d) {
    const months = [
      '',
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
    return '${months[d.month]} ${d.year}';
  }
}
