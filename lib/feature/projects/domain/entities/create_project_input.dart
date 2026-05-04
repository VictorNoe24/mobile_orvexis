class CreateProjectInput {
  const CreateProjectInput({
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.statusCode,
    this.code,
    this.imageSourcePath,
  });

  final String name;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String statusCode;
  final String? code;
  final String? imageSourcePath;
}
