import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/create_project_controller.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, required this.controller});

  final CreateProjectController controller;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatusCode = 'active';

  @override
  void didUpdateWidget(covariant CreateProjectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      if (isStartDate) {
        _startDate = selectedDate;
        if (_endDate != null && _endDate!.isBefore(selectedDate)) {
          _endDate = null;
        }
      } else {
        _endDate = selectedDate;
      }
    });
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await widget.controller.create(
        CreateProjectInput(
          name: _nameController.text.trim(),
          code: _nullIfEmpty(_codeController.text),
          location: _locationController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          statusCode: _selectedStatusCode,
          imageSourcePath: widget.controller.selectedImagePath,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto creado correctamente.')),
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

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $label.';
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Seleccionar fecha';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final imagePath = widget.controller.selectedImagePath;

        return Scaffold(
          appBar: AppBar(title: const Text('Agregar proyecto')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nuevo proyecto',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guarda el proyecto en la base local e incluye una imagen almacenada en el telefono.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.controller.isSaving
                          ? null
                          : widget.controller.pickImage,
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath == null
                            ? _EmptyProjectImagePicker(colors: colors)
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: FilledButton.tonalIcon(
                                      onPressed: widget.controller.isSaving
                                          ? null
                                          : widget
                                                .controller
                                                .clearSelectedImage,
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text('Quitar'),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: widget.controller.isSaving
                          ? null
                          : widget.controller.pickImage,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(
                        imagePath == null
                            ? 'Seleccionar imagen'
                            : 'Cambiar imagen',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) =>
                          _requiredValidator(value, 'el nombre del proyecto'),
                      decoration: const InputDecoration(
                        labelText: 'Nombre del proyecto',
                        hintText: 'Ej. Elysium Towers Phase II',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Codigo interno',
                        hintText: 'Ej. PRJ-2026-001',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      validator: (value) => _requiredValidator(
                        value,
                        'la ubicacion del proyecto',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Ubicacion',
                        hintText: 'Ej. 450 Skyline Blvd, Austin, TX',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatusCode,
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('En curso'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Finalizado'),
                        ),
                      ],
                      onChanged: widget.controller.isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedStatusCode = value;
                              });
                            },
                      decoration: const InputDecoration(labelText: 'Estado'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.controller.isSaving
                                ? null
                                : () => _selectDate(isStartDate: true),
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: Text('Inicio: ${_formatDate(_startDate)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.controller.isSaving
                                ? null
                                : () => _selectDate(isStartDate: false),
                            icon: const Icon(Icons.event_available_rounded),
                            label: Text('Fin: ${_formatDate(_endDate)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.controller.isSaving
                          ? null
                          : _handleSubmit,
                      child: Text(
                        widget.controller.isSaving
                            ? 'Guardando...'
                            : 'Guardar proyecto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyProjectImagePicker extends StatelessWidget {
  const _EmptyProjectImagePicker({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.secondary.withValues(alpha: 0.72)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Toca para elegir una imagen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
