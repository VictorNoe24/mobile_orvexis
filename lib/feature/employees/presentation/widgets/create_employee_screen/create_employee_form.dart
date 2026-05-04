import 'package:flutter/material.dart';

class CreateEmployeeForm extends StatelessWidget {
  const CreateEmployeeForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.firstSurnameController,
    required this.secondSurnameController,
    required this.emailController,
    required this.phoneController,
    required this.availableRoleNames,
    required this.selectedRoleName,
    required this.rolesErrorMessage,
    required this.isActive,
    required this.isSaving,
    this.title = 'Nuevo empleado',
    this.description =
        'Completa los datos del empleado para agregarlo a la organizacion actual.',
    this.submitLabel = 'Guardar empleado',
    required this.onRoleChanged,
    required this.onCreateRole,
    required this.onManageRoles,
    required this.onActiveChanged,
    required this.onSubmit,
    required this.requiredValidator,
    required this.emailValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController firstSurnameController;
  final TextEditingController secondSurnameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final List<String> availableRoleNames;
  final String? selectedRoleName;
  final String? rolesErrorMessage;
  final bool isActive;
  final bool isSaving;
  final String title;
  final String description;
  final String submitLabel;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onCreateRole;
  final VoidCallback onManageRoles;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onSubmit;
  final String? Function(String?, String) requiredValidator;
  final String? Function(String?) emailValidator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _FormFieldBlock(
            label: 'Nombre(s)',
            child: TextFormField(
              controller: nameController,
              validator: (value) => requiredValidator(value, 'el nombre'),
              decoration: const InputDecoration(
                hintText: 'Ingresa el nombre',
              ),
            ),
          ),
          _FormFieldBlock(
            label: 'Primer apellido',
            child: TextFormField(
              controller: firstSurnameController,
              validator: (value) =>
                  requiredValidator(value, 'el primer apellido'),
              decoration: const InputDecoration(
                hintText: 'Ingresa el primer apellido',
              ),
            ),
          ),
          _FormFieldBlock(
            label: 'Segundo apellido (opcional)',
            child: TextFormField(
              controller: secondSurnameController,
              decoration: const InputDecoration(
                hintText: 'Ingresa el segundo apellido',
              ),
            ),
          ),
          _FormFieldBlock(
            label: 'Correo electronico',
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              decoration: const InputDecoration(
                hintText: 'empleado@company.com',
              ),
            ),
          ),
          _FormFieldBlock(
            label: 'Telefono',
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) => requiredValidator(value, 'el telefono'),
              decoration: const InputDecoration(
                hintText: '(777)0000000',
              ),
            ),
          ),
          _FormFieldBlock(
            label: 'Puesto / rol',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedRoleName,
                  items: availableRoleNames
                      .map(
                        (roleName) => DropdownMenuItem<String>(
                          value: roleName,
                          child: Text(roleName),
                        ),
                      )
                      .toList(),
                  onChanged:
                      isSaving || availableRoleNames.isEmpty ? null : onRoleChanged,
                  validator: (value) => requiredValidator(value, 'el puesto'),
                  decoration: InputDecoration(
                    hintText: availableRoleNames.isEmpty
                        ? 'No hay roles disponibles'
                        : 'Selecciona un rol',
                    errorText: rolesErrorMessage,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: isSaving ? null : onCreateRole,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Crear nuevo rol'),
                      ),
                      TextButton.icon(
                        onPressed: isSaving ? null : onManageRoles,
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Ver y editar roles'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (availableRoleNames.isEmpty && rolesErrorMessage == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Aun no hay roles disponibles. Crea uno para poder asignarlo al empleado.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(child: Text('Empleado activo')),
                  Switch(
                    value: isActive,
                    onChanged: isSaving ? null : onActiveChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isSaving || availableRoleNames.isEmpty ? null : onSubmit,
            child: Text(isSaving ? 'Guardando...' : submitLabel),
          ),
        ],
      ),
    );
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
