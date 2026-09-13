import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_file.dart';
import 'package:mobile_orvexis/feature/backups/domain/entities/backup_restore_plan.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

class BackupLocalDataSource {
  BackupLocalDataSource(this._database);

  static const _databaseFileName = 'payroll_system_dev.sqlite';
  static const _manifestFileName = 'manifest.json';
  static const _formatVersion = 1;

  final AppDatabase _database;

  Future<BackupFile> createBackup() async {
    final temporaryDirectory = await getTemporaryDirectory();
    final timestamp = DateTime.now();
    final stamp = _fileTimestamp(timestamp);
    final workDirectory = Directory(
      p.join(temporaryDirectory.path, 'orvexis_backup_$stamp'),
    );
    await workDirectory.create(recursive: true);

    final databaseSnapshot = File(
      p.join(workDirectory.path, _databaseFileName),
    );
    await _database.customStatement(
      "VACUUM INTO '${_escapeSql(databaseSnapshot.path)}'",
    );

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final archive = Archive();
    await _addFileToArchive(archive, databaseSnapshot, _databaseFileName);
    await _addDirectoryToArchive(
      archive,
      Directory(p.join(documentsDirectory.path, 'project_images')),
      'project_images',
    );
    await _addDirectoryToArchive(
      archive,
      Directory(p.join(documentsDirectory.path, 'payroll_reports')),
      'payroll_reports',
    );

    final manifest = jsonEncode({
      'formatVersion': _formatVersion,
      'createdAt': timestamp.toUtc().toIso8601String(),
      'schemaVersion': _database.schemaVersion,
      'includesProjectImages': true,
      'includesPayrollReports': true,
    });
    final manifestBytes = utf8.encode(manifest);
    archive.addFile(
      ArchiveFile(_manifestFileName, manifestBytes.length, manifestBytes),
    );

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw StateError('No se pudo crear el archivo de respaldo.');
    }

    final backup = File(
      p.join(temporaryDirectory.path, 'respaldo_orvexis_$stamp.zip'),
    );
    await backup.writeAsBytes(zipBytes, flush: true);
    await workDirectory.delete(recursive: true);

