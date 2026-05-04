import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_assigned_employee.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_detail.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_assigned_employees_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/remove_employee_from_project_usecase.dart';

class ProjectDetailController extends ChangeNotifier {
  ProjectDetailController(
    this._getCurrentSessionUseCase,
    this._getProjectDetailUseCase,
    this._getProjectAssignedEmployeesUseCase,
    this._removeEmployeeFromProjectUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetProjectDetailUseCase _getProjectDetailUseCase;
  final GetProjectAssignedEmployeesUseCase _getProjectAssignedEmployeesUseCase;
  final RemoveEmployeeFromProjectUseCase _removeEmployeeFromProjectUseCase;

  bool isLoading = false;
  bool isMutatingAssignments = false;
  String? errorMessage;
  ProjectDetail? detail;
  List<ProjectAssignedEmployee> assignedEmployees = const [];

  Future<void> load(String projectId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      detail = await _getProjectDetailUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
      );
      assignedEmployees = await _getProjectAssignedEmployeesUseCase(
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

  Future<void> removeAssignedEmployee({
    required String projectId,
    required String assignmentId,
  }) async {
    isMutatingAssignments = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _removeEmployeeFromProjectUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
        assignmentId: assignmentId,
      );

      await load(projectId);
    } finally {
      isMutatingAssignments = false;
      notifyListeners();
    }
  }
}
