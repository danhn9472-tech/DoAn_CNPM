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
}