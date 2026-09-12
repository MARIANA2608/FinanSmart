import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'api_service.dart';

/// Procesa y sincroniza las operaciones creadas
/// mientras FinanSmart se encuentra sin conexión.
class SyncService {
  final AppDatabase database;

  final Connectivity _connectivity =
      Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  bool _processing = false;

  SyncService({
    required this.database,
  });

  // ============================================================
  // MONITOREO DE CONECTIVIDAD
  // ============================================================

  Future<void> startMonitoring() async {
    await _connectivitySubscription
        ?.cancel();

    _connectivitySubscription =
        _connectivity
            .onConnectivityChanged
            .listen(
      (results) async {
        if (_hasConnection(
          results,
        )) {
          await processPendingOperations();
        }
      },
    );

    final currentResults =
        await _connectivity
            .checkConnectivity();

    if (_hasConnection(
      currentResults,
    )) {
      await processPendingOperations();
    }
  }

  Future<void> stopMonitoring() async {
    await _connectivitySubscription
        ?.cancel();

    _connectivitySubscription = null;
  }

  bool _hasConnection(
    List<ConnectivityResult> results,
  ) {
    return results.any(
      (result) =>
          result !=
          ConnectivityResult.none,
    );
  }

  // ============================================================
  // PROCESAR COLA OFFLINE
  // ============================================================

  Future<void>
      processPendingOperations() async {
    if (_processing) {
      return;
    }

    _processing = true;

    try {
      final operations =
          await database
              .select(
                database
                    .pendingOperations,
              )
              .get();

      for (final operation
          in operations) {
        if (operation.syncStatus ==
            'synced') {
          continue;
        }

        if (operation.syncStatus ==
            'failed') {
          continue;
        }

        if (operation.retryCount >= 3) {
          continue;
        }

        await _sendOperation(
          operation,
        );
      }
    } finally {
      _processing = false;
    }
  }

  // ============================================================
  // ENVIAR OPERACIÓN
  // ============================================================

  Future<void> _sendOperation(
    PendingOperation operation,
  ) async {
    try {
      /*
        Espera creciente:

        intento 0 -> inmediato
        intento 1 -> 2 segundos
        intento 2 -> 4 segundos
      */
      if (operation.retryCount > 0) {
        final seconds =
            1 << operation.retryCount;

        await Future.delayed(
          Duration(
            seconds: seconds,
          ),
        );
      }

      switch (
          operation.operationType) {
        case 'create_request':
          await _sendCreateRequest(
            operation,
          );
          break;

        default:
          await _markAsFailed(
            operation,
          );
          return;
      }
    } on ValidationException {
      /*
        Si el backend devuelve 422,
        no tiene sentido repetir la
        misma operación automáticamente.

        Se marca como fallida porque
        requiere corrección de datos.
      */
      await _markAsFailed(
        operation,
      );
    } on DioException catch (error) {
      if (_isRetryableNetworkError(
        error,
      )) {
        await _increaseRetry(
          operation,
        );

        return;
      }

      /*
        Un 401 normalmente será gestionado
        automáticamente por ApiClient.

        Si aun así llega hasta aquí,
        no se reintenta indefinidamente.
      */
      if (error.response?.statusCode ==
          401) {
        await _increaseRetry(
          operation,
        );

        return;
      }

      /*
        Los errores del servidor
        pueden ser temporales.
      */
      final statusCode =
          error.response
              ?.statusCode;

      if (statusCode != null &&
          statusCode >= 500) {
        await _increaseRetry(
          operation,
        );

        return;
      }

      await _markAsFailed(
        operation,
      );
    } catch (_) {
      await _increaseRetry(
        operation,
      );
    }
  }

  // ============================================================
  // CREAR SOLICITUD
  // ============================================================

  Future<void> _sendCreateRequest(
    PendingOperation operation,
  ) async {
    final payload =
        decodePayload(
      operation.payload,
    );

    final clientId =
        payload['client_id']
            ?.toString();

    final financiamientoId =
        _toInt(
      payload[
          'financiamiento_id'],
    );

    final monto =
        _toDouble(
      payload['monto'],
    );

    final plazoMeses =
        _toInt(
      payload['plazo_meses'],
    );

    if (clientId == null ||
        clientId.isEmpty) {
      await _markAsFailed(
        operation,
      );

      return;
    }

    /*
      Se utiliza ApiService en lugar
      de http.post.

      De esta forma:
      - se agrega Authorization;
      - se renueva el token ante 401;
      - se reutiliza el cliente Dio
        centralizado;
      - se mantiene la misma API que
        usa la aplicación online.
    */
    await ApiService.crearSolicitud(
      clientId: clientId,
      financiamientoId:
          financiamientoId,
      monto: monto,
      plazoMeses:
          plazoMeses,
    );

    await _markAsSynced(
      operation,
    );
  }

  // ============================================================
  // ERRORES QUE PUEDEN REINTENTARSE
  // ============================================================

  bool _isRetryableNetworkError(
    DioException error,
  ) {
    return error.type ==
            DioExceptionType
                .connectionError ||
        error.type ==
            DioExceptionType
                .connectionTimeout ||
        error.type ==
            DioExceptionType
                .sendTimeout ||
        error.type ==
            DioExceptionType
                .receiveTimeout;
  }

  // ============================================================
  // MARCAR COMO SINCRONIZADA
  // ============================================================

  Future<void> _markAsSynced(
    PendingOperation operation,
  ) async {
    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(
              operation.id,
            ),
      ))
        .write(
      const PendingOperationsCompanion(
        syncStatus:
            Value('synced'),
      ),
    );
  }

  // ============================================================
  // INCREMENTAR REINTENTO
  // ============================================================

  Future<void> _increaseRetry(
    PendingOperation operation,
  ) async {
    final newRetryCount =
        operation.retryCount + 1;

    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(
              operation.id,
            ),
      ))
        .write(
      PendingOperationsCompanion(
        retryCount:
            Value(
          newRetryCount,
        ),
        syncStatus:
            Value(
          newRetryCount >= 3
              ? 'failed'
              : 'pending',
        ),
      ),
    );
  }

  // ============================================================
  // MARCAR COMO FALLIDA
  // ============================================================

  Future<void> _markAsFailed(
    PendingOperation operation,
  ) async {
    await (database.update(
      database.pendingOperations,
    )..where(
        (table) =>
            table.id.equals(
              operation.id,
            ),
      ))
        .write(
      const PendingOperationsCompanion(
        syncStatus:
            Value('failed'),
      ),
    );
  }

  // ============================================================
  // JSON PARA LA OUTBOX
  // ============================================================

  static String encodePayload(
    Map<String, dynamic> data,
  ) {
    return jsonEncode(
      data,
    );
  }

  static Map<String, dynamic>
      decodePayload(
    String payload,
  ) {
    return Map<String, dynamic>.from(
      jsonDecode(
        payload,
      ),
    );
  }

  // ============================================================
  // CONVERSIONES
  // ============================================================

  int _toInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}