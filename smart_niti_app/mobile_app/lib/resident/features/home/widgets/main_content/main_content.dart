import 'package:flutter/material.dart';
import 'package:mobile_app/resident/features/home/widgets/main_content/widgets/next_booking.dart';
import 'package:mobile_app/resident/features/home/widgets/main_content/widgets/total_balance.dart';
import 'widgets/pending_parcels.dart';
import 'widgets/active_repair.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: const Text(
              "Your Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(child: ActiveRepair()),
              SizedBox(width: 20),
              Expanded(child: TotalBalance()),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(child: NextBooking()),
              SizedBox(width: 10),
              Expanded(child: PendingParcels()),
            ],
          ),
        ],
      ),
    );
  }
}
