class ProjectAssignableEmployee {
  const ProjectAssignableEmployee({
    required this.orgUserId,
    required this.userId,
    required this.name,
    required this.role,
    required this.initials,
    required this.isActive,
  });

  final String orgUserId;
  final String userId;
  final String name;
  final String role;
  final String initials;
  final bool isActive;
}
