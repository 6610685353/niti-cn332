import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/features/dashboard/widgets/system_users_card.dart';
import 'package:juristic_app/features/home/models/ticket_model.dart';
import 'package:juristic_app/features/juristic/juristic_facade.dart';
import '../widgets/recent_complaints_card.dart';
import '../widgets/repair_overview_card.dart';
import '../widgets/stat_card.dart';
import 'package:juristic_app/features/home/view/home_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onViewAllTap;

  const DashboardPage({super.key, this.onViewAllTap});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _facade = JuristicFacade();

  List<TicketModel> _tickets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tickets = await _facade.getTickets();
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    } else if (_error != null) {
      content = Center(
        key: const ValueKey('error'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'โหลดข้อมูลไม่สำเร็จ\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTickets,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    } else {
      final stats = _facade.countByStatus(_tickets);
      final total = _tickets.length;

      final recentActive = _tickets
          .where(
            (t) =>
                t.status != TicketStatus.done &&
                t.status != TicketStatus.cancelled,
          )
          .toList();

      content = RefreshIndicator(
        key: const ValueKey('content'),
        onRefresh: _loadTickets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                "Real-time property maintenance",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Repairs Request",
                        value: "$total",
                        icon: Icons.build,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        title: "Pending Request",
                        value: "${stats['submitted'] ?? 0}",
                        icon: Icons.pending_actions,
                        color: AppColors.errorRed,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        title: "In Progress",
                        value: "${stats['in_progress'] ?? 0}",
                        icon: Icons.engineering,
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ฝั่งซ้าย (มี 2 กล่องเรียงบนล่าง)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        RepairOverviewCard(
                          total: total,
                          submitted: stats['submitted'] ?? 0,
                          assigned: stats['assigned'] ?? 0,
                          inProgress: stats['in_progress'] ?? 0,
                          done: stats['done'] ?? 0,
                        ),
                        const SizedBox(height: 24),
                        // 🌟 นำกล่อง System Users มาวางตรงนี้!
                        const SystemUsersCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // ฝั่งขวา (มีกล่อง Completed และ Recent Complaints ล็อกความสูงพอๆ กัน)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        StatCard(
                          title: "Completed",
                          value: "${stats['done'] ?? 0}",
                          icon: Icons.check_circle_outline,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(height: 24),
                        RecentComplaintsCard(
                          tickets: recentActive,
                          onViewAllTap: () {
                            if (widget.onViewAllTap != null) {
                              widget.onViewAllTap!();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
    );
  }
}
