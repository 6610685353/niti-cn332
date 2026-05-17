import 'package:flutter/material.dart';

class StatusStepper extends StatelessWidget {
  final String currentStatus;

  const StatusStepper({Key? key, required this.currentStatus})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ลำดับ progress ของงาน
    final steps = ['Pending', 'Repairing', 'Done'];

    // index ของ status ปัจจุบัน (ถ้าหาไม่เจอให้ใช้ 0)
    final currentIndex = steps
        .indexOf(currentStatus)
        .clamp(0, steps.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label บนสุด ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              _buildStatusBadge(currentStatus),
            ],
          ),
          const SizedBox(height: 20),

          // ── Step indicators ───────────────────────────
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              // ตำแหน่งคี่ = connector line
              if (i.isOdd) {
                final stepIndex = i ~/ 2;
                final isDone = stepIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF1677FF)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }

              // ตำแหน่งคู่ = step circle
              final stepIndex = i ~/ 2;
              final isCurrent = stepIndex == currentIndex;
              final isDone = stepIndex < currentIndex;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isCurrent ? 36 : 28,
                    height: isCurrent ? 36 : 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? const Color(0xFF1677FF)
                          : isCurrent
                          ? const Color(0xFF1677FF)
                          : const Color(0xFFE2E8F0),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1677FF).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : isCurrent
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 10),

          // ── Step labels ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final label = entry.value;
              final isCurrent = idx == currentIndex;
              final isDone = idx < currentIndex;

              return Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? const Color(0xFF1677FF)
                      : isDone
                      ? const Color(0xFF1677FF)
                      : const Color(0xFF94A3B8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    Color border;
    IconData icon;

    switch (status) {
      case 'Done':
        bg = const Color(0xFFF0FDF4);
        text = const Color(0xFF16A34A);
        border = const Color(0xFFBBF7D0);
        icon = Icons.check_circle_rounded;
        break;
      case 'Repairing':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1677FF);
        border = const Color(0xFFBFDBFE);
        icon = Icons.build_rounded;
        break;
      case 'Pending':
      default:
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFEA580C);
        border = const Color(0xFFFED7AA);
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
