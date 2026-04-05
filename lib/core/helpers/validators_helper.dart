class ValidatorsHelper {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null) return null;

    if (value.length < min) {
      return 'Mínimo $min caracteres';
    }
    return null;
  }
}