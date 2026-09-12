import 'package:dio/dio.dart';

import '../core/network_failure.dart';
import '../data/local/financiamiento_local_source.dart';
import '../data/remote/financiamiento_remote_source.dart';
import '../models/financiamiento_model.dart';

class FinanciamientoRepository {
  final FinanciamientoRemoteSource remoteSource;
  final FinanciamientoLocalSource localSource;

  const FinanciamientoRepository({
    required this.remoteSource,
    required this.localSource,
  });

  // ============================================================
  // OBTENER FINANCIAMIENTOS
  //
  // Estrategia:
  // 1. Intenta consultar el servidor.
  // 2. Si responde correctamente, actualiza Drift.
  // 3. Si falla la red, traduce el error al dominio.
  // 4. Si existe caché local, la devuelve.
  // ============================================================

  Future<FinanciamientoResult> obtenerFinanciamientos({
    CancelToken? cancelToken,
  }) async {
    try {
      final remotos =
          await remoteSource.obtenerFinanciamientos(
        cancelToken: cancelToken,
      );

      await localSource.guardarFinanciamientos(
        remotos,
      );

      final ultimaSincronizacion =
          await localSource
              .obtenerUltimaSincronizacion();

      return FinanciamientoResult(
        financiamientos: remotos,
        desdeCache: false,
        ultimaSincronizacion:
            ultimaSincronizacion,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        rethrow;
      }

      final failure =
          NetworkFailure.fromDio(
        error,
      );

      final locales =
          await localSource
              .obtenerFinanciamientos();

      final ultimaSincronizacion =
          await localSource
              .obtenerUltimaSincronizacion();

      if (locales.isNotEmpty) {
        return FinanciamientoResult(
          financiamientos: locales,
          desdeCache: true,
          ultimaSincronizacion:
              ultimaSincronizacion,
          mensaje:
              '${failure.message} '
              'Se muestran los datos guardados.',
        );
      }

      throw failure;
    } on NetworkFailure {
      rethrow;
    } catch (_) {
      final locales =
          await localSource
              .obtenerFinanciamientos();

      final ultimaSincronizacion =
          await localSource
              .obtenerUltimaSincronizacion();

      if (locales.isNotEmpty) {
        return FinanciamientoResult(
          financiamientos: locales,
          desdeCache: true,
          ultimaSincronizacion:
              ultimaSincronizacion,
          mensaje:
              'No fue posible actualizar los datos. '
              'Se muestran los datos guardados.',
        );
      }

      throw const NetworkFailure(
        type:
            NetworkFailureType.unknown,
        message:
            'No fue posible cargar '
            'los financiamientos.',
      );
    }
  }
}

// ============================================================
// RESULTADO PARA LA CAPA SUPERIOR
// ============================================================

class FinanciamientoResult {
  final List<FinanciamientoModel> financiamientos;

  final bool desdeCache;

  final DateTime? ultimaSincronizacion;

  final String? mensaje;

  const FinanciamientoResult({
    required this.financiamientos,
    required this.desdeCache,
    this.ultimaSincronizacion,
    this.mensaje,
  });
}