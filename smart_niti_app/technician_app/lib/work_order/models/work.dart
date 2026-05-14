class WorkOrder {
  final String id;
  final String status;
  final String category;
  final bool isUrgent;
  final String title;
  final String description;
  final String location;
  final String scheduledTime;
  final bool? isAccepted;
  final String? assigneeName;
  final String? assigneeRole;
  final int? rating;
  final String? residentName;

  WorkOrder({
    required this.id,
    required this.status,
    required this.category,
    required this.isUrgent,
    required this.title,
    required this.description,
    required this.location,
    required this.scheduledTime,
    this.isAccepted = false,
    this.assigneeName,
    this.assigneeRole,
    this.rating,
    this.residentName,
  });
}

// ──────────────────────────────────────────────
// Mock Data — งานทั้งหมด
// ──────────────────────────────────────────────
final List<WorkOrder> mockWorkOrdersList = [
  // ── งาน Active (แสดงบนหน้า Home) ───────────

  // งานที่ยังไม่ได้ Accept → ขึ้น Pending + ปุ่ม Accept Job
  WorkOrder(
    id: '#TK-8825',
    status: 'Pending',
    category: 'ELECTRICAL',
    isUrgent: true,
    isAccepted: false,
    title: 'Power Outlet Not Working',
    description:
        'Multiple power outlets in the office area are not functioning. Residents report complete loss of power on the east wall.',
    location: 'Room 210, Floor 2',
    scheduledTime: 'Today, 11:00 AM',
  ),

  // งานที่ Accept แล้ว แต่ยังไม่เสร็จ → ขึ้น Repairing + ปุ่ม Update Progress
  WorkOrder(
    id: '#TK-8823',
    status: 'Repairing',
    category: 'HVAC',
    isUrgent: true,
    isAccepted: true,
    title: 'AC Leakage & Unusual Noise',
    description:
        'The unit in the master bedroom is leaking water from the front panel. Resident reports a grinding sound when the compressor kicks in. Requires immediate inspection.',
    location: 'Room 402, Floor 4',
    scheduledTime: 'Today, 09:00 AM',
    assigneeName: 'Alex Johnson',
    assigneeRole: 'Senior Technician',
  ),

  // งานที่ Accept แล้ว รอเริ่ม → ขึ้น Pending + ปุ่ม Update Progress
  WorkOrder(
    id: '#TK-8826',
    status: 'Pending',
    category: 'PLUMBING',
    isUrgent: false,
    isAccepted: false,
    title: 'Water Pressure Issue',
    description:
        'Low water pressure reported in multiple units on floor 3. Needs inspection of the main supply valve.',
    location: 'Room 315, Floor 3',
    scheduledTime: 'Today, 02:00 PM',
    assigneeName: 'Robert Chen',
    assigneeRole: 'Certified Plumber',
  ),

  // ── งาน Done / Cancelled (แสดงเฉพาะหน้า History) ──
  WorkOrder(
    id: '#TK-8821',
    status: 'Done',
    category: 'PLUMBING',
    isUrgent: false,
    isAccepted: true,
    title: 'Leaking Pipe Repair',
    description: 'Fixed leaking pipe under the sink.',
    location: 'Room 101, Floor 1',
    scheduledTime: 'May 12, 2023 • 10:30 AM',
    assigneeName: 'Robert Chen',
    assigneeRole: 'Certified Plumber',
    rating: 5,
    residentName: 'Somchai Jaidee',
  ),
  WorkOrder(
    id: '#TK-8822',
    status: 'Cancelled',
    category: 'HVAC',
    isUrgent: false,
    isAccepted: false,
    title: 'AC Annual Maintenance',
    description: 'Routine maintenance check.',
    location: 'Room 205, Floor 2',
    scheduledTime: 'April 05, 2023 • 02:15 PM',
    assigneeName: 'Sarah Jenkins',
    assigneeRole: 'HVAC Specialist',
    rating: null,
    residentName: 'Nattaporn Srisuk',
  ),
  WorkOrder(
    id: '#TK-8824',
    status: 'Done',
    category: 'ELECTRICAL',
    isUrgent: false,
    isAccepted: true,
    title: 'Kitchen Circuit Short',
    description: 'Fixing short circuit in the kitchen area.',
    location: 'Room 304, Floor 3',
    scheduledTime: 'March 15, 2023 • 09:00 AM',
    assigneeName: 'Marcus Webb',
    assigneeRole: 'Master Electrician',
    rating: 5,
    residentName: 'Wiroj Tanaka',
  ),
];
