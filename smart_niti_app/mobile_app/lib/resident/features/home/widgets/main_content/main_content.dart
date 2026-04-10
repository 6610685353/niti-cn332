import 'package:flutter/material.dart';
import 'package:mobile_app/resident/features/home/widgets/main_content/widgets/next_booking.dart';
import 'package:mobile_app/resident/features/home/widgets/main_content/widgets/total_balance.dart';
import 'widgets/pending_parcels.dart';
import 'widgets/active_repair.dart';
import 'package:mobile_app/resident/features/home/widgets/recent_update.dart ';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // เพิ่ม BouncingScrollPhysics เพื่อให้เลื่อนลื่นขึ้น
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RecentUpdate(),
          const SizedBox(height: 10), // เพิ่ม gap เล็กน้อย
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
