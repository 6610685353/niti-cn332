import 'dart:io';

class RepairRequestModel {
  String category;
  String title;
  String description;
  String location;
  List<File> images;

  DateTime? selectedDate;
  String? selectedTimeSlot;

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
