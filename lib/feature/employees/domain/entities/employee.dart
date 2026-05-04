class Employee {
  const Employee({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.startDate,
    required this.isActive,
  });

  final String id;
  final String initials;
  final String name;
  final String role;
  final String startDate;
  final bool isActive;
}
