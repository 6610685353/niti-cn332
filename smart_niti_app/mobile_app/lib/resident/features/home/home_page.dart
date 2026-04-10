import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/main_content/main_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            hasNotification: true,
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification clicked")),
              );
            },
          ),
          const Expanded(child: MainContent()),
        ],
      ),
    );
  }
}
