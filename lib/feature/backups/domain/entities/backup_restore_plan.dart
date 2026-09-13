class BackupRestorePlan {
  const BackupRestorePlan({
    required this.stagingPath,
    required this.createdAt,
    required this.schemaVersion,
    required this.includesProjectImages,
    required this.includesPayrollReports,
  });

  final String stagingPath;
  final DateTime createdAt;
  final int schemaVersion;
  final bool includesProjectImages;
  final bool includesPayrollReports;
}
