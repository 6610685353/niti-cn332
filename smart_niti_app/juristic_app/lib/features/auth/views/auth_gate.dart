import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juristic_app/features/auth/login/views/login_page.dart';
import 'package:juristic_app/features/home/view/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. ถ้า Firebase ยังตรวจสอบสถานะไม่เสร็จ (กำลังดึง Token จากเบราว์เซอร์)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // แสดงตัวโหลดรอแป๊บหนึ่ง
            ),
          );
        }

        // 2. ถ้าพบว่าเคยล็อกอินค้างไว้ (เปิดหน้าหลักให้ทันที ไม่หลุดไปหน้า Login)
        if (snapshot.hasData) {
          return const HomePage(); // เปลี่ยนเป็นหน้าหลักของแอปนิติบุคคล
        }

        // 3. ถ้าไม่มีข้อมูล หรือ Log out ไปแล้วจริงๆ ค่อยส่งไปหน้า Login
        return const LoginPage();
      },
    );
  }
}
