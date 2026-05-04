class ProjectFormData {
  const ProjectFormData({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.statusCode,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String? code;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String statusCode;
  final String? imagePath;
}
