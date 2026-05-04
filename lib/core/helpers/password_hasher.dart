class PasswordHasher {
  const PasswordHasher._();

  static String hash(String value) {
    const int offsetBasis = 0x811C9DC5;
    const int prime = 0x01000193;
    var hash = offsetBasis;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * prime) & 0xFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }

  static bool matches({required String rawValue, required String hashedValue}) {
    return hash(rawValue) == hashedValue;
  }
}
