enum ScheduleItemType { task, breakTime }

class ScheduleModel {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String startTime;
  final String duration;
  final bool isActive;
  final ScheduleItemType type;

  ScheduleModel({
    required this.id,
    this.title = '',
    this.location = '',
    required this.date,
    required this.startTime,
    this.duration = '',
    this.isActive = false,
    this.type = ScheduleItemType.task,
  });
}

final DateTime today = DateTime.now();
final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

//Mock Data
final List<ScheduleModel> scheduleMockData = [
  // Yesterday
  ScheduleModel(
    id: 'Y001',
    title: 'Completed: Pump Check',
    location: 'Basement B1',
    date: yesterday,
    startTime: '10:00',
    duration: '30 min',
  ),

  // Today
  ScheduleModel(
    id: 'T001',
    title: 'AC Repair & Maintenance',
    location: 'Unit 402, North Tower',
    date: today,
    startTime: '01:00',
    duration: '60 min',
    isActive: true,
  ),
  ScheduleModel(
    id: 'T002',
    title: 'Light Replacement',
    location: 'Main Lobby',
    date: today,
    startTime: '11:30',
    duration: '30 min',
  ),
  ScheduleModel(
    id: 'TB01',
    date: today,
    startTime: '12:00',
    type: ScheduleItemType.breakTime,
  ),
  ScheduleModel(
    id: 'T003',
    title: 'Door Lock Repair',
    location: 'Suite 101',
    date: today,
    startTime: '14:00',
    duration: '45 min',
  ),

  // Tomorrow
  ScheduleModel(
    id: 'TM01',
    title: 'Monthly Fire Alarm Test',
    location: 'Every Floor',
    date: tomorrow,
    startTime: '08:30',
    duration: '120 min',
  ),
  ScheduleModel(
    id: 'TMB01',
    date: tomorrow,
    startTime: '12:00',
    type: ScheduleItemType.breakTime,
  ),
  ScheduleModel(
    id: 'TM02',
    title: 'CCTV Inspection',
    location: 'Security Room',
    date: tomorrow,
    startTime: '13:30',
    duration: '60 min',
  ),

  // Day After Tomorrow
  ScheduleModel(
    id: 'AT01',
    title: 'Pool Cleaning',
    location: 'Clubhouse',
    date: today.add(const Duration(days: 2)),
    startTime: '07:00',
    duration: '180 min',
  ),
];
