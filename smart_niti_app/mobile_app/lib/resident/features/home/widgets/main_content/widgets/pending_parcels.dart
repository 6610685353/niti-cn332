import 'package:flutter/material.dart';

class PendingParcels extends StatelessWidget {
  const PendingParcels({super.key});

  void _onTap(BuildContext context) {
    // ตอนนี้ยังไม่มีหน้าใหม่
    debugPrint("PendingParcels tapped");

    // อนาคตใส่แบบนี้ได้เลย:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const ParcelDetailPage()),
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
                  color: const Color(0xFFE8F3FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.markunread_mailbox,
                  color: Color(0xFF0B129D),
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Pending Parcels",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              const Text(
                "3 Ready for pickup",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Icon(Icons.lock_outlined, size: 14, color: Color(0xFF4C739A)),
                  SizedBox(width: 5),
                  Text(
                    "Locker: B-104",
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
