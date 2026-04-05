import 'package:uuid/uuid.dart';

class UuidHelper {
  static const Uuid _uuid = Uuid();

  static String generate() {
    return _uuid.v4();
  }
}