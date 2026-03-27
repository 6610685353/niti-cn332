import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import '../widgets/recent_complaints_card.dart';
import '../widgets/repair_overview_card.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            "Real-time property maintenance for Q1 2077",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // แถวของ Stat Cards
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(
                  child: StatCard(
                    title: "Total Repairs Request",
                    value: "142",
                    icon: Icons.build,
                    trend: "↗ 12%",
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: StatCard(
                    title: "Billing Summary",
                    value: "20",
                    subValue: "/ 250",
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.successGreen,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: StatCard(
                    title: "Parcels pending pickup",
                    value: "28",
                    icon: Icons.warning,
                    color: AppColors.warningOrange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ส่วนเนื้อหากลางหน้าจอ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: RepairOverviewCard()),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: const [
                    StatCard(
                      title: "Scheduled Facility Bookings",
                      value: "142",
                      icon: Icons.calendar_month,
                      trend: "↗ 12%",
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 24),
                    RecentComplaintsCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
