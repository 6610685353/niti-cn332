import 'package:flutter/material.dart';

class NextBooking extends StatelessWidget {
  const NextBooking({super.key});

  void _onTap(BuildContext context) {
    // ตอนนี้ยังไม่มีหน้าใหม่
    debugPrint("NextBooking tapped");

    // อนาคตใส่แบบนี้ได้เลย:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const BookingDetailPage()),
    // );
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
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event,
                  color: Color(0xFF9333EA),
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Next Booking",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              const Text(
                "Gym at 6:00 PM",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4C739A),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Color(0xFF4C739A)),
                  SizedBox(width: 5),
                  Text(
                    "Todar, Main Hall",
                    style: TextStyle(fontSize: 12, color: Color(0xFF4C739A)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
