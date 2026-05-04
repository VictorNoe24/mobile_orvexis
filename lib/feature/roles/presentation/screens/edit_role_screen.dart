import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/edit_role_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/widgets/create_role_screen/create_role_form.dart';

class EditRoleScreen extends StatefulWidget {
  const EditRoleScreen({
    super.key,
    required this.roleId,
    required this.controller,
  });

  final String roleId;
  final EditRoleController controller;

  @override
  State<EditRoleScreen> createState() => _EditRoleScreenState();
}

class _EditRoleScreenState extends State<EditRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _didSeed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.roleId);
  }

  @override
  void didUpdateWidget(covariant EditRoleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final didChangeController = oldWidget.controller != widget.controller;
    final didChangeRole = oldWidget.roleId != widget.roleId;
    if (!didChangeController && !didChangeRole) return;

    if (didChangeController) {
      oldWidget.controller.dispose();
    }

    _didSeed = false;
    widget.controller.initialize(widget.roleId);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _seedIfNeeded() {
    if (_didSeed || widget.controller.formData == null) return;
    _nameController.text = widget.controller.formData!.name;
    _didSeed = true;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await widget.controller.updateRole(
        roleId: widget.roleId,
        name: _nameController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol actualizado correctamente.')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el nombre del rol.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        _seedIfNeeded();
        final formData = widget.controller.formData;

        return Scaffold(
          appBar: AppBar(title: const Text('Editar rol')),
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : CreateRoleForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  isSaving: widget.controller.isSaving,
                  title: 'Editar rol',
                  description: formData?.isSystem == true
                      ? 'Este es un rol del sistema y no se puede modificar.'
                      : 'Corrige el nombre del rol para que se refleje en toda la organizacion.',
                  submitLabel: 'Guardar cambios',
                  isReadOnly: formData?.isSystem == true,
                  onSubmit: _handleSubmit,
                  nameValidator: _nameValidator,
                ),
        );
      },
    );
  }
}
