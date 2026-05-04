class ProjectAssignedEmployee {
  const ProjectAssignedEmployee({
    required this.assignmentId,
    required this.orgUserId,
    required this.userId,
    required this.name,
    required this.role,
    required this.initials,
    required this.assignedLabel,
  });

  final String assignmentId;
  final String orgUserId;
  final String userId;
  final String name;
  final String role;
  final String initials;
  final String assignedLabel;
}
