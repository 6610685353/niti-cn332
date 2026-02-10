import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color.fromARGB(26, 15, 102, 189),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.home_work,
            size: 40,
            color: Color.fromARGB(255, 15, 102, 189),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Smart Niti',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Residential Management',
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(97, 117, 137, 1),
          ),
        ),
      ],
    );
  }
}
