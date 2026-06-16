import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  // Lưu Token sau khi đăng nhập thành công
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Lấy Token để gắn vào Header API
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Xóa Token khi đăng xuất
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}