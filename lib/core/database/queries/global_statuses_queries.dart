import 'package:drift/drift.dart' show OrderingTerm;

import '../app_database.dart';

class GlobalStatusesQueries {
  final AppDatabase database;

  const GlobalStatusesQueries(this.database);

  Future<bool> tableExists() async {
    final result = await database.customSelect('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = 'global_statuses'
    ''').getSingleOrNull();

    return result != null;
  }

  Future<List<GlobalStatuse>> getAllOrdered() {
    return (database.select(database.globalStatuses)..orderBy([
          (tbl) => OrderingTerm.asc(tbl.sortOrder),
          (tbl) => OrderingTerm.asc(tbl.name),
        ]))
        .get();
  }

  Stream<List<GlobalStatuse>> watchAllOrdered() {
    return (database.select(database.globalStatuses)..orderBy([
          (tbl) => OrderingTerm.asc(tbl.sortOrder),
          (tbl) => OrderingTerm.asc(tbl.name),
        ]))
        .watch();
  }

  int duplicateCodeCount(List<GlobalStatuse> statuses) {
    final codeCounts = <String, int>{};

    for (final status in statuses) {
      codeCounts.update(status.code, (value) => value + 1, ifAbsent: () => 1);
    }

    return codeCounts.values.where((count) => count > 1).length;
  }
}
