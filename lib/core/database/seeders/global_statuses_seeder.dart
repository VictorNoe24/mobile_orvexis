import '../app_database.dart';
import 'global_status_seed_data.dart';

class GlobalStatusesSeeder {
  final AppDatabase db;

  GlobalStatusesSeeder(this.db);

  Future<void> seed() async {
    final existingStatuses = await db.select(db.globalStatuses).get();
    final existingCodes = existingStatuses.map((row) => row.code).toSet();

    final missingItems = globalStatusSeedData
        .where((item) => !existingCodes.contains(item.code))
        .map((item) => item.toCompanion())
        .toList();

    if (missingItems.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(db.globalStatuses, missingItems);
    });
  }

  Future<void> seedByEntity(String entity) async {
    final existingStatuses = await (db.select(
      db.globalStatuses,
    )..where((tbl) => tbl.entity.equals(entity))).get();
    final existingCodes = existingStatuses.map((row) => row.code).toSet();

    final filteredData = globalStatusSeedData
        .where(
          (item) => item.entity == entity && !existingCodes.contains(item.code),
        )
        .map((item) => item.toCompanion())
        .toList();

    if (filteredData.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(db.globalStatuses, filteredData);
    });
  }
}
