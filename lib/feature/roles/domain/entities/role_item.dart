class RoleItem {
  const RoleItem({
    required this.id,
    required this.name,
    required this.code,
    required this.isSystem,
    required this.isActive,
  });

  final String id;
  final String name;
  final String code;
  final bool isSystem;
  final bool isActive;
}
