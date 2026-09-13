import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_employee.dart';
import 'package:mobile_orvexis/feature/attendance/domain/entities/attendance_entry_input.dart';
import 'package:mobile_orvexis/feature/attendance/presentation/providers/attendance_controller.dart';

class ProjectAttendanceScreen extends StatefulWidget {
  const ProjectAttendanceScreen({
    super.key,
    required this.projectId,
    required this.controller,
  });

  final String projectId;
  final AttendanceController controller;

  @override
  State<ProjectAttendanceScreen> createState() =>
      _ProjectAttendanceScreenState();
}

class _ProjectAttendanceScreenState extends State<ProjectAttendanceScreen> {
  DateTime _workDate = DateTime.now();
  final Set<String> _selectedIds = {};
  final Map<String, DateTime?> _checkIns = {};
  final Map<String, DateTime?> _checkOuts = {};
  final Map<String, TextEditingController> _notes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.controller.load(
      projectId: widget.projectId,
      workDate: _workDate,
    );
    if (!mounted) return;
    _checkIns.clear();
    _checkOuts.clear();
    for (final employee in widget.controller.employees) {
      _checkIns[employee.orgUserId] = employee.checkInAt;
      _checkOuts[employee.orgUserId] = employee.checkOutAt;
      _notes.putIfAbsent(
        employee.orgUserId,
        () => TextEditingController(text: employee.notes ?? ''),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.dispose();
    for (final controller in _notes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _workDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() => _workDate = selected);
    await _load();
  }

  Future<void> _pickTime(String id, bool isCheckIn) async {
    final current = isCheckIn ? _checkIns[id] : _checkOuts[id];
    final time = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    final dateTime = DateTime(
      _workDate.year,
      _workDate.month,
      _workDate.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isCheckIn) {
        _checkIns[id] = dateTime;
      } else {
        _checkOuts[id] = dateTime;
      }
    });
  }

  Future<void> _applyBatchTime(bool isCheckIn) async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un empleado.')),
      );
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dateTime = DateTime(
      _workDate.year,
      _workDate.month,
      _workDate.day,
      time.hour,
      time.minute,
    );
    setState(() {
      for (final id in _selectedIds) {
        if (isCheckIn) {
          _checkIns[id] = dateTime;
        } else if (_checkIns[id] != null) {
          _checkOuts[id] = dateTime;
        }
      }
    });
  }

  Future<void> _save() async {
    final entries = widget.controller.employees
        .map(
          (employee) => AttendanceEntryInput(
            orgUserId: employee.orgUserId,
            checkInAt: _checkIns[employee.orgUserId],
            checkOutAt: _checkOuts[employee.orgUserId],
            notes: _notes[employee.orgUserId]?.text,
          ),
        )
        .toList(growable: false);
    try {
      await widget.controller.save(
        projectId: widget.projectId,
        workDate: _workDate,
        entries: entries,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Asistencia guardada.')));
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Asistencia de obra')),
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
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today_rounded),
                            label: Text(_dateLabel(_workDate)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => _applyBatchTime(true),
                                  icon: const Icon(Icons.login_rounded),
                                  label: const Text('Entrada masiva'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => _applyBatchTime(false),
                                  icon: const Icon(Icons.logout_rounded),
                                  label: const Text('Salida masiva'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: widget.controller.employees.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay personal activo asignado a esta obra.',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: widget.controller.employees.length,
                              itemBuilder: (context, index) {
                                final employee =
                                    widget.controller.employees[index];
                                return _AttendanceEmployeeCard(
                                  employee: employee,
                                  selected: _selectedIds.contains(
                                    employee.orgUserId,
                                  ),
                                  checkInAt: _checkIns[employee.orgUserId],
                                  checkOutAt: _checkOuts[employee.orgUserId],
                                  notesController: _notes[employee.orgUserId]!,
                                  onSelected: (selected) => setState(() {
                                    selected
                                        ? _selectedIds.add(employee.orgUserId)
                                        : _selectedIds.remove(
                                            employee.orgUserId,
                                          );
                                  }),
                                  onPickCheckIn: () =>
                                      _pickTime(employee.orgUserId, true),
                                  onPickCheckOut: () =>
                                      _pickTime(employee.orgUserId, false),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: FilledButton.icon(
                        onPressed: widget.controller.isSaving ? null : _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          widget.controller.isSaving
                              ? 'Guardando...'
                              : 'Guardar asistencia',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AttendanceEmployeeCard extends StatelessWidget {
  const _AttendanceEmployeeCard({
    required this.employee,
    required this.selected,
    required this.checkInAt,
    required this.checkOutAt,
    required this.notesController,
    required this.onSelected,
    required this.onPickCheckIn,
    required this.onPickCheckOut,
  });
  final AttendanceEmployee employee;
  final bool selected;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final TextEditingController notesController;
  final ValueChanged<bool> onSelected;
  final VoidCallback onPickCheckIn;
  final VoidCallback onPickCheckOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (value) => onSelected(value ?? false),
              ),
              CircleAvatar(child: Text(employee.initials)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  employee.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickCheckIn,
                  icon: const Icon(Icons.login_rounded),
                  label: Text(
                    checkInAt == null ? 'Entrada' : _timeLabel(checkInAt!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: checkInAt == null ? null : onPickCheckOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    checkOutAt == null ? 'Salida' : _timeLabel(checkOutAt!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 1,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
        ],
      ),
    );
  }
}

String _timeLabel(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _dateLabel(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
