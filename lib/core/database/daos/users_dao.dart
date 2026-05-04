import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  Stream<List<User>> watchAllUsers() {
    return select(users).watch();
  }

  Future<User?> getUserById(String id) {
    return (select(
      users,
    )..where((tbl) => tbl.idUser.equals(id))).getSingleOrNull();
  }

  Future<User?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((tbl) => tbl.email.equals(email))).getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion entity) {
    return into(users).insert(entity);
  }

  Future<bool> updateUser(User entity) {
    return update(users).replace(entity);
  }

  Future<int> deleteUserById(String id) {
    return (delete(users)..where((tbl) => tbl.idUser.equals(id))).go();
  }
}
