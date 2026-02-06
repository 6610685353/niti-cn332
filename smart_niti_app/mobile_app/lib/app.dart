import 'package:flutter/material.dart';
import 'auth/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Smart Niti', home: LoginPage());
  }
}
