import 'package:flutter/material.dart';
import '../../home/screens/home.dart';
import '../../profile/screens/profile.dart';
import '../constants/app_color.dart';
import '../../schedule/screens/schedule.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({Key? key}) : super(key: key);

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  int _currentIndex = 0;

  void _jumpToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(onProfileTap: () => _jumpToTab(2)),
      const ScheduleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _jumpToTab,
        selectedItemColor: AppColors.textDark,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
