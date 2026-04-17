import 'package:drift/drift.dart';

import '../app_database.dart';
import '../global_status_defaults.dart';

class GlobalStatusSeedItem {
  final String idGlobalStatus;
  final String entity;
  final String code;
  final String name;
  final String? category;
  final int? sortOrder;
  final bool isTerminal;
  final bool isActive;

  const GlobalStatusSeedItem({
    required this.idGlobalStatus,
    required this.entity,
    required this.code,
    required this.name,
    this.category,
    this.sortOrder,
    this.isTerminal = false,
    this.isActive = true,
  });

  GlobalStatusesCompanion toCompanion() {
    return GlobalStatusesCompanion(
      idGlobalStatus: Value(idGlobalStatus),
      entity: Value(entity),
      code: Value(code),
      name: Value(name),
      category: Value(category),
      sortOrder: Value(sortOrder),
      isTerminal: Value(isTerminal),
      isActive: Value(isActive),
    );
  }
}

const List<GlobalStatusSeedItem> globalStatusSeedData = [
  GlobalStatusSeedItem(
    idGlobalStatus: GlobalStatusDefaults.activeId,
    entity: 'system',
    code: 'active',
    name: 'Activo',
    category: 'availability',
    sortOrder: 1,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-inactive',
    entity: 'system',
    code: 'inactive',
    name: 'Inactivo',
    category: 'availability',
    sortOrder: 2,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-draft',
    entity: 'system',
    code: 'draft',
    name: 'Borrador',
    category: 'lifecycle',
    sortOrder: 3,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-approved',
    entity: 'system',
    code: 'approved',
    name: 'Aprobado',
    category: 'lifecycle',
    sortOrder: 4,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-rejected',
    entity: 'system',
    code: 'rejected',
    name: 'Rechazado',
    category: 'lifecycle',
    sortOrder: 5,
    isTerminal: true,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-paid',
    entity: 'system',
    code: 'paid',
    name: 'Pagado',
    category: 'lifecycle',
    sortOrder: 6,
    isTerminal: true,
  ),
  GlobalStatusSeedItem(
    idGlobalStatus: 'global-status-system-cancelled',
    entity: 'system',
    code: 'cancelled',
    name: 'Cancelado',
    category: 'lifecycle',
    sortOrder: 7,
    isTerminal: true,
  ),
];
