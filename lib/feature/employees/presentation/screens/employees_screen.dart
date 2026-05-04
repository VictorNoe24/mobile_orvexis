import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employees_usecase.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/datasources/employees_local_datasource.dart';
import 'package:mobile_orvexis/feature/employees/infrastructure/repositories/employees_repository_impl.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/employees_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/employees_screen/employees_tab.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({
    super.key,
    required this.getCurrentSessionUseCase,
    required this.employeesLocalDataSource,
  });

  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final EmployeesLocalDataSource employeesLocalDataSource;

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late final EmployeesController _controller = EmployeesController(
    widget.getCurrentSessionUseCase,
    GetEmployeesUseCase(
      EmployeesRepositoryImpl(widget.employeesLocalDataSource),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeesTab(controller: _controller);
  }
}
