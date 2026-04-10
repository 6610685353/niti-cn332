import 'dart:io';

class RepairRequestModel {
  // Step 1: Details
  String category;
  String title;
  String description;
  String location;
  List<File> images;

  // Step 2: Schedule
  DateTime? selectedDate;
  String? selectedTimeSlot;

  // Step 3: Confirmation (ราคาอาจจะมาจาก Backend หรือ Fixed ไว้)
  double inspectionFee;

  RepairRequestModel({
    this.category = '',
    this.title = '',
    this.description = '',
    this.location = 'Master Bedroom',
    this.images = const [],
    this.selectedDate,
    this.selectedTimeSlot,
    this.inspectionFee = 25.0,
  });

  // ใช้สำหรับอัปเดตข้อมูลบางส่วนโดยไม่ล้างข้อมูลเก่า
  RepairRequestModel copyWith({
    String? category,
    String? title,
    String? description,
    String? location,
    List<File>? images,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    double? inspectionFee,
  }) {
    return RepairRequestModel(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      images: images ?? this.images,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      inspectionFee: inspectionFee ?? this.inspectionFee,
    );
  }
}
