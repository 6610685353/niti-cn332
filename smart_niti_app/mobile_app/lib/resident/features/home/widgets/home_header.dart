// lib/resident/features/home/widgets/home_header.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../core/app_config.dart';
import '../../../core/user_avatar_notifier.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.hasNotification = false,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/users/$uid'));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _userData = data);
        // sync notifier เฉพาะตอน fetch ครั้งแรก (ถ้ายังไม่มีค่าใน notifier)
        if (userAvatarNotifier.value == null) {
          userAvatarNotifier.value = data['image_url'] as String? ?? '';
        }
      }
    } catch (_) {}
  }

  String get _firstName {
    final fn = _userData?['first_name'] as String? ?? '';
    return fn.isNotEmpty
        ? fn
        : (FirebaseAuth.instance.currentUser?.displayName ?? '');
  }

  String get _initial {
    final name = _firstName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16, top: 60, bottom: 10),
      child: Row(
        children: [
          // ── Avatar: ฟังค่าจาก notifier เพื่ออัพเดตทันทีเมื่อ profile เปลี่ยน ──
          ValueListenableBuilder<String?>(
            valueListenable: userAvatarNotifier,
            builder: (_, avatarUrl, __) => _buildAvatar(avatarUrl),
          ),
          const SizedBox(width: 14),

          // ── Text ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Niti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      const TextSpan(text: 'Welcome, '),
                      TextSpan(
                        text: _firstName.isNotEmpty ? _firstName : '...',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF137FEC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    final hasImage = avatarUrl != null && avatarUrl.isNotEmpty;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF137FEC), width: 2),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                // cache busting: เพิ่ม timestamp เพื่อบังคับโหลดรูปใหม่
                key: ValueKey(avatarUrl),
                errorBuilder: (_, __, ___) => _initialAvatar(),
              )
            : _initialAvatar(),
      ),
    );
  }

  Widget _initialAvatar() {
    return Container(
      color: const Color(0xFFDBEAFE),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF137FEC),
        ),
      ),
    );
  }
}
