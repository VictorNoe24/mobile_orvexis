import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_compensation_form_data.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/update_employee_compensation_input.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employee_compensation_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/update_employee_compensation_usecase.dart';

class EmployeeCompensationController extends ChangeNotifier {
  EmployeeCompensationController(
    this._getCurrentSessionUseCase,
    this._getEmployeeCompensationUseCase,
    this._updateEmployeeCompensationUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetEmployeeCompensationUseCase _getEmployeeCompensationUseCase;
  final UpdateEmployeeCompensationUseCase _updateEmployeeCompensationUseCase;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  EmployeeCompensationFormData? formData;

  Future<void> initialize(String employeeId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      formData = await _getEmployeeCompensationUseCase(
        organizationId: session.organizationId,
        employeeId: employeeId,
      );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save({
    required String employeeId,
    required UpdateEmployeeCompensationInput input,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _updateEmployeeCompensationUseCase(
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
