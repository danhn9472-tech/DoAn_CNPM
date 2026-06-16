class HealthProfileResponseDto {
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String address;
  final String bloodType;
  final double height;
  final double weight;
  final double bmi;

  HealthProfileResponseDto({
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.bmi,
  });

  factory HealthProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return HealthProfileResponseDto(
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      bloodType: json['bloodType'] ?? 'N/A',
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'address': address,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
    };
  }
}

class PatientConditionDto {
  final int id;
  final String conditionName;
  final String? description;

  PatientConditionDto({required this.id, required this.conditionName, this.description});

  factory PatientConditionDto.fromJson(Map<String, dynamic> json) {
    return PatientConditionDto(
      id: json['id'],
      conditionName: json['conditionName'] ?? '',
      description: json['description'],
    );
  }
}

class PatientAllergyDto {
  final int id;
  final String drugName;
  final String severity; // High, Moderate, Low
  final String? symptoms;

  PatientAllergyDto({required this.id, required this.drugName, required this.severity, this.symptoms});

  factory PatientAllergyDto.fromJson(Map<String, dynamic> json) {
    return PatientAllergyDto(
      id: json['id'],
      drugName: json['drugName'] ?? '',
      severity: json['severity'] ?? 'Low',
      symptoms: json['symptoms'],
    );
  }
}