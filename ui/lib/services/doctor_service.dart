import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class DoctorService {
  final StorageService _storageService = StorageService();
  static const String baseUrl = 'https://localhost:7170/api';

  Future<List<Map<String, dynamic>>> searchDoctors(String keyword) async {
    if (keyword.isEmpty) return [];
    try {
      final token = await _storageService.getToken();
      if (token == null) return [];
      
      final url = Uri.parse('$baseUrl/Doctors/search?keyword=$keyword');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Lỗi tìm kiếm bác sĩ: $e");
    }
    return [];
  }
}
