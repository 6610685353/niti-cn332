import 'package:flutter/material.dart';
import 'auth/login/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Niti',
      theme: ThemeData(fontFamily: 'Inter'),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
