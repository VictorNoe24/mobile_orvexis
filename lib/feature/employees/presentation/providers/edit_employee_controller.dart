import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_by_id_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_role_names_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/update_employee_usecase.dart';

class EditEmployeeController extends ChangeNotifier {
  EditEmployeeController(
    this._getCurrentSessionUseCase,
    this._getEmployeeByIdUseCase,
    this._getEmployeeRoleNamesUseCase,
    this._updateEmployeeUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetEmployeeByIdUseCase _getEmployeeByIdUseCase;
  final GetEmployeeRoleNamesUseCase _getEmployeeRoleNamesUseCase;
  final UpdateEmployeeUseCase _updateEmployeeUseCase;

  bool isLoading = false;
  bool isSaving = false;
  String? loadErrorMessage;
  List<String> availableRoleNames = const [];
  EmployeeFormData? formData;

  Future<void> initialize(String employeeId) async {
    isLoading = true;
    loadErrorMessage = null;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      final employeeData = await _getEmployeeByIdUseCase(
        organizationId: session.organizationId,
        employeeId: employeeId,
      );
      final roleNames = await _getEmployeeRoleNamesUseCase(
        organizationId: session.organizationId,
      );

      formData = employeeData;
      availableRoleNames = roleNames;
      if (!availableRoleNames.contains(employeeData.roleName)) {
        availableRoleNames = [...availableRoleNames, employeeData.roleName]..sort();
      }
    } catch (error) {
      loadErrorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadRoles() async {
    final session = await _getCurrentSessionUseCase();
    if (session == null) return;

    availableRoleNames = await _getEmployeeRoleNamesUseCase(
      organizationId: session.organizationId,
    );
    if (formData != null && !availableRoleNames.contains(formData!.roleName)) {
      availableRoleNames = [...availableRoleNames, formData!.roleName]..sort();
    }
    notifyListeners();
  }

  Future<void> update({
    required String employeeId,
    required CreateEmployeeInput input,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _updateEmployeeUseCase(
        organizationId: session.organizationId,
        employeeId: employeeId,
        input: input,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
