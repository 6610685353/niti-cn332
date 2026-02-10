import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Niti',
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
