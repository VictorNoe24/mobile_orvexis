import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assignable_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/assign_employees_to_project_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_assignable_project_employees_usecase.dart';

class AssignProjectEmployeesController extends ChangeNotifier {
  AssignProjectEmployeesController(
    this._getCurrentSessionUseCase,
    this._getAssignableProjectEmployeesUseCase,
    this._assignEmployeesToProjectUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetAssignableProjectEmployeesUseCase
  _getAssignableProjectEmployeesUseCase;
  final AssignEmployeesToProjectUseCase _assignEmployeesToProjectUseCase;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<ProjectAssignableEmployee> availableEmployees = const [];
  final Set<String> selectedOrgUserIds = <String>{};

  Future<void> initialize(String projectId) async {
    isLoading = true;
    errorMessage = null;
    selectedOrgUserIds.clear();
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      availableEmployees = await _getAssignableProjectEmployeesUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
      );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleEmployee(String orgUserId) {
    if (selectedOrgUserIds.contains(orgUserId)) {
      selectedOrgUserIds.remove(orgUserId);
    } else {
      selectedOrgUserIds.add(orgUserId);
    }
    notifyListeners();
  }

  Future<void> assign(String projectId) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _assignEmployeesToProjectUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
        orgUserIds: selectedOrgUserIds.toList(growable: false),
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
