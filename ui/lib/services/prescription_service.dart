import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prescription.dart';
import 'storage_service.dart';

class PrescriptionService {
  final StorageService _storageService = StorageService();
  static const String baseUrl = 'https://localhost:7170/api';

  Future<List<Prescription>> getPrescriptions({String? status}) async {
    final token = await _storageService.getToken();
    if (token == null) throw Exception('Token not found');

    String url = '$baseUrl/Prescriptions';
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Prescription.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load prescriptions. Status: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> deletePrescription(int id) async {
    final token = await _storageService.getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Prescriptions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã xóa đơn thuốc'};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Xóa đơn thuốc thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<Map<String, dynamic>> getPrescriptionDetail(int id) async {
    final token = await _storageService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/Prescriptions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load prescription detail. Status: ${response.statusCode}');
    }
  }
}
