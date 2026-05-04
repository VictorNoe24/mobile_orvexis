import 'package:mobile_orvexis/feature/projects/domain/entities/project_activity_item.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_item.dart';

class ProjectDetail {
  const ProjectDetail({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.statusLabel,
    required this.imagePath,
    required this.code,
    required this.progressPercent,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.createdAtLabel,
    required this.assignedEmployeesCount,
    required this.activities,
  });

  final String id;
  final String name;
  final String location;
  final ProjectStatusCode status;
  final String statusLabel;
  final String? imagePath;
  final String? code;
  final int progressPercent;
  final String startDateLabel;
  final String endDateLabel;
  final String createdAtLabel;
  final int assignedEmployeesCount;
  final List<ProjectActivityItem> activities;
}
