class RegisterAdminOrganizationInput {
  const RegisterAdminOrganizationInput({
    required this.adminUser,
    required this.organization,
  });

  final AdminUserRegistrationData adminUser;
  final OrganizationRegistrationData organization;
}

class AdminUserRegistrationData {
  const AdminUserRegistrationData({
    required this.name,
    required this.firstSurname,
    this.secondSurname,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String firstSurname;
  final String? secondSurname;
  final String email;
  final String phone;
  final String password;
}

class OrganizationRegistrationData {
  const OrganizationRegistrationData({
    required this.name,
    this.logoUrl,
    this.taxId,
    required this.timezone,
    required this.brandColorHex,
  });

  final String name;
  final String? logoUrl;
  final String? taxId;
  final String timezone;
  final String brandColorHex;
}
