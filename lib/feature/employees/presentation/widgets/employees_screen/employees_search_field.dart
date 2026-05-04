import 'package:flutter/material.dart';

class EmployeesSearchField extends StatelessWidget {
  const EmployeesSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Buscar por nombre...',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}
