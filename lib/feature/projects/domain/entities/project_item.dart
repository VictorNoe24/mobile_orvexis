enum ProjectStatusCode { active, inProgress, completed }

class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    required this.location,
    required this.dateLabel,
    required this.status,
    required this.statusLabel,
    required this.imagePath,
    this.code,
  });

  final String id;
  final String name;
  final String location;
  final String dateLabel;
  final ProjectStatusCode status;
  final String statusLabel;
  final String? imagePath;
  final String? code;
}