    return BackupFile(
      path: backup.path,
      createdAt: timestamp,
      sizeInBytes: await backup.length(),
    );
  }

  Future<String?> exportBackup(BackupFile backup) async {
    if (Platform.isIOS) {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Respaldo de Orvexis',
          subject: 'Respaldo de datos',
          text: 'Respaldo de datos de Orvexis.',
          files: [XFile(backup.path, mimeType: 'application/zip')],
          fileNameOverrides: [p.basename(backup.path)],
        ),
      );
      return null;
    }

    final directoryPath = await getDirectoryPath(
      confirmButtonText: 'Guardar respaldo aquí',
    );
    if (directoryPath == null) return null;

    final destination = p.join(directoryPath, p.basename(backup.path));
    await File(backup.path).copy(destination);
    return destination;
  }

  Future<BackupRestorePlan?> selectBackupForRestore() async {
    final typeGroup = Platform.isIOS
        ? const XTypeGroup(
            label: 'Respaldo Orvexis',
            uniformTypeIdentifiers: ['public.zip-archive'],
          )
        : const XTypeGroup(
            label: 'Respaldo Orvexis',
            extensions: ['zip'],
            mimeTypes: ['application/zip'],
          );
    final selectedFile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (selectedFile == null) return null;

    final zipBytes = await selectedFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    final manifestFile = archive.findFile(_manifestFileName);
    final databaseFile = archive.findFile(_databaseFileName);
    if (manifestFile == null || databaseFile == null) {
      throw const FormatException('No es un respaldo válido de Orvexis.');
    }

    final manifest = _readManifest(manifestFile);
    final formatVersion = manifest['formatVersion'];
    if (formatVersion != _formatVersion) {
      throw const FormatException(
        'Este respaldo usa un formato no compatible.',
      );
    }

    final schemaVersion = manifest['schemaVersion'];
    if (schemaVersion is! int || schemaVersion > _database.schemaVersion) {
      throw const FormatException(
        'El respaldo fue creado por una versión más nueva de la aplicación.',
      );
    }
    final createdAtValue = manifest['createdAt'];
    final createdAt = createdAtValue is String
        ? DateTime.tryParse(createdAtValue)?.toLocal()
        : null;
    if (createdAt == null) {
      throw const FormatException('El respaldo no tiene una fecha válida.');
    }

    final temporaryDirectory = await getTemporaryDirectory();
    final stagingDirectory = Directory(
      p.join(
        temporaryDirectory.path,
        'orvexis_restore_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await stagingDirectory.create(recursive: true);
    try {
      for (final file in archive.files) {
        if (!file.isFile) continue;
        final output = _safeOutputFile(stagingDirectory, file.name);
        await output.parent.create(recursive: true);
        await output.writeAsBytes(file.content as List<int>, flush: true);
      }
      _validateSqliteFile(
        File(p.join(stagingDirectory.path, _databaseFileName)),
      );
    } catch (_) {
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
      rethrow;
    }

    return BackupRestorePlan(
      stagingPath: stagingDirectory.path,
      createdAt: createdAt,
      schemaVersion: schemaVersion,
      includesProjectImages: manifest['includesProjectImages'] == true,
      includesPayrollReports: manifest['includesPayrollReports'] == true,
    );
  }

  Future<void> restore(BackupRestorePlan plan) async {
    final stagingDirectory = Directory(plan.stagingPath);
    final stagedDatabase = File(p.join(plan.stagingPath, _databaseFileName));
    if (!await stagedDatabase.exists()) {
      throw StateError('El respaldo preparado ya no está disponible.');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(
      p.join(documentsDirectory.path, _databaseFileName),
    );
    final token = DateTime.now().microsecondsSinceEpoch.toString();
    final previousDatabase = File('${databaseFile.path}.before_restore_$token');
    final assetNames = ['project_images', 'payroll_reports'];
    final previousDirectories = <String, Directory>{};

    try {
      if (await databaseFile.exists()) {
        await databaseFile.rename(previousDatabase.path);
      }
      for (final name in assetNames) {
        final current = Directory(p.join(documentsDirectory.path, name));
        if (await current.exists()) {
          final previous = Directory('${current.path}.before_restore_$token');
          await current.rename(previous.path);
          previousDirectories[name] = previous;
        }
      }

      await stagedDatabase.copy(databaseFile.path);
      for (final name in assetNames) {
        final stagedDirectory = Directory(p.join(plan.stagingPath, name));
        if (await stagedDirectory.exists()) {
          await _copyDirectory(
            stagedDirectory,
            Directory(p.join(documentsDirectory.path, name)),
          );
        }
      }
    } catch (_) {
      if (await databaseFile.exists()) {
        await databaseFile.delete();
      }
      if (await previousDatabase.exists()) {
        await previousDatabase.rename(databaseFile.path);
      }
      for (final name in assetNames) {
        final current = Directory(p.join(documentsDirectory.path, name));
        if (await current.exists()) {
          await current.delete(recursive: true);
        }
        final previous = previousDirectories[name];
        if (previous != null && await previous.exists()) {
          await previous.rename(current.path);
        }
      }
      rethrow;
    } finally {
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
    }

    if (await previousDatabase.exists()) {
      await previousDatabase.delete();
    }
    for (final directory in previousDirectories.values) {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }

  Future<void> _addFileToArchive(
    Archive archive,
    File file,
    String archivePath,
  ) async {
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
  }

  Future<void> _addDirectoryToArchive(
    Archive archive,
    Directory directory,
    String archiveRoot,
  ) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final relativePath = p.relative(entity.path, from: directory.path);
      await _addFileToArchive(
        archive,
        entity,
        p.join(archiveRoot, relativePath),
      );
    }
  }

  Map<String, dynamic> _readManifest(ArchiveFile file) {
    final decoded = jsonDecode(utf8.decode(file.content as List<int>));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El manifiesto del respaldo no es válido.');
    }
    return decoded;
  }

  File _safeOutputFile(Directory stagingDirectory, String archivePath) {
    final normalizedPath = p.normalize(archivePath);
    if (p.isAbsolute(normalizedPath) ||
        normalizedPath.startsWith('..${p.separator}')) {
      throw const FormatException(
        'El respaldo contiene una ruta no permitida.',
      );
    }
    final outputPath = p.join(stagingDirectory.path, normalizedPath);
    if (!p.isWithin(stagingDirectory.path, outputPath)) {
      throw const FormatException(
        'El respaldo contiene una ruta no permitida.',
      );
    }
    return File(outputPath);
  }

  void _validateSqliteFile(File file) {
    final database = sqlite.sqlite3.open(file.path);
    try {
      final integrity = database.select('PRAGMA integrity_check');
      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        throw const FormatException(
          'La base de datos del respaldo está dañada.',
        );
      }
    } finally {
      database.close();
    }
  }

  Future<void> _copyDirectory(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final entity in from.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relativePath = p.relative(entity.path, from: from.path);
      final target = File(p.join(to.path, relativePath));
      await target.parent.create(recursive: true);
      await entity.copy(target.path);
    }
  }

  String _fileTimestamp(DateTime value) {
    String pad(int number) => number.toString().padLeft(2, '0');
    return '${value.year}${pad(value.month)}${pad(value.day)}_${pad(value.hour)}${pad(value.minute)}${pad(value.second)}';
  }

  String _escapeSql(String value) => value.replaceAll("'", "''");
}
