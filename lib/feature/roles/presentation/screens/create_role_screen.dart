import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/create_role_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/widgets/create_role_screen/create_role_form.dart';

class CreateRoleScreen extends StatefulWidget {
  const CreateRoleScreen({
    super.key,
    required this.controller,
  });

  final CreateRoleController controller;

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void didUpdateWidget(covariant CreateRoleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.dispose();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      final createdRoleName = await widget.controller.createRole(
        _nameController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol creado correctamente.')),
      );
      context.pop(createdRoleName);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
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
        return Scaffold(
          appBar: AppBar(title: const Text('Crear rol')),
          body: CreateRoleForm(
            formKey: _formKey,
            nameController: _nameController,
            isSaving: widget.controller.isSaving,
            onSubmit: _handleSubmit,
            nameValidator: _nameValidator,
          ),
        );
      },
    );
  }
}
