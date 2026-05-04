class RoleFormData {
  const RoleFormData({
    required this.id,
    required this.name,
    required this.code,
    required this.isSystem,
  });

  final String id;
  final String name;
  final String code;
  final bool isSystem;
}
