import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/presentation/providers/edit_project_controller.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final EditProjectController controller;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatusCode = 'active';
  bool _didHydrate = false;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant EditProjectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _didHydrate = false;
      widget.controller.initialize(widget.projectId);
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _hydrateForm() {
    final data = widget.controller.formData;
    if (_didHydrate || data == null) {
      return;
    }

    _nameController.text = data.name;
    _codeController.text = data.code ?? '';
    _locationController.text = data.location;
    _startDate = data.startDate;
    _endDate = data.endDate;
    _selectedStatusCode = data.statusCode;
    _didHydrate = true;
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
      await widget.controller.update(
        projectId: widget.projectId,
        input: CreateProjectInput(
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
        const SnackBar(content: Text('Proyecto actualizado correctamente.')),
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
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (widget.controller.errorMessage != null ||
            widget.controller.formData == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editar proyecto')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.controller.errorMessage ??
                      'No se pudo cargar el proyecto.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        _hydrateForm();

        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final imagePath = widget.controller.selectedImagePath;

        return Scaffold(
          appBar: AppBar(title: const Text('Editar proyecto')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Actualizar proyecto',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edita la informacion general de la obra y su imagen.',
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
                            ? _EmptyEditProjectImagePicker(colors: colors)
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _EmptyEditProjectImagePicker(
                                              colors: colors,
                                            ),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Codigo interno',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      validator: (value) => _requiredValidator(
                        value,
                        'la ubicacion del proyecto',
                      ),
                      decoration: const InputDecoration(labelText: 'Ubicacion'),
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
                    OutlinedButton.icon(
                      onPressed: widget.controller.isSaving
                          ? null
                          : () => _selectDate(isStartDate: true),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text('Inicio: ${_formatDate(_startDate)}'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: widget.controller.isSaving
                          ? null
                          : () => _selectDate(isStartDate: false),
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text('Fin: ${_formatDate(_endDate)}'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.controller.isSaving
                          ? null
                          : _handleSubmit,
                      child: Text(
                        widget.controller.isSaving
                            ? 'Guardando...'
                            : 'Guardar cambios',
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

class _EmptyEditProjectImagePicker extends StatelessWidget {
  const _EmptyEditProjectImagePicker({required this.colors});

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
      child: const Center(
        child: Icon(
          Icons.add_photo_alternate_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}
