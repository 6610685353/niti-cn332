import 'package:flutter/material.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({super.key});

  void _onTap(BuildContext context) {
    // ตอนนี้ยังไม่มีหน้าใหม่
    debugPrint("TotalBalance tapped");

    // อนาคตใส่แบบนี้ได้เลย:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const BalanceDetailPage()),
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFFDC2626),
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Total Balance",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              const Text(
                "\$500.00",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () => _onTap(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137FEC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "PAY NOW",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
