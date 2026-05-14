import 'package:flutter/material.dart';
// ปรับ Path การ Import ให้ถูกต้องตามโครงสร้างโปรเจกต์
import '../../work_order/models/work.dart';
import '../../work_order/screens/repairing.dart';
import '../widgets/repair_history_card.dart';

class RepairHistoryScreen extends StatefulWidget {
  final String initialTab;

  const RepairHistoryScreen({Key? key, this.initialTab = 'All'})
    : super(key: key);

  @override
  State<RepairHistoryScreen> createState() => _RepairHistoryScreenState();
}

class _RepairHistoryScreenState extends State<RepairHistoryScreen> {
  final List<String> _tabs = ['All', 'Pending', 'Repairing', 'Done'];
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  List<WorkOrder> get _filteredOrders {
    if (_selectedTab == 'All') return mockWorkOrdersList;
    return mockWorkOrdersList
        .where((order) => order.status == _selectedTab)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF0F172A),
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Repair History',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return RepairHistoryCard(
                  workOrder: order,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RepairingScreen(workOrder: order),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : Colors.grey.shade500,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
