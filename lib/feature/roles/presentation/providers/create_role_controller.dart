import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/roles/domain/entities/create_role_input.dart';
import 'package:mobile_orvexis/feature/roles/domain/usecases/create_role_usecase.dart';

class CreateRoleController extends ChangeNotifier {
  CreateRoleController(this._getCurrentSessionUseCase, this._createRoleUseCase);

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final CreateRoleUseCase _createRoleUseCase;

  bool isSaving = false;

  Future<String> createRole(String name) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      return await _createRoleUseCase(
        organizationId: session.organizationId,
        input: CreateRoleInput(name: name.trim()),
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
