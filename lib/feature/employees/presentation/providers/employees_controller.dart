import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee.dart';
import 'package:mobile_orvexis/feature/employees/domain/entities/employee_filter.dart';
import 'package:mobile_orvexis/feature/employees/domain/usecases/get_employees_usecase.dart';

class EmployeesController extends ChangeNotifier {
  EmployeesController(
    this._getCurrentSessionUseCase,
    this._getEmployeesUseCase,
  );

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final GetEmployeesUseCase _getEmployeesUseCase;
  static const int _pageSize = 6;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final List<Employee> _employees = [];
  List<Employee> get employees => List.unmodifiable(_employees);

  EmployeeFilter selectedFilter = EmployeeFilter.all;
  bool isInitialLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  int _currentPage = 0;
  Timer? _searchDebounce;
  String? _organizationId;
  bool _isDisposed = false;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    refresh();
  }

  Future<void> refresh() async {
    final organizationId = await _resolveOrganizationId();
    if (_isDisposed) return;

    if (organizationId == null) {
      errorMessage = 'No se encontro la organizacion de la sesion actual.';
      isInitialLoading = false;
      _safeNotifyListeners();
      return;
    }

    _currentPage = 0;
    hasMore = true;
    errorMessage = null;
    _employees.clear();
    isInitialLoading = true;
    _safeNotifyListeners();

    try {
      final page = await _getEmployeesUseCase(
        organizationId: organizationId,
        query: searchController.text,
        filter: selectedFilter,
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (_isDisposed) return;
      _employees.addAll(page.items);
      hasMore = page.hasMore;
    } catch (error) {
      if (_isDisposed) return;
      errorMessage = 'No fue posible cargar empleados: $error';
    } finally {
      if (!_isDisposed) {
        isInitialLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isDisposed || isInitialLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    _safeNotifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final organizationId = await _resolveOrganizationId();
      if (_isDisposed) return;
      if (organizationId == null) {
        errorMessage = 'No se encontro la organizacion de la sesion actual.';
        return;
      }
      final page = await _getEmployeesUseCase(
        organizationId: organizationId,
        query: searchController.text,
        filter: selectedFilter,
        page: nextPage,
        pageSize: _pageSize,
      );
      if (_isDisposed) return;
      _currentPage = nextPage;
      _employees.addAll(page.items);
      hasMore = page.hasMore;
    } catch (error) {
      if (_isDisposed) return;
      errorMessage = 'No fue posible cargar mas empleados: $error';
    } finally {
      if (!_isDisposed) {
        isLoadingMore = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<String?> _resolveOrganizationId() async {
    if (_organizationId != null) return _organizationId;
    final session = await _getCurrentSessionUseCase();
    _organizationId = session?.organizationId;
    return _organizationId;
  }

  void selectFilter(EmployeeFilter filter) {
    if (_isDisposed || selectedFilter == filter) return;
    selectedFilter = filter;
    refresh();
  }

  void _onSearchChanged() {
    if (_isDisposed) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), refresh);
  }

  void _onScroll() {
    if (_isDisposed || !scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      loadMore();
    }
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
