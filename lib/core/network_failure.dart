import 'package:dio/dio.dart';

enum NetworkFailureType {
  noConnection,
  timeout,
  clientError,
  serverError,
  cancelled,
  unknown,
}

class NetworkFailure implements Exception {
  final NetworkFailureType type;
  final String message;
  final int? statusCode;

  const NetworkFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory NetworkFailure.fromDio(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          type: NetworkFailureType.noConnection,
          message:
              'Sin conexión. Verifique su acceso a Internet.',
        );

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          type: NetworkFailureType.timeout,
          message:
              'La solicitud tardó demasiado. Intente nuevamente.',
        );

      case DioExceptionType.badResponse:
        final statusCode =
            error.response?.statusCode;

        if (statusCode != null &&
            statusCode >= 400 &&
            statusCode < 500) {
          return NetworkFailure(
            type:
                NetworkFailureType.clientError,
            statusCode:
                statusCode,
            message:
                statusCode == 401
                    ? 'La sesión expiró y no pudo renovarse.'
                    : 'No fue posible procesar la solicitud.',
          );
        }

        if (statusCode != null &&
            statusCode >= 500) {
          return NetworkFailure(
            type:
                NetworkFailureType.serverError,
            statusCode:
                statusCode,
            message:
                'El servidor no está disponible temporalmente.',
          );
        }

        return NetworkFailure(
          type:
              NetworkFailureType.unknown,
          statusCode:
              statusCode,
          message:
              'Ocurrió un error de comunicación.',
        );

      case DioExceptionType.cancel:
        return const NetworkFailure(
          type:
              NetworkFailureType.cancelled,
          message:
              'La solicitud fue cancelada.',
        );

      default:
        return const NetworkFailure(
          type:
              NetworkFailureType.unknown,
          message:
              'No fue posible completar la operación.',
        );
    }
  }

  bool get esReintentable {
    return type ==
            NetworkFailureType.noConnection ||
        type ==
            NetworkFailureType.timeout ||
        type ==
            NetworkFailureType.serverError;
  }

  @override
  String toString() {
    return message;
  }
}