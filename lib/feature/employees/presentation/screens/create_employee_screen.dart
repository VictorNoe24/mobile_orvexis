import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/create_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/create_employee_screen/create_employee_form.dart';

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({
    super.key,
    required this.controller,
  });

  final CreateEmployeeController controller;

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firstSurnameController = TextEditingController();
  final _secondSurnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  String? _selectedRoleName;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void didUpdateWidget(covariant CreateEmployeeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.dispose();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    _firstSurnameController.dispose();
    _secondSurnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await widget.controller.create(
        CreateEmployeeInput(
          name: _nameController.text.trim(),
          firstSurname: _firstSurnameController.text.trim(),
          secondSurname: _nullIfEmpty(_secondSurnameController.text),
          email: _emailController.text.trim().toLowerCase(),
          phone: _phoneController.text.trim(),
          roleName: _selectedRoleName!.trim(),
          isActive: _isActive,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado creado correctamente.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _handleCreateRole() async {
    final createdRoleName = await context.push<String>('/roles/create');
    if (!mounted || createdRoleName == null) return;

    await widget.controller.initialize();
    if (!mounted) return;

    setState(() {
      _selectedRoleName = widget.controller.availableRoleNames.contains(
            createdRoleName,
          )
          ? createdRoleName
          : _selectedRoleName;
    });
  }

  Future<void> _handleManageRoles() async {
    await context.push('/roles');
    if (!mounted) return;
    await widget.controller.initialize();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $label.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _requiredValidator(value, 'el correo electronico');
    if (required != null) return required;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Agregar empleado')),
          body: widget.controller.isLoadingRoles
              ? const Center(child: CircularProgressIndicator())
              : CreateEmployeeForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  firstSurnameController: _firstSurnameController,
                  secondSurnameController: _secondSurnameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  availableRoleNames: widget.controller.availableRoleNames,
                  selectedRoleName: _selectedRoleName,
                  rolesErrorMessage: widget.controller.rolesErrorMessage,
                  isActive: _isActive,
                  isSaving: widget.controller.isSaving,
                  title: 'Nuevo empleado',
                  description:
                      'Completa los datos del empleado para agregarlo a la organizacion actual.',
                  submitLabel: 'Guardar empleado',
                  onRoleChanged: (value) {
                    setState(() {
                      _selectedRoleName = value;
                    });
                  },
                  onCreateRole: _handleCreateRole,
                  onManageRoles: _handleManageRoles,
                  onActiveChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  onSubmit: _handleSubmit,
                  requiredValidator: _requiredValidator,
                  emailValidator: _emailValidator,
                ),
        );
      },
    );
  }
}
