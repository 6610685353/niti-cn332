import 'package:flutter/material.dart';

class ActiveRepair extends StatelessWidget {
  const ActiveRepair({super.key});

  void _onTap(BuildContext context) {
    // ตอนนี้ยังไม่มีหน้าใหม่
    debugPrint("ActiveRepair tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(15),
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.build,
                  color: Color(0xFFD97706),
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Active Repairs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              const Text(
                "Leakage fixed",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4C739A),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    "50%",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF137FEC),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: 0.5,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF137FEC),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
