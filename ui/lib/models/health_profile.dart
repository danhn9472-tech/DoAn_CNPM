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