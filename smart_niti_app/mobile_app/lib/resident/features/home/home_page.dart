// lib/resident/features/home/home_page.dart

import 'package:flutter/material.dart';
import '../repair_history/repair_history_page.dart';
import 'widgets/home_header.dart';
import 'widgets/main_content/widgets/active_repair.dart';
import '../../core/user_data_notifier.dart';

class HomePage extends StatelessWidget {
  final UserDataNotifier userNotifier;

  const HomePage({super.key, required this.userNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: realtime จาก userNotifier ─────────────────────────
          ListenableBuilder(
            listenable: userNotifier,
            builder: (context, _) {
              return HomeHeader(
                hasNotification: true,
                userName: userNotifier.displayName,
                userImageUrl: userNotifier.imageUrl,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification clicked')),
                  );
                },
              );
            },
          ),

          // ── Main scrollable content ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Your Repairs" + "History" row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Your Repairs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RepairHistoryPage(),
                          ),
                        ),
                        child: const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Repair list ────────────────────────────────────────
                  const ActiveRepair(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
