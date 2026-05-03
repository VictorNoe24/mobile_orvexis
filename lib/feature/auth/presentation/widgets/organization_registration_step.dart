import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_brand_color_picker.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_dropdown_field.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_labeled_text_field.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_step_constants.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_step_progress.dart';

class OrganizationRegistrationStep extends StatelessWidget {
  const OrganizationRegistrationStep({
    super.key,
    required this.formKey,
    required this.organizationNameController,
    required this.logoUrlController,
    required this.taxIdController,
    required this.selectedTimezone,
    required this.selectedBrandColor,
    required this.isSaving,
    required this.requiredValidator,
    required this.logoUrlValidator,
    required this.onTimezoneChanged,
    required this.onColorSelected,
    required this.onCreate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController organizationNameController;
  final TextEditingController logoUrlController;
  final TextEditingController taxIdController;
  final String selectedTimezone;
  final Color selectedBrandColor;
  final bool isSaving;
  final String? Function(String?, String) requiredValidator;
  final String? Function(String?) logoUrlValidator;
  final ValueChanged<String?> onTimezoneChanged;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterStepProgress(currentStep: 1),
        const SizedBox(height: 18),
        Text(
          'Define tu identidad de marca.',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Cuentanos un poco mas sobre tu organizacion para empezar.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 26),
        Center(child: _OrganizationLogoPreview(controller: logoUrlController)),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              RegisterLabeledTextField(
                label: 'Nombre de la organizacion',
                hintText: 'e.g. Acme Corp',
                controller: organizationNameController,
                validator: (value) =>
                    requiredValidator(value, 'el nombre de la organizacion'),
              ),
              RegisterLabeledTextField(
                label: 'Logo URL',
                hintText: 'https://example.com/logo.png',
                controller: logoUrlController,
                keyboardType: TextInputType.url,
                validator: logoUrlValidator,
              ),
              RegisterLabeledTextField(
                label: 'RFC / Tax ID',
                hintText: 'Ingresa numero de ID',
                trailingLabel: 'Opcional',
                controller: taxIdController,
              ),
              RegisterDropdownField(
                label: 'Zona Horaria',
                value: selectedTimezone,
                items: registerTimezones,
                onChanged: onTimezoneChanged,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color de marca',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              RegisterBrandColorPicker(
                colors: registerBrandColors,
                selectedColor: selectedBrandColor,
                onSelected: onColorSelected,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onCreate,
                child: Text(isSaving ? 'Creando...' : 'Crear'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganizationLogoPreview extends StatelessWidget {
  const _OrganizationLogoPreview({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final logoUrl = value.text.trim();
        final uri = Uri.tryParse(logoUrl);
        final hasValidShape =
            logoUrl.isNotEmpty &&
            uri != null &&
            uri.hasScheme &&
            uri.hasAuthority &&
            (uri.scheme == 'http' || uri.scheme == 'https');

        return Container(
          width: 104,
          height: 104,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(
              color: hasValidShape ? colors.primary : colors.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: hasValidShape
              ? Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _LogoPreviewFallback(
                      icon: Icons.broken_image_outlined,
                      message: 'URL invalida',
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colors.primary,
                        ),
                      ),
                    );
                  },
                )
              : _LogoPreviewFallback(
                  icon: Icons.image_outlined,
                  message: logoUrl.isEmpty ? null : 'Revisa la URL',
                ),
        );
      },
    );
  }
}

class _LogoPreviewFallback extends StatelessWidget {
  const _LogoPreviewFallback({required this.icon, this.message});

  final IconData icon;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 32),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.15,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
