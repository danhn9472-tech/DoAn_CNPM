// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_profile.dart'; // Assuming this path

class ProfileService {
  static const String baseUrl = 'https://localhost:7170/api'; // Cập nhật theo port thực tế của backend

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
        return HealthProfileResponseDto.fromJson(jsonDecode(response.body));
      } else {
        // Handle error or return null
        print('Failed to load profile: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting profile: $e');
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

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật hồ sơ thành công'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Cập nhật hồ sơ thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  Future<List<PatientConditionDto>> getConditions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/conditions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body);
        return List<PatientConditionDto>.from(l.map((model) => PatientConditionDto.fromJson(model)));
      } else {
        print('Failed to load conditions: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting conditions: $e');
      return [];
    }
  }

  Future<List<ConditionSearchResponseDto>> searchConditions(String token, String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/conditions/search?keyword=$keyword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body);
        return List<ConditionSearchResponseDto>.from(l.map((model) => ConditionSearchResponseDto.fromJson(model)));
      }
    } catch (e) {
      print('Error searching conditions: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> addCondition(String token, AddConditionDto condition) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Profiles/conditions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(condition.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Thêm bệnh lý nền thành công'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Thêm bệnh lý nền thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  Future<List<PatientAllergyDto>> getAllergies(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Profiles/allergies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body);
        return List<PatientAllergyDto>.from(l.map((model) => PatientAllergyDto.fromJson(model)));
      } else {
        print('Failed to load allergies: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting allergies: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addAllergy(String token, AddAllergyDto allergy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Profiles/allergies'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(allergy.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Thêm dị ứng thuốc thành công'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Thêm dị ứng thuốc thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteCondition(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Profiles/conditions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Xóa bệnh lý nền thành công'};
      } else {
        String message = 'Xóa bệnh lý nền thất bại';
        try {
          final errorData = jsonDecode(response.body);
          message = errorData['message'] ?? message;
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }
}