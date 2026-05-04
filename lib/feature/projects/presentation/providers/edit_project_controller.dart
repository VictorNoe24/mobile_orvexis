import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/create_project_input.dart';
import 'package:mobile_orvexis/feature/projects/domain/entities/project_form_data.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/get_project_form_data_usecase.dart';
import 'package:mobile_orvexis/feature/projects/domain/usecases/update_project_usecase.dart';

class EditProjectController extends ChangeNotifier {
  EditProjectController(
    this._getCurrentSessionUseCase,
    this._getProjectFormDataUseCase,
    this._updateProjectUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetProjectFormDataUseCase _getProjectFormDataUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final ImagePicker _imagePicker = ImagePicker();

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  ProjectFormData? formData;
  String? selectedImagePath;
  String? _originalImagePath;
  bool removeCurrentImage = false;

  Future<void> initialize(String projectId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      formData = await _getProjectFormDataUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
      );
      selectedImagePath = formData?.imagePath;
      _originalImagePath = formData?.imagePath;
      removeCurrentImage = false;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (image == null) {
      return;
    }

    selectedImagePath = image.path;
    removeCurrentImage = false;
    notifyListeners();
  }

  void clearSelectedImage() {
    selectedImagePath = null;
    removeCurrentImage = true;
    notifyListeners();
  }

  Future<void> update({
    required String projectId,
    required CreateProjectInput input,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      final session = await _getCurrentSessionUseCase();
      if (session == null) {
        throw Exception('No se encontro una sesion activa.');
      }

      await _updateProjectUseCase(
        organizationId: session.organizationId,
        projectId: projectId,
        input: CreateProjectInput(
          name: input.name,
          location: input.location,
          startDate: input.startDate,
          endDate: input.endDate,
          statusCode: input.statusCode,
          code: input.code,
          imageSourcePath: removeCurrentImage
              ? ''
              : selectedImagePath == _originalImagePath
              ? null
              : selectedImagePath,
        ),
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
