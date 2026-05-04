import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/auth_session.dart';
import 'package:mobile_orvexis/feature/auth/domain/entities/login_input.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/login_usecase.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._loginUseCase);

  final LoginUseCase _loginUseCase;

  bool obscurePassword = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      return await _loginUseCase(
        LoginInput(email: email.trim(), password: password.trim()),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
