import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_profile.dart';

class ProfileService {
  static const String baseUrl = 'https://localhost:7170/api';

  Future<HealthProfileResponseDto?> getMyProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return HealthProfileResponseDto.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching profile: $e');
      return null;
    }
  }
}