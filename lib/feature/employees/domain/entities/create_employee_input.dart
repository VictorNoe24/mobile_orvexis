class CreateEmployeeInput {
  const CreateEmployeeInput({
    required this.name,
    required this.firstSurname,
    this.secondSurname,
    required this.email,
    required this.phone,
    required this.roleName,
    required this.isActive,
  });

  final String name;
  final String firstSurname;
  final String? secondSurname;
  final String email;
  final String phone;
  final String roleName;
  final bool isActive;
}
