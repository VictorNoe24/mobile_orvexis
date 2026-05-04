import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/create_employee_input.dart';
import 'package:mobile_orvexis/feature/employees/presentation/providers/edit_employee_controller.dart';
import 'package:mobile_orvexis/feature/employees/presentation/widgets/create_employee_screen/create_employee_form.dart';

class EditEmployeeScreen extends StatefulWidget {
  const EditEmployeeScreen({
    super.key,
    required this.employeeId,
    required this.controller,
  });

  final String employeeId;
  final EditEmployeeController controller;

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firstSurnameController = TextEditingController();
  final _secondSurnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  String? _selectedRoleName;
  bool _didSeedForm = false;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.employeeId);
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

  void _seedFormIfNeeded() {
    if (_didSeedForm || widget.controller.formData == null) return;

    final data = widget.controller.formData!;
    _nameController.text = data.name;
    _firstSurnameController.text = data.firstSurname;
    _secondSurnameController.text = data.secondSurname ?? '';
    _emailController.text = data.email;
    _phoneController.text = data.phone;
    _selectedRoleName = data.roleName;
    _isActive = data.isActive;
    _didSeedForm = true;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await widget.controller.update(
        employeeId: widget.employeeId,
        input: CreateEmployeeInput(
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
        const SnackBar(content: Text('Empleado actualizado correctamente.')),
      );
      context.pop(true);
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

    await widget.controller.reloadRoles();
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
    await widget.controller.reloadRoles();
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
        _seedFormIfNeeded();

        return Scaffold(
          appBar: AppBar(title: const Text('Editar empleado')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.loadErrorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.loadErrorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : CreateEmployeeForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  firstSurnameController: _firstSurnameController,
                  secondSurnameController: _secondSurnameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  availableRoleNames: widget.controller.availableRoleNames,
                  selectedRoleName: _selectedRoleName,
                  rolesErrorMessage: null,
                  isActive: _isActive,
                  isSaving: widget.controller.isSaving,
                  title: 'Editar empleado',
                  description:
                      'Actualiza los datos del empleado dentro de la organizacion actual.',
                  submitLabel: 'Guardar cambios',
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
