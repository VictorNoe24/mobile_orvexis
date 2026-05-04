import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';
import 'package:mobile_orvexis/feature/auth/presentation/providers/register_organization_controller.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/admin_registration_step.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/organization_registration_step.dart';

class RegisterOrganizationScreen extends StatefulWidget {
  const RegisterOrganizationScreen({super.key, required this.controller});

  final RegisterOrganizationController controller;

  @override
  State<RegisterOrganizationScreen> createState() =>
      _RegisterOrganizationScreenState();
}

class _RegisterOrganizationScreenState
    extends State<RegisterOrganizationScreen> {
  final _userFormKey = GlobalKey<FormState>();
  final _organizationFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _firstSurnameController = TextEditingController();
  final _secondSurnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _organizationNameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _taxIdController = TextEditingController();

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    _firstSurnameController.dispose();
    _secondSurnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationNameController.dispose();
    _logoUrlController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    FocusScope.of(context).unfocus();

    if (widget.controller.isUserStep) {
      final isValid = _userFormKey.currentState?.validate() ?? false;
      if (!isValid) return;

      if (!widget.controller.acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes aceptar los Terminos y Condiciones para continuar.',
            ),
          ),
        );
        return;
      }

      widget.controller.goToOrganizationStep();
      return;
    }

    final isValid = _organizationFormKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await _registerAdminAndOrganization();
  }

  Future<void> _registerAdminAndOrganization() async {
    try {
      await widget.controller.register(
        RegisterAdminOrganizationInput(
          adminUser: AdminUserRegistrationData(
            name: _nameController.text.trim(),
            firstSurname: _firstSurnameController.text.trim(),
            secondSurname: _nullIfEmpty(_secondSurnameController.text),
            email: _emailController.text.trim().toLowerCase(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          ),
          organization: OrganizationRegistrationData(
            name: _organizationNameController.text.trim(),
            logoUrl: _nullIfEmpty(_logoUrlController.text),
            taxId: _nullIfEmpty(_taxIdController.text),
            timezone: widget.controller.selectedTimezone,
            brandColorHex: _colorToHex(widget.controller.selectedBrandColor),
          ),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cuenta de administrador y organizacion creadas correctamente.',
          ),
        ),
      );

      context.go('/home');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible completar el registro: $error')),
      );
    }
  }

  void _handleBack() {
    if (!widget.controller.goBackStep()) {
      context.pop();
    }
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $label.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _requiredValidator(value, 'tu correo electronico');
    if (required != null) return required;

    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final required = _requiredValidator(value, 'tu contrasena');
    if (required != null) return required;

    if (value!.trim().length < 8) {
      return 'La contrasena debe tener al menos 8 caracteres.';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final required = _requiredValidator(value, 'la confirmacion de contrasena');
    if (required != null) return required;

    if (value!.trim() != _passwordController.text.trim()) {
      return 'Las contrasenas no coinciden.';
    }
    return null;
  }

  String? _logoUrlValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Ingresa una URL valida.';
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    return '#$hex';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: controller.isSaving ? null : _handleBack,
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              controller.isUserStep ? 'Crear Cuenta' : 'Crear Organizacion',
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: controller.isUserStep
                        ? AdminRegistrationStep(
                            key: const ValueKey('admin-step'),
                            formKey: _userFormKey,
                            nameController: _nameController,
                            firstSurnameController: _firstSurnameController,
                            secondSurnameController: _secondSurnameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            acceptedTerms: controller.acceptedTerms,
                            obscurePassword: controller.obscurePassword,
                            obscureConfirmPassword:
                                controller.obscureConfirmPassword,
                            onAcceptedTermsChanged: (value) {
                              controller.setAcceptedTerms(value ?? false);
                            },
                            onTogglePassword:
                                controller.togglePasswordVisibility,
                            onToggleConfirmPassword:
                                controller.toggleConfirmPasswordVisibility,
                            onGoToLogin: () => context.go('/login'),
                            requiredValidator: _requiredValidator,
                            emailValidator: _emailValidator,
                            passwordValidator: _passwordValidator,
                            confirmPasswordValidator: _confirmPasswordValidator,
                            onContinue: controller.isSaving
                                ? null
                                : _handlePrimaryAction,
                          )
                        : OrganizationRegistrationStep(
                            key: const ValueKey('organization-step'),
                            formKey: _organizationFormKey,
                            organizationNameController:
                                _organizationNameController,
                            logoUrlController: _logoUrlController,
                            taxIdController: _taxIdController,
                            selectedTimezone: controller.selectedTimezone,
                            selectedBrandColor: controller.selectedBrandColor,
                            isSaving: controller.isSaving,
                            requiredValidator: _requiredValidator,
                            logoUrlValidator: _logoUrlValidator,
                            onTimezoneChanged: (value) {
                              if (value == null) return;
                              controller.setTimezone(value);
                            },
                            onColorSelected: controller.setBrandColor,
                            onCreate: controller.isSaving
                                ? null
                                : _handlePrimaryAction,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
