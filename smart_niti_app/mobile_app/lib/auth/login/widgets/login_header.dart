import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 86,
          decoration: BoxDecoration(
            color: const Color.fromARGB(26, 15, 102, 189),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.home_work,
            size: 40,
            color: Color.fromARGB(255, 15, 102, 189),
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'Smart Niti',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 17),
        const Text(
          'Residential Management',
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(97, 117, 137, 1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
