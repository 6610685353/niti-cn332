// lib/resident/core/resident_main_page.dart

import 'package:flutter/material.dart';
import '../features/profile/profile_page.dart';
import '../features/home/home_page.dart';
import 'widgets/main_bottom_nav.dart';
import '../features/repair_request/repair_request_page.dart';

class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ── FAB: เฉพาะหน้า Home, icon +, เปิดหน้า Repair Request ──────────
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

      // FAB ตรงกลาง
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
