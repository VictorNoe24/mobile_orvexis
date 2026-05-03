import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_labeled_text_field.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_step_progress.dart';

class AdminRegistrationStep extends StatelessWidget {
  const AdminRegistrationStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.firstSurnameController,
    required this.secondSurnameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onAcceptedTermsChanged,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onGoToLogin,
    required this.requiredValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController firstSurnameController;
  final TextEditingController secondSurnameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final ValueChanged<bool?> onAcceptedTermsChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onGoToLogin;
  final String? Function(String?, String) requiredValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) confirmPasswordValidator;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterStepProgress(currentStep: 0),
        const SizedBox(height: 18),
        Text(
          'Unete hoy mismo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Introduce tus datos para crear una cuenta y empezar. Nombre completo',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              RegisterLabeledTextField(
                label: 'Nombre(s)',
                hintText: 'Ingresa tu nombre completo',
                controller: nameController,
                validator: (value) => requiredValidator(value, 'tu nombre'),
              ),
              RegisterLabeledTextField(
                label: 'Primer apellido',
                hintText: 'Ingresa tu primer apellido',
                controller: firstSurnameController,
                validator: (value) =>
                    requiredValidator(value, 'tu primer apellido'),
              ),
              RegisterLabeledTextField(
                label: 'Segundo apellido (opcional)',
                hintText: 'Ingresa tu segundo completo',
                controller: secondSurnameController,
              ),
              RegisterLabeledTextField(
                label: 'Correo electronico',
                hintText: 'name@company.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: emailValidator,
              ),
              RegisterLabeledTextField(
                label: 'Telefono',
                hintText: '(777)0000000',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => requiredValidator(value, 'tu telefono'),
              ),
              RegisterLabeledTextField(
                label: 'Contrasena',
                hintText: 'Ingresa tu contrasena',
                controller: passwordController,
                obscureText: obscurePassword,
                validator: passwordValidator,
                suffixIcon: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              RegisterLabeledTextField(
                label: 'Confirmar contrasena',
                hintText: 'Confirma tu contrasena',
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                validator: confirmPasswordValidator,
                suffixIcon: IconButton(
                  onPressed: onToggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: onAcceptedTermsChanged,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Acepto los Terminos y Condiciones y la Politica de Privacidad.',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onContinue,
                child: const Text('Siguiente'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: onGoToLogin,
                  child: const Text('¿Ya tienes una cuenta? Inicia sesion'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
