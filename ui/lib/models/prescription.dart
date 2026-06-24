class Prescription {
  final int prescriptionId;
  final String diagnosis;
  final DateTime createdDate;
  final String status;
  final String doctorName;
  final int drugCount;
  final bool hasConflict; // Thêm cờ đánh dấu đơn thuốc có xung đột

  Prescription({
    required this.prescriptionId,
    required this.diagnosis,
    required this.createdDate,
    required this.status,
    required this.doctorName,
    required this.drugCount,
    this.hasConflict = false,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescriptionId'] ?? 0,
      diagnosis: json['diagnosis'] ?? 'N/A',
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      status: json['status'] ?? 'Unknown',
      doctorName: json['doctorName'] ?? 'N/A',
      drugCount: json['drugCount'] ?? 0,
      hasConflict: json['hasConflict'] ?? false, 
    );
  }

  bool get isActive => status == 'DangUong';
}
