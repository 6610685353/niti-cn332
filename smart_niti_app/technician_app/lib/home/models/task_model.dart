import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String tag;
  final String time;
  final String location;
  final Color tagColor;
  final DateTime date;

  TaskModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.time,
    required this.location,
    required this.tagColor,
    required this.date,
  });
}

final List<TaskModel> homeMockTasks = [
  TaskModel(
    id: '#8821',
    title: 'AC Leakage - Room 402',
    tag: 'HIGH PRIORITY',
    time: '09:00 - 10:00 AM',
    location: 'Floor 4',
    tagColor: Colors.red,
    date: DateTime.now(),
  ),
  TaskModel(
    id: '#8822',
    title: 'Light Replacement - Lobby',
    tag: 'NORMAL',
    time: '11:30 - 12:00 PM',
    location: 'Lobby',
    tagColor: Colors.blue,
    date: DateTime.now(),
  ),
  TaskModel(
    id: '#8823',
    title: 'Door Lock Repair - Suite 204',
    tag: 'SCHEDULED',
    time: '01:00 - 02:00 PM',
    location: 'Floor 2',
    tagColor: Colors.orange,
    date: DateTime.now().add(const Duration(days: 1)),
  ),
];
