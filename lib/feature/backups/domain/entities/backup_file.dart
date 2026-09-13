class BackupFile {
  const BackupFile({
    required this.path,
    required this.createdAt,
    required this.sizeInBytes,
  });

  final String path;
  final DateTime createdAt;
  final int sizeInBytes;
}
