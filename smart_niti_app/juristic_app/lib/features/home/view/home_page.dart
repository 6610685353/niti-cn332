import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. เพิ่ม import สำหรับตัวจัดการความจำ
import 'package:juristic_app/core/widgets/top_bar.dart';
import 'package:juristic_app/features/dashboard/views/dashboard_page.dart';
import 'package:juristic_app/features/task_dispatch/view/task_dispatch_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เริ่มต้นให้หน้าแรก (Dashboard) เป็น 0 ไว้ก่อน (เดี๋ยวตัวโหลดความจำจะมาทับค่านี้ทีหลัง)
  int _selectedIndex = 0;

  // List เก็บหน้า View ต่างๆ ตามลำดับเมนู
  final List<Widget> _pages = [
    const DashboardPage(), // Index 0
    const TaskDispatchPage(), // Index 1
    // const Center(
    //   child: Text("Announcement Page", style: TextStyle(fontSize: 24)),
    // ), // Index 2
    // const Center(
    //   child: Text("Parcel Page", style: TextStyle(fontSize: 24)),
    // ), // Index 3
  ];

  @override
  void initState() {
    super.initState();
    // 2. พอหน้าเว็บโหลดปุ๊บ ให้วิ่งไปดึงความจำมาทันที
    _loadLastMenu();
  }

  // ฟังก์ชันดึงค่าที่เคยเลือกล่าสุด
  Future<void> _loadLastMenu() async {
    final prefs = await SharedPreferences.getInstance();
    // ดึงคีย์ 'last_menu_index' ถ้ายังไม่เคยเลือกเลยให้ส่ง 0 (Dashboard) กลับมา
    final savedIndex = prefs.getInt('last_menu_index') ?? 0;

    // อัปเดต UI ถ้า widget ยังมีชีวิตอยู่
    if (mounted) {
      setState(() {
        _selectedIndex = savedIndex;
      });
    }
  }

  // ฟังก์ชันสำหรับเปลี่ยนหน้า
  Future<void> _onMenuTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // 3. ทุกครั้งที่กดเปลี่ยนเมนู ให้เซฟค่านั้นลงความจำเบราว์เซอร์ด้วย
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_menu_index', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        icon: Icons.business,
        title: 'Smart Niti Admin Center',
        selectedIndex: _selectedIndex,
        onMenuTap: _onMenuTapped,
      ),
      // เปลี่ยนเนื้อหาตรงกลางหน้าจอตาม Index ที่เลือก
      body: _pages[_selectedIndex],
    );
  }
}
