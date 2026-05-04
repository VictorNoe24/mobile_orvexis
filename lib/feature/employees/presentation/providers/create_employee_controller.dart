import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/create_employee_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_role_names_usecase.dart';

class CreateEmployeeController extends ChangeNotifier {
  CreateEmployeeController(
    this._getCurrentSessionUseCase,
    this._createEmployeeUseCase,
    this._getEmployeeRoleNamesUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final CreateEmployeeUseCase _createEmployeeUseCase;
  final GetEmployeeRoleNamesUseCase _getEmployeeRoleNamesUseCase;

  bool isLoadingRoles = false;
  bool isSaving = false;
  String? rolesErrorMessage;
  List<String> availableRoleNames = const [];

  Future<void> initialize() async {
    isLoadingRoles = true;
    rolesErrorMessage = null;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      availableRoleNames = await _getEmployeeRoleNamesUseCase(
        organizationId: session.organizationId,
      );
    } catch (error) {
      rolesErrorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingRoles = false;
      notifyListeners();
    }
  }

  Future<void> create(CreateEmployeeInput input) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _createEmployeeUseCase(
        organizationId: session.organizationId,
        input: input,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
