import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finansmart/core/network_failure.dart';

void main() {
  group('NetworkFailure.fromDio', () {
    test('Convierte error de conexión en noConnection', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.noConnection);
      expect(failure.message, contains('Sin conexión'));
      expect(failure.esReintentable, true);
    });

    test('Convierte timeout en timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.timeout);
      expect(failure.message, contains('tardó demasiado'));
      expect(failure.esReintentable, true);
    });

    test('Convierte HTTP 401 en error de cliente', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.clientError);
      expect(failure.statusCode, 401);
      expect(failure.message, contains('sesión expiró'));
      expect(failure.esReintentable, false);
    });

    test('Convierte HTTP 422 en error de cliente', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
        ),
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.clientError);
      expect(failure.statusCode, 422);
      expect(failure.message, contains('procesar la solicitud'));
      expect(failure.esReintentable, false);
    });

    test('Convierte HTTP 500 en error de servidor', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.serverError);
      expect(failure.statusCode, 500);
      expect(failure.message, contains('servidor'));
      expect(failure.esReintentable, true);
    });

    test('Convierte cancelación en cancelled', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.cancelled);
      expect(failure.message, contains('cancelada'));
      expect(failure.esReintentable, false);
    });

    test('Convierte HTTP 300 en error desconocido', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 300,
        ),
      );

      final failure = NetworkFailure.fromDio(error);

      expect(failure.type, NetworkFailureType.unknown);
      expect(failure.statusCode, 300);
      expect(
        failure.message,
        'Ocurrió un error de comunicación.',
      );
      expect(failure.esReintentable, false);
    });
  });
}