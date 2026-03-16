import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/date_selector.dart';
import '../widgets/timeline_line.dart';
import '../widgets/task_card.dart';
import '../models/schedule_model.dart';
import '../../core/constants/app_color.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isTaskInProgress(ScheduleModel item) {
    try {
      final now = DateTime.now();
      if (!DateUtils.isSameDay(item.date, now)) return false;

      final timeParts = item.startTime.split(':');
      final start = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final durationVal = int.parse(item.duration.split(' ')[0]);
      final end = start.add(Duration(minutes: durationVal));

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = scheduleMockData.where((task) {
      return DateUtils.isSameDay(task.date, _selectedDate);
    }).toList();

    filteredTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Work Schedule",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: DateSelector(
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final item = filteredTasks[index];

                      if (item.type == ScheduleItemType.breakTime) {
                        return _buildTimelineRow(
                          item.startTime,
                          _buildBreakUI(),
                          showCard: false,
                        );
                      } else {
                        return _buildTimelineRow(
                          item.startTime,
                          TaskCard(
                            title: item.title,
                            location: item.location,
                            startTime: item.startTime,
                            duration: item.duration,
                            isActive: _isTaskInProgress(item),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 12.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.local_cafe_outlined,
            size: 18,
            color: Colors.blueGrey.shade200,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "BREAK TIME",
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Take a breath and relax",
                style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Color(0xFFB6B6B6)),
          const SizedBox(height: 16),
          const Text(
            "No tasks scheduled for this day",
            style: TextStyle(color: Color(0xFFB6B6B6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    String time,
    Widget content, {
    bool showCard = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 45,
            child: Padding(
              padding: EdgeInsets.only(top: showCard ? 2 : 14),
              child: Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: showCard ? 4 : 16),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: showCard
                        ? const Color(0xFF2B468B)
                        : Colors.blueGrey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CustomPaint(painter: DashedLinePainter()),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showCard ? 24 : 16),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
