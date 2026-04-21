class MaintenanceRequest {
  final String? id;
  final String unitNumber;
  final String maintenanceType;
  final String? title;
  final String category;
  final String description;
  final String priority;
  final DateTime? preferredDate;
  final String status;
  final DateTime? createdAt;

  MaintenanceRequest({
    this.id,
    required this.unitNumber,
    required this.maintenanceType,
    this.title,
    required this.category,
    required this.description,
    required this.priority,
    this.preferredDate,
    this.status = 'pending',
    this.createdAt,
  });

  // 👉 what Flutter SENDS to backend
  Map<String, dynamic> toJson() => {
    'unit_number': unitNumber,
    'maintenance_type': maintenanceType,
    'title': title,
    'category': category,
    'description': description,
    'priority': priority,
    'preferred_date': preferredDate?.toIso8601String(),
    'status': status,
  };

  // 👉 what Flutter RECEIVES from backend
  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequest(
        id: json['id']?.toString(),
        unitNumber: json['unit_number'] ?? '',
        maintenanceType: json['maintenance_type'] ?? json['category'] ?? '',
        title: json['title'],
        category: json['category'] ?? json['maintenance_type'] ?? '',
        description: json['description'] ?? '',
        priority: json['priority'] ?? 'medium',
        preferredDate: json['preferred_date'] != null
            ? DateTime.tryParse(json['preferred_date'])
            : null,
        status: json['status'] ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}
