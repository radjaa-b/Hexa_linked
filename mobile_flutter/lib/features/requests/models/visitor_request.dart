class VisitorRequest {
  final String? id;

  final String visitorName;
  final String visitorPhone;
  final String visitorEmail;

  final String purpose;
  final DateTime visitDate;
  final String startTime;
  final String endTime;
  final String? note;

  final String status;
  final DateTime? createdAt;

  VisitorRequest({
    this.id,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitorEmail,
    required this.purpose,
    required this.visitDate,
    required this.startTime,
    required this.endTime,
    this.note,
    this.status = 'PENDING',
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'visitor_name': visitorName,
    'visitor_phone': visitorPhone,
    'visitor_email': visitorEmail,
    'purpose': purpose,
    'visit_date':
        '${visitDate.year.toString().padLeft(4, '0')}-'
        '${visitDate.month.toString().padLeft(2, '0')}-'
        '${visitDate.day.toString().padLeft(2, '0')}',
    'start_time': startTime,
    'end_time': endTime,
    'note': note,
  };

  factory VisitorRequest.fromJson(Map<String, dynamic> json) {
    return VisitorRequest(
      id: json['id']?.toString(),
      visitorName: json['visitor_name'] ?? '',
      visitorPhone: json['visitor_phone'] ?? '',
      visitorEmail: json['visitor_email'] ?? '',
      purpose: json['purpose'] ?? '',
      visitDate: DateTime.parse(json['visit_date']),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      note: json['note'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
