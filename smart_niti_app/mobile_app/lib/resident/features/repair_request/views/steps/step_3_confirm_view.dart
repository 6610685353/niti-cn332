import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/repair_request_provider.dart';

class Step3ConfirmView extends StatelessWidget {
  const Step3ConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairRequestProvider>();
    final data = provider.requestData;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Confirm Repair Details",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111618),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Please verify all information before submitting your request.",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),

          const SizedBox(height: 24),

          // --- 1. Issue Summary Card ---
          _buildInfoCard(
            icon: Icons.warning_rounded,
            iconColor: const Color(0xFF13B6EC),
            title: "Issue Summary",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubLabel("Category & Title"),
                Text(
                  "${data.category}: ${data.title}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSubLabel("Description"),
                Text(
                  data.description.isEmpty ? "-" : data.description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Uploaded Media Card ---
          _buildInfoCard(
            icon: Icons.image_outlined,
            iconColor: const Color(0xFF13B6EC),
            title: "Uploaded Media",
            child: data.images.isEmpty
                ? const Text(
                    "No images uploaded",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  )
                : Wrap(
                    spacing: 12,
                    children: data.images
                        .map((file) => _buildCircleThumb(file))
                        .toList(),
                  ),
          ),

          // --- 3. Location & Appointment Card (แบบใหม่ตามรูป) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: "Location",
                  value: data.location,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: "Appointment",
                  value:
                      "${data.selectedDate != null ? DateFormat('MMM dd, yyyy').format(data.selectedDate!) : '-'} | ${data.selectedTimeSlot ?? '-'}",
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // Widget สำหรับหัวข้อย่อยสีเทาๆ
  Widget _buildSubLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget สำหรับแถว Location/Appointment ที่มีไอคอนในกล่องสีฟ้า
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8FE), // สีฟ้าอ่อนมาก
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF13B6EC), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ส่วน Card พื้นฐาน
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111618),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          child,
        ],
      ),
    );
  }

  // รูปวงกลม Thumbnails
  Widget _buildCircleThumb(File file) {
    return Container(
      width: 73,
      height: 73,
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
    );
  }
}
