import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/create_project_usecase.dart';

class CreateProjectController extends ChangeNotifier {
  CreateProjectController(
    this._getCurrentSessionUseCase,
    this._createProjectUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final ImagePicker _imagePicker = ImagePicker();

  bool isSaving = false;
  String? selectedImagePath;

  Future<void> pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (image == null) {
      return;
    }

    selectedImagePath = image.path;
    notifyListeners();
  }

  void clearSelectedImage() {
    if (selectedImagePath == null) {
      return;
    }

    selectedImagePath = null;
    notifyListeners();
  }

  Future<void> create(CreateProjectInput input) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _createProjectUseCase(
        organizationId: session.organizationId,
        input: input,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
