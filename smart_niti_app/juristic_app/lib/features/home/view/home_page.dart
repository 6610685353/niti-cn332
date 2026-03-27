import 'package:flutter/material.dart';
import 'package:juristic_app/core/widgets/top_bar.dart';
import 'package:juristic_app/features/dashboard/views/dashboard_page.dart';
import 'package:juristic_app/features/task_dispatch/view/task_dispatch_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เริ่มต้นให้หน้าแรก (Dashboard) เป็น 0
  int _selectedIndex = 0;

  // List เก็บหน้า View ต่างๆ ตามลำดับเมนู
  final List<Widget> _pages = [
    const DashboardPage(), // Index 0: หน้า Dashboard ที่คุณทำไว้
    const TaskDispatchPage(),
    const Center(
      child: Text("Announcement Page", style: TextStyle(fontSize: 24)),
    ), // Index 2
    const Center(
      child: Text("Parcel Page", style: TextStyle(fontSize: 24)),
    ), // Index 3
  ];

  // ฟังก์ชันสำหรับเปลี่ยนหน้า
  void _onMenuTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        icon: Icons.business,
        title: 'Smart Niti Admin Center',
        selectedIndex:
            _selectedIndex, // ส่ง Index ปัจจุบันไปให้ Navbar เช็คสีน้ำเงิน
        onMenuTap: _onMenuTapped, // ส่งฟังก์ชันไปให้ปุ่มเมนูกด
      ),
      // เปลี่ยนเนื้อหาตรงกลางหน้าจอตาม Index ที่เลือก
      body: _pages[_selectedIndex],
    );
  }
}
