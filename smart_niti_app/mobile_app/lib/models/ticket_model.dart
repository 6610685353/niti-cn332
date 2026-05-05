class TicketModel {
  final String? id;
  final String title;
  final String description;
  final String? mechanic;
  final String status;

  TicketModel({
    this.id,
    required this.title,
    required this.description,
    this.mechanic,
    this.status = 'pending',
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String?,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mechanic: json['mechanic'] as String?,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'mechanic': mechanic,
    };
  }
}