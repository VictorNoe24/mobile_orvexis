import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/feature/roles/presentation/providers/roles_controller.dart';
import 'package:mobile_orvexis/feature/roles/presentation/widgets/roles_screen/role_list_tile.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({
    super.key,
    required this.controller,
  });

  final RolesController controller;

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _openCreateRole() async {
    final createdRole = await context.push<String>('/roles/create');
    if (!mounted || createdRole == null) return;
    await widget.controller.load();
  }

  Future<void> _openEditRole(String roleId) async {
    final didUpdate = await context.push<bool>('/roles/$roleId/edit');
    if (!mounted || didUpdate != true) return;
    await widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Roles')),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreateRole,
            child: const Icon(Icons.add_rounded),
          ),
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
              : widget.controller.roles.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aun no hay roles registrados para esta organizacion.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final role = widget.controller.roles[index];
                    return RoleListTile(
                      role: role,
                      onTap: role.isSystem ? null : () => _openEditRole(role.id),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: widget.controller.roles.length,
                ),
        );
      },
    );
  }
}
