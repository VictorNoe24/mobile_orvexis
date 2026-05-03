import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AuthCredentialsLocalDataSource {
  const AuthCredentialsLocalDataSource();

  Future<void> saveCredentials({
    required String userId,
    required String email,
    required String passwordHash,
  }) async {
    final records = await _readAll();
    records[email.trim().toLowerCase()] = {
      'userId': userId,
      'passwordHash': passwordHash,
    };
    await _writeAll(records);
  }

  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final records = await _readAll();
    return records[email.trim().toLowerCase()];
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'auth_credentials.json'));
  }

  Future<Map<String, dynamic>> _readAll() async {
    final file = await _getFile();
    if (!await file.exists()) return {};

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {};
  }

  Future<void> _writeAll(Map<String, dynamic> records) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(records));
  }
}
