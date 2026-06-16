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

  Future<Map<String, dynamic>> updateMyProfile(String token, HealthProfileResponseDto profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Profiles/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Cập nhật thất bại (${response.statusCode})'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Lỗi hệ thống (${response.statusCode})'
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ: $e'
      };
    }
  }

  Future<List<PatientConditionDto>> getConditions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => PatientConditionDto.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching conditions: $e');
    }
    return [];
  }

  Future<List<PatientAllergyDto>> getAllergies(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/allergies'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => PatientAllergyDto.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching allergies: $e');
    }
    return [];
  }
}