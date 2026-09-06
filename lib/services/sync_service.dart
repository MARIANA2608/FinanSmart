import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../database/app_database.dart';

/// Procesa y sincroniza las operaciones creadas
/// mientras FinanSmart se encuentra sin conexión.
class SyncService {
  static const String _defaultBaseUrl =
      String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final AppDatabase database;
  final String baseUrl;

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  bool _processing = false;

  SyncService({
    required this.database,
    this.baseUrl = _defaultBaseUrl,
  });

  /// Comienza a observar los cambios de conectividad.
  Future<void> startMonitoring() async {
    await _connectivitySubscription?.cancel();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(
      (results) async {
        if (_hasConnection(results)) {
          await processPendingOperations();
        }
      },
    );

    // También comprueba la conexión al iniciar.
    final currentResults =
        await _connectivity.checkConnectivity();

    if (_hasConnection(currentResults)) {
      await processPendingOperations();
    }
  }

  /// Detiene el observador de conectividad.
  Future<void> stopMonitoring() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  bool _hasConnection(
    List<ConnectivityResult> results,
  ) {
    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  /// Procesa las operaciones todavía pendientes.
  ///
  /// Cada una admite como máximo tres intentos.
  Future<void> processPendingOperations() async {
    if (_processing) {
      return;
    }

    _processing = true;

    try {
      final operations = await database
          .select(database.pendingOperations)
          .get();

      for (final operation in operations) {
        if (operation.syncStatus == 'synced') {
          continue;
        }

        if (operation.syncStatus == 'failed') {
          continue;
        }

        if (operation.retryCount >= 3) {
          continue;
        }

        await _sendOperation(operation);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _sendOperation(
    PendingOperation operation,
  ) async {
    try {
      // Espera creciente:
      // intento 0 -> inmediato
      // intento 1 -> 2 segundos
      // intento 2 -> 4 segundos
      if (operation.retryCount > 0) {
        final seconds =
            1 << operation.retryCount;

        await Future.delayed(
          Duration(seconds: seconds),
        );
      }

      late http.Response response;

      switch (operation.operationType) {
        case 'create_request':
          response = await http
              .post(
                Uri.parse(
                  '$baseUrl/api/solicitudes',
                ),
                headers: {
                  'Content-Type':
                      'application/json',
                  'Accept':
                      'application/json',
                },
                body: operation.payload,
              )
              .timeout(
                const Duration(seconds: 8),
              );
          break;

        default:
          await _markAsFailed(operation);
          return;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        await _markAsSynced(operation);
      } else {
        await _increaseRetry(operation);
      }
    } catch (_) {
      await _increaseRetry(operation);
    }
  }

  /// Marca la operación como enviada correctamente.
  Future<void> _markAsSynced(
    PendingOperation operation,
  ) async {
    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(operation.id),
      ))
        .write(
      const PendingOperationsCompanion(
        syncStatus: Value('synced'),
      ),
    );
  }

  /// Incrementa los intentos y marca como error
  /// cuando alcanza el máximo permitido.
  Future<void> _increaseRetry(
    PendingOperation operation,
  ) async {
    final newRetryCount =
        operation.retryCount + 1;

    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(operation.id),
      ))
        .write(
      PendingOperationsCompanion(
        retryCount: Value(newRetryCount),
        syncStatus: Value(
          newRetryCount >= 3
              ? 'failed'
              : 'pending',
        ),
      ),
    );
  }

  Future<void> _markAsFailed(
    PendingOperation operation,
  ) async {
    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(operation.id),
      ))
        .write(
      const PendingOperationsCompanion(
        syncStatus: Value('failed'),
      ),
    );
  }

  /// Convierte los datos a JSON para almacenarlos
  /// en la cola local.
  static String encodePayload(
    Map<String, dynamic> data,
  ) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> decodePayload(
    String payload,
  ) {
    return Map<String, dynamic>.from(
      jsonDecode(payload),
    );
  }
}