// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_users_dao.dart';

// ignore_for_file: type=lint
mixin _$OrgUsersDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $GlobalStatusesTable get globalStatuses => attachedDatabase.globalStatuses;
  $UsersTable get users => attachedDatabase.users;
  $OrgUsersTable get orgUsers => attachedDatabase.orgUsers;
  OrgUsersDaoManager get managers => OrgUsersDaoManager(this);
}

class OrgUsersDaoManager {
  final _$OrgUsersDaoMixin _db;
  OrgUsersDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$GlobalStatusesTableTableManager get globalStatuses =>
      $$GlobalStatusesTableTableManager(
        _db.attachedDatabase,
        _db.globalStatuses,
      );
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$OrgUsersTableTableManager get orgUsers =>
      $$OrgUsersTableTableManager(_db.attachedDatabase, _db.orgUsers);
}
