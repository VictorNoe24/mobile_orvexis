import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_orvexis/core/database/app_database.dart';
import 'package:mobile_orvexis/core/database/queries/global_statuses_queries.dart';
import 'package:mobile_orvexis/feature/auth/domain/usecases/has_active_session_usecase.dart';

class SplashScreen extends StatefulWidget {
  final AppDatabase database;
  final HasActiveSessionUseCase hasActiveSessionUseCase;

  const SplashScreen({
    super.key,
    required this.database,
    required this.hasActiveSessionUseCase,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  late final GlobalStatusesQueries _globalStatusesQueries =
      GlobalStatusesQueries(widget.database);

  @override
  void initState() {
    super.initState();
    _validateDatabase();
  }

  Future<void> _validateDatabase() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tableExists = await _globalStatusesQueries.tableExists();

      if (!tableExists) {
        throw Exception('La tabla global_statuses no fue creada.');
      }

      final globalStatuses = await _globalStatusesQueries.getAllOrdered();

      if (globalStatuses.isEmpty) {
        throw Exception(
          'La base de datos existe, pero no se encontraron registros sembrados.',
        );
      }

      final hasActiveSession = await widget.hasActiveSessionUseCase();

      if (!mounted) return;
      context.go(hasActiveSession ? '/home' : '/start');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_bottom_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preparando Mobile Orvexis',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLoading
                        ? 'Comprobando que la base de datos y los seeders esten listos.'
                        : _errorMessage ??
                              'No fue posible validar la base de datos.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage ??
                                    'Ocurrio un error al validar la informacion.',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _validateDatabase,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
