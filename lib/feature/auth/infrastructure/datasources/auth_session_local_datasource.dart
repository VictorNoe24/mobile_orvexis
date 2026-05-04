import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';

class AuthSessionLocalDataSource {
  const AuthSessionLocalDataSource();

  Future<void> saveSession(AuthSession session) async {
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode({
        'userId': session.userId,
        'email': session.email,
        'organizationId': session.organizationId,
      }),
    );
  }

  Future<AuthSession?> getSession() async {
    final file = await _getFile();
    if (!await file.exists()) return null;

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;

    final userId = decoded['userId'] as String?;
    final email = decoded['email'] as String?;
    final organizationId = decoded['organizationId'] as String?;

    if (userId == null || email == null || organizationId == null) return null;

    return AuthSession(
      userId: userId,
      email: email,
      organizationId: organizationId,
    );
  }

  Future<bool> hasSession() async {
    return (await getSession()) != null;
  }

  Future<void> clearSession() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'auth_session.json'));
  }
}
