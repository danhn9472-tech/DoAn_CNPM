class PatientAllergyDto {
  final int id;
  final String drugName;
  final String severity; // High, Moderate, Low
  final String? symptoms; // Optional

  PatientAllergyDto({
    required this.id,
    required this.drugName,
    required this.severity,
    this.symptoms,
  });

  factory PatientAllergyDto.fromJson(Map<String, dynamic> json) {
    return PatientAllergyDto(
      id: (json['allergyId'] ?? json['id'] ?? 0) as int,
      drugName: json['drugName'] ?? '',
      severity: json['severity'] ?? '',
      symptoms: json['symptoms'],
    );
  }
}

class AddAllergyDto {
  final int drugId;
  final String severity; // High, Moderate, Low
  final String? symptoms;

  AddAllergyDto({required this.drugId, required this.severity, this.symptoms});

  Map<String, dynamic> toJson() => {'drugId': drugId, 'severity': severity, 'symptoms': symptoms};
}
