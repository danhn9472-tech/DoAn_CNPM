class PatientConditionDto {
  final int id;
  final String conditionName;
  final String? description; // Optional
  final String diagnosisDate; // yyyy-MM-dd

  PatientConditionDto({
    required this.id,
    required this.conditionName,
    this.description,
    required this.diagnosisDate,
  });

  factory PatientConditionDto.fromJson(Map<String, dynamic> json) {
    String diagDate = json['diagnosedDate'] ?? json['diagnosisDate'] ?? '';
    if (diagDate.isNotEmpty && diagDate.contains('T')) {
      diagDate = diagDate.split('T')[0];
    }
    return PatientConditionDto(
      id: (json['patientConditionId'] ?? json['id'] ?? 0) as int,
      conditionName: json['conditionName'] ?? '',
      description: json['notes'] ?? json['description'],
      diagnosisDate: diagDate,
    );
  }
}

class AddConditionDto {
  final int conditionId;
  final String? notes;
  final String? diagnosedDate; // yyyy-MM-dd

  AddConditionDto({required this.conditionId, this.notes, this.diagnosedDate});

  Map<String, dynamic> toJson() => {'conditionId': conditionId, 'notes': notes, 'diagnosedDate': diagnosedDate};
}

class ConditionSearchResponseDto {
  final int conditionId;
  final String conditionName;

  ConditionSearchResponseDto({required this.conditionId, required this.conditionName});

  factory ConditionSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return ConditionSearchResponseDto(
      conditionId: json['conditionId'] ?? json['ConditionId'] ?? 0,
      conditionName: json['conditionName'] ?? json['ConditionName'] ?? '',
    );
  }
}
