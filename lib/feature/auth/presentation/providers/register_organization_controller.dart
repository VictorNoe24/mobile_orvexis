import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/register_admin_organization_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/register_admin_with_organization_usecase.dart';
import 'package:mobile_orvexis/feature/auth/presentation/widgets/register_step_constants.dart';

class RegisterOrganizationController extends ChangeNotifier {
  RegisterOrganizationController(this._registerAdminWithOrganizationUseCase);

  final RegisterAdminWithOrganizationUseCase
  _registerAdminWithOrganizationUseCase;

  int currentStep = 0;
  bool acceptedTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isSaving = false;
  String selectedTimezone = registerTimezones.first;
  Color selectedBrandColor = registerBrandColors.first;

  bool get isUserStep => currentStep == 0;

  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void goToOrganizationStep() {
    currentStep = 1;
    notifyListeners();
  }

  bool goBackStep() {
    if (currentStep == 0) {
      return false;
    }

    currentStep = 0;
    notifyListeners();
    return true;
  }

  void setTimezone(String value) {
    selectedTimezone = value;
    notifyListeners();
  }

  void setBrandColor(Color color) {
    selectedBrandColor = color;
    notifyListeners();
  }

  Future<void> register(RegisterAdminOrganizationInput input) async {
    isSaving = true;
    notifyListeners();

    try {
      await _registerAdminWithOrganizationUseCase(input);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
