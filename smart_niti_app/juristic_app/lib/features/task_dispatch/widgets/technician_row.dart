import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class TechnicianRow extends StatefulWidget {
  final String name, role;
  final int currentTasks;
  final int maxTasks;
  final Color roleColor;

  const TechnicianRow({
    super.key,
    required this.name,
    required this.role,
    required this.currentTasks,
    this.maxTasks = 5,
    required this.roleColor,
  });

  @override
  State<TechnicianRow> createState() => _TechnicianRowState();
}

class _TechnicianRowState extends State<TechnicianRow> {
  // สร้างตัวแปรเก็บสถานะการกดปุ่ม
  bool _isAssigned = false;

  @override
  Widget build(BuildContext context) {
    double percent = widget.currentTasks / widget.maxTasks;

    // Logic สีปุ่ม: ถ้าช่างว่าง (0 tasks) หรือ ปุ่มถูกกดไปแล้ว (_isAssigned = true) ให้เป็นสีทึบ
    bool isAvailable = widget.currentTasks == 0;
    bool showSolidBlue = _isAssigned;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // Avatar & Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 20,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: widget.roleColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Workload
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget.currentTasks} / ${widget.maxTasks} Tasks",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primaryBlue,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${(percent * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Button
          SizedBox(
            width: 95, // เพิ่มความกว้างนิดนึงเผื่อคำว่า Assigned
            child: ElevatedButton(
              onPressed: () {
                // อัปเดต State เมื่อปุ่มถูกกด (สลับไปมาได้)
                setState(() {
                  _isAssigned = !_isAssigned;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: showSolidBlue
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlue.withOpacity(0.1),
                foregroundColor: showSolidBlue
                    ? Colors.white
                    : AppColors.primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _isAssigned ? "Assigned" : "Assign", // เปลี่ยนข้อความตอนกดด้วย
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
