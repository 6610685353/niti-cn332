import 'package:flutter/material.dart';
import 'login/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Niti',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug สีแดงที่มุมจอ
      theme: ThemeData(
        // ตั้งค่าสีหลัก (Primary Swatch) เป็นสีน้ำเงินตามปุ่ม Login
        primarySwatch: Colors.blue,
        // ใช้ Font มาตรฐาน
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 2. กำหนดหน้าแรกที่จะให้แสดงเมื่อเปิดแอป
      home: const LoginScreen(),
    );
  }
}
