import 'package:flutter/material.dart';

class CreateRoleForm extends StatelessWidget {
  const CreateRoleForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.isSaving,
    this.title = 'Crear rol',
    this.description =
        'Agrega un nuevo puesto para tu organizacion. Luego aparecera en el selector de empleados.',
    this.submitLabel = 'Guardar rol',
    this.isReadOnly = false,
    required this.onSubmit,
    required this.nameValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool isSaving;
  final String title;
  final String description;
  final String submitLabel;
  final bool isReadOnly;
  final VoidCallback onSubmit;
  final String? Function(String?) nameValidator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewCode = _normalizeRoleCode(nameController.text);

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 24),
          _FormFieldBlock(
            label: 'Nombre del rol',
            child: TextFormField(
              controller: nameController,
              readOnly: isReadOnly,
              validator: nameValidator,
              decoration: const InputDecoration(
                hintText: 'Ej. Supervisor de Operaciones',
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Codigo generado',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    previewCode.isEmpty ? 'sin-codigo' : previewCode,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isSaving || isReadOnly ? null : onSubmit,
            child: Text(isSaving ? 'Guardando...' : submitLabel),
          ),
        ],
      ),
    );
  }

  String _normalizeRoleCode(String roleName) {
    return roleName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class _FormFieldBlock extends StatelessWidget {
  const _FormFieldBlock({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
