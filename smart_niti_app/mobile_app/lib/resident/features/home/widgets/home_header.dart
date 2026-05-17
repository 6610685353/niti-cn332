import 'package:flutter/material.dart';
import '../../../core/app_config.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool hasNotification;
  final String? userName;
  final String? userImageUrl;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.hasNotification = false,
    this.userName,
    this.userImageUrl,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = userImageUrl != null
        ? NetworkImage('${AppConfig.baseUrl}$userImageUrl')
              as ImageProvider<Object>
        : null;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 10),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF137FEC).withOpacity(0.25),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 24, color: Color(0xFF94A3B8))
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // ── Greeting + Name ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  userName?.isNotEmpty == true ? userName! : 'Smart Niti',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
