import 'package:flutter/material.dart';
import './models/repair_history_model.dart';

class RepairHistoryPage extends StatefulWidget {
  const RepairHistoryPage({super.key});

  @override
  State<RepairHistoryPage> createState() => _RepairHistoryPageState();
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  String selectedFilter = "All";

  // ข้อมูลจำลอง (Mock Data)
  final List<RepairHistoryItem> allRepairs = [
    RepairHistoryItem(
      category: "PLUMBING",
      title: "Leaking Pipe Repair",
      date: "May 12, 2023",
      time: "10:30 AM",
      technicianName: "Robert Chen",
      technicianRole: "Certified Plumber",
      status: RepairStatus.completed,
      rating: 5,
    ),
    RepairHistoryItem(
      category: "HVAC",
      title: "AC Annual Maintenance",
      date: "April 05, 2023",
      time: "02:15 PM",
      technicianName: "Sarah Jenkins",
      technicianRole: "HVAC Specialist",
      status: RepairStatus.cancelled,
    ),
    RepairHistoryItem(
      category: "ELECTRICAL",
      title: "Kitchen Circuit Short",
      date: "March 15, 2023",
      time: "09:00 AM",
      technicianName: "Marcus Webb",
      technicianRole: "Master Electrician",
      status: RepairStatus.completed,
      rating: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // กรองข้อมูลตาม Filter ที่เลือก
    List<RepairHistoryItem> filteredList = allRepairs.where((item) {
      if (selectedFilter == "All") return true;
      if (selectedFilter == "Completed")
        return item.status == RepairStatus.completed;
      if (selectedFilter == "Cancelled")
        return item.status == RepairStatus.cancelled;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Repair History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildRepairCard(filteredList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ส่วนของ Tab Filter ---
  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ["All", "Completed", "Cancelled"].map((filter) {
          bool isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- ส่วนของ Repair Card ---
  Widget _buildRepairCard(RepairHistoryItem item) {
    bool isCompleted = item.status == RepairStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.category,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${item.date} • ${item.time}",
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade200),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.technicianName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item.technicianRole,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              isCompleted
                  ? _buildRatingStars(item.rating)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "No Rating",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RepairStatus status) {
    bool isCompleted = status == RepairStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCompleted ? "Completed" : "Cancelled",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isCompleted
              ? const Color(0xFF16A34A)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => const Icon(Icons.star, color: Colors.amber, size: 14),
          ),
        ),
        const Text(
          "Rating Given",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
        ),
      ],
    );
  }
}
