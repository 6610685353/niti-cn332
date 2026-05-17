// lib/resident/core/resident_main_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/profile/profile_page.dart';
import '../features/home/home_page.dart';
import 'widgets/main_bottom_nav.dart';
import '../features/repair_request/repair_request_page.dart';
import 'user_data_notifier.dart';

class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  int _currentIndex = 0;

  // Notifier เดียวที่แชร์ระหว่าง HomePage และ ProfilePage
  final _userNotifier = UserDataNotifier();

  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    // Fetch ครั้งแรกทันที
    _userNotifier.fetchUserData();

    // Re-fetch ทุกครั้งที่ Firebase auth state เปลี่ยน
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userNotifier.fetchUserData();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(userNotifier: _userNotifier),
      ProfilePage(userNotifier: _userNotifier),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),

      // ── FAB: เฉพาะหน้า Home ─────────────────────────────────────────────
      floatingActionButton: _currentIndex == 0
          ? SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RepairRequestPage(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF0F172A),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 3),
                ),
                elevation: 6,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
