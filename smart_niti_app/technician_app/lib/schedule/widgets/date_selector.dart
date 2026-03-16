import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_color.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = List.generate(5, (index) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    });

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = dates[index];
          bool isSelected = DateUtils.isSameDay(date, selectedDate);
          bool isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgApp,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                      ? AppColors.primary.withValues(
                          alpha: 0.4,
                        ) // ✅ แก้เป็น withValues
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.2,
                          ), // ✅ แก้เป็น withValues
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(
                              alpha: 0.8,
                            ) // ✅ แก้เป็น withValues
                          : AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
