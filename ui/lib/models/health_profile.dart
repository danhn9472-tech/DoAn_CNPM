class HealthProfileResponseDto {
  final String fullName;
  final String dateOfBirth; // yyyy-MM-dd
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
      bloodType: json['bloodType'] ?? '',
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
      'bmi': bmi, // Include BMI to match HealthProfileResponseDto spec
    };
  }
}

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
    return PatientConditionDto(
      id: json['id'] as int,
      conditionName: json['conditionName'] ?? '',
      description: json['description'],
      diagnosisDate: json['diagnosisDate'] ?? '',
    );
  }
}

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
      id: json['id'] as int,
      drugName: json['drugName'] ?? '',
      severity: json['severity'] ?? '',
      symptoms: json['symptoms'],
    );
  }
}

// DTOs for adding new data
class AddConditionDto {
  final int conditionId;
  final String? notes;
  final String? diagnosedDate; // yyyy-MM-dd

  AddConditionDto({required this.conditionId, this.notes, this.diagnosedDate});

  Map<String, dynamic> toJson() => {'conditionId': conditionId, 'notes': notes, 'diagnosedDate': diagnosedDate};
}

class AddAllergyDto {
  final int drugId;
  final String severity; // High, Moderate, Low
  final String? symptoms;

  AddAllergyDto({required this.drugId, required this.severity, this.symptoms});

  Map<String, dynamic> toJson() => {'drugId': drugId, 'severity': severity, 'symptoms': symptoms};
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