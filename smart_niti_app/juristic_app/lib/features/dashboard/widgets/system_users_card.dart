import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/features/juristic/juristic_facade.dart';

class SystemUsersCard extends StatefulWidget {
  const SystemUsersCard({super.key});

  @override
  State<SystemUsersCard> createState() => _SystemUsersCardState();
}

class _SystemUsersCardState extends State<SystemUsersCard> {
  final JuristicFacade _facade = JuristicFacade();

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _currentRole = 'resident';

  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _currentPage = 0;
    });

    try {
      final data = await _facade.getUsersByRole(_currentRole);
      if (!mounted) return;
      setState(() {
        _users = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _users = [];
        _loading = false;
      });
    }
  }

  // ฟังก์ชันแสดง Popup ยืนยันก่อนลบ
  Future<void> _confirmDelete(String uid, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete User",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete '$name'?\nThis action cannot be undone.",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteUser(uid);
    }
  }

  Future<void> _deleteUser(String uid) async {
    setState(() => _loading = true);
    try {
      await _facade.deleteUser(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _fetchUsers(); // โหลดข้อมูลใหม่หลังจากลบสำเร็จ
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int get _totalPages => (_users.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * _itemsPerPage;
    final displayUsers = _users.skip(startIndex).take(_itemsPerPage).toList();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "System Users",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildFilterChip('Resident', 'resident'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Technician', 'technician'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // หัวตาราง (Table Header)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Action",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Body (Data Rows)
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? Center(
                    child: Text(
                      "No users found.",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayUsers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      return _buildUserRow(displayUsers[index]);
                    },
                  ),
          ),

          // Footer (Pagination)
          if (_users.isNotEmpty && _totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  color: _currentPage > 0
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                ),
                Text(
                  "Page ${_currentPage + 1} of $_totalPages",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24),
                  onPressed: _currentPage < _totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  color: _currentPage < _totalPages - 1
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String roleValue) {
    final isSelected = _currentRole == roleValue;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          _currentRole = roleValue;
          _fetchUsers();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
        .trim();
    final displayName = name.isEmpty ? (user['uid'] ?? 'Unknown User') : name;
    final isResident = _currentRole == 'resident';

    final residentInfo = user['resident_info'] ?? user;
    final roomNo = residentInfo['room_no'] ?? '-';
    final building = residentInfo['building'] ?? '-';

    final techInfo = user['technician_info'] ?? user;
    final rating = techInfo['rating']?.toString() ?? '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        children: [
          // คอลัมน์ Name (flex: 4)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isResident
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Icon(
                    isResident ? Icons.person : Icons.engineering,
                    size: 20,
                    color: isResident
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // คอลัมน์ Details (flex: 4)
          Expanded(
            flex: 4,
            child: isResident
                ? Text(
                    "Room $roomNo  |  Building $building",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),

          // คอลัมน์ Action (flex: 2)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _confirmDelete(user['uid'], displayName),
                icon: const Icon(Icons.delete_outline),
                color: AppColors.errorRed,
                tooltip: 'Delete User',
                splashRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
