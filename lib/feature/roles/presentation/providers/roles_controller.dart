import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_item.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/get_roles_usecase.dart';

class RolesController extends ChangeNotifier {
  RolesController(this._getCurrentSessionUseCase, this._getRolesUseCase);

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetRolesUseCase _getRolesUseCase;

  bool isLoading = false;
  String? errorMessage;
  List<RoleItem> roles = const [];
  bool _isDisposed = false;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final session = await _getCurrentSessionUseCase();
      if (_isDisposed) return;
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      roles = await _getRolesUseCase(organizationId: session.organizationId);
    } catch (error) {
      if (_isDisposed) return;
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _safeNotify();
      }
    }
  }

  void _safeNotify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
