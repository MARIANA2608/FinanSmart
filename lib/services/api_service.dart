import 'package:dio/dio.dart';

import 'api_client.dart';

class ApiService {
  static Dio get _dio {
    ApiClient.instance.initialize();
    return ApiClient.instance.dio;
  }

  // ============================================================
  // FINANCIAMIENTOS
  // ============================================================

  static Future<Map<String, dynamic>>
      obtenerFinanciamientos({
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/api/financiamientos',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        response.data as Map,
      );
    }

    throw Exception(
      _messageFromResponse(response),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        response.data as Map,
      );
    }

    throw Exception(
      _messageFromResponse(response),
    );
  }

  // ============================================================
  // CREAR SOLICITUD
  // ============================================================

  static Future<Map<String, dynamic>> crearSolicitud({
    required String clientId,
    required int financiamientoId,
    required double monto,
    required int plazoMeses,
  }) async {
    final response = await _dio.post(
      '/api/solicitudes',
      data: {
        'client_id': clientId,
        'financiamiento_id': financiamientoId,
        'monto': monto,
        'plazo_meses': plazoMeses,
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        response.data as Map,
      );
    }

    if (response.statusCode == 422) {
      final body =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final errors = body['errors'];

      if (errors is Map) {
        throw ValidationException(
          Map<String, dynamic>.from(
            errors,
          ).map(
            (key, value) => MapEntry(
              key,
              value.toString(),
            ),
          ),
        );
      }
    }

    throw Exception(
      _messageFromResponse(response),
    );
  }

  // ============================================================
  // OBTENER SOLICITUDES DEL SERVIDOR
  // ============================================================

  static Future<Map<String, dynamic>>
      obtenerSolicitudes({
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/api/solicitudes',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        response.data as Map,
      );
    }

    throw Exception(
      _messageFromResponse(response),
    );
  }

  // ============================================================
  // MENSAJE DE RESPUESTA
  // ============================================================

  static String _messageFromResponse(
    Response response,
  ) {
    if (response.data is Map) {
      final map =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final message =
          map['mensaje'] ??
          map['message'];

      if (message != null) {
        return message.toString();
      }
    }

    return 'Error HTTP ${response.statusCode}';
  }
}

// ============================================================
// VALIDACIÓN 422
// ============================================================

class ValidationException
    implements Exception {
  final Map<String, String> errors;

  ValidationException(
    this.errors,
  );

  @override
  String toString() {
    return errors.values.join('\n');
  }
}