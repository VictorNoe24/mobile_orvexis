import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/role_form_data.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/get_role_by_id_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/update_role_usecase.dart';

class EditRoleController extends ChangeNotifier {
  EditRoleController(
    this._getCurrentSessionUseCase,
    this._getRoleByIdUseCase,
    this._updateRoleUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetRoleByIdUseCase _getRoleByIdUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  RoleFormData? formData;
  bool _isDisposed = false;

  Future<void> initialize(String roleId) async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final session = await _getCurrentSessionUseCase();
      if (_isDisposed) return;
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      formData = await _getRoleByIdUseCase(
        organizationId: session.organizationId,
        roleId: roleId,
      );
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

  Future<String> updateRole({
    required String roleId,
    required String name,
  }) async {
    isSaving = true;
    _safeNotify();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      return await _updateRoleUseCase(
        organizationId: session.organizationId,
        roleId: roleId,
        input: CreateRoleInput(name: name),
      );
    } finally {
      if (!_isDisposed) {
        isSaving = false;
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
