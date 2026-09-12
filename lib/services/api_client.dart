import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'secure_storage_service.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio dio;

  bool _initialized = false;

  Future<String?>? _refreshFuture;

  void initialize() {
    if (_initialized) {
      return;
    }

    ApiConfig.validate();

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout:
            ApiConfig.connectTimeout,
        receiveTimeout:
            ApiConfig.receiveTimeout,
        sendTimeout:
            ApiConfig.connectTimeout,
        contentType:
            Headers.jsonContentType,
        responseType:
            ResponseType.json,
        validateStatus: (status) {
          return status != null &&
              status < 500;
        },
      ),
    );

    // ============================================================
    // 1. INTERCEPTOR DE AUTENTICACIÓN
    // ============================================================

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (options, handler) async {
          final token =
              await SecureStorageService
                  .getToken();

          if (token != null &&
              token.isNotEmpty) {
            options.headers[
                    'Authorization'] =
                'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );

    // ============================================================
    // 2. INTERCEPTOR DE RENOVACIÓN DE TOKEN
    // ============================================================

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse:
            (response, handler) async {
          if (response.statusCode !=
              401) {
            handler.next(response);
            return;
          }

          final request =
              response.requestOptions;

          final alreadyRetried =
              request.extra[
                      'reintentado'] ==
                  true;

          final isRefreshRequest =
              request.path ==
                  '/api/auth/refresh';

          if (ApiConfig.enableLogs &&
              kDebugMode) {
            debugPrint(
              'AUTH 401 detectado en '
              '${request.method} '
              '${request.path}',
            );
          }

          if (alreadyRetried ||
              isRefreshRequest) {
            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH No se realizará '
                'otro reintento. '
                'Se limpia la sesión.',
              );
            }

            await SecureStorageService
                .clearSession();

            handler.next(response);
            return;
          }

          try {
            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH Access token expirado. '
                'Intentando renovar sesión...',
              );
            }

            final newToken =
                await _refreshAccessToken();

            if (newToken == null ||
                newToken.isEmpty) {
              if (ApiConfig.enableLogs &&
                  kDebugMode) {
                debugPrint(
                  'AUTH No fue posible '
                  'renovar el access token.',
                );
              }

              await SecureStorageService
                  .clearSession();

              handler.next(response);
              return;
            }

            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH Access token '
                'renovado correctamente.',
              );
            }

            request.extra[
                    'reintentado'] =
                true;

            request.headers[
                    'Authorization'] =
                'Bearer $newToken';

            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH Reintentando '
                'petición original: '
                '${request.method} '
                '${request.path}',
              );
            }

            final retryResponse =
                await dio.fetch(
              request,
            );

            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH Reintento '
                'completado con HTTP '
                '${retryResponse.statusCode}.',
              );
            }

            handler.resolve(
              retryResponse,
            );
          } catch (e) {
            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'AUTH Error durante '
                'la renovación: $e',
              );
            }

            await SecureStorageService
                .clearSession();

            handler.next(response);
          }
        },
      ),
    );

    // ============================================================
    // 3. RETRY SOLO PARA OPERACIONES IDEMPOTENTES
    // ============================================================

    dio.interceptors.add(
      InterceptorsWrapper(
        onError:
            (error, handler) async {
          final request =
              error.requestOptions;

          if (!_esIdempotente(
            request.method,
          )) {
            handler.next(error);
            return;
          }

          if (!_esErrorReintentable(
            error,
          )) {
            handler.next(error);
            return;
          }

          final retryCount =
              request.extra[
                      'network_retry_count'] as int? ??
                  0;

          if (retryCount >= 2) {
            handler.next(error);
            return;
          }

          final nextRetry =
              retryCount + 1;

          request.extra[
                  'network_retry_count'] =
              nextRetry;

          final delaySeconds =
              nextRetry;

          if (ApiConfig.enableLogs &&
              kDebugMode) {
            debugPrint(
              'RETRY '
              '${request.method} '
              '${request.path} '
              'intento $nextRetry/2 '
              'en ${delaySeconds}s',
            );
          }

          await Future.delayed(
            Duration(
              seconds:
                  delaySeconds,
            ),
          );

          try {
            final response =
                await dio.fetch(
              request,
            );

            if (ApiConfig.enableLogs &&
                kDebugMode) {
              debugPrint(
                'RETRY completado '
                '${request.method} '
                '${request.path} '
                'HTTP ${response.statusCode}',
              );
            }

            handler.resolve(
              response,
            );
          } on DioException catch (
            retryError
          ) {
            handler.next(
              retryError,
            );
          } catch (_) {
            handler.next(
              error,
            );
          }
        },
      ),
    );

    // ============================================================
    // 4. LOGGING SOLO EN DESARROLLO
    // ============================================================

    if (ApiConfig.enableLogs &&
        kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (options, handler) {
            final safeHeaders =
                Map<String, dynamic>.from(
              options.headers,
            );

            if (safeHeaders.containsKey(
              'Authorization',
            )) {
              safeHeaders[
                      'Authorization'] =
                  '*** OCULTO ***';
            }

            debugPrint(
              'HTTP ${options.method} '
              '${options.uri}',
            );

            debugPrint(
              'Headers: $safeHeaders',
            );

            handler.next(options);
          },
          onResponse:
              (response, handler) {
            debugPrint(
              'HTTP '
              '${response.statusCode} '
              '${response.requestOptions.path}',
            );

            handler.next(response);
          },
          onError:
              (error, handler) {
            debugPrint(
              'Error HTTP: '
              '${error.type}',
            );

            handler.next(error);
          },
        ),
      );
    }

    _initialized = true;
  }

  // ============================================================
  // MÉTODOS IDEMPOTENTES
  // ============================================================

  bool _esIdempotente(
    String method,
  ) {
    final normalized =
        method.toUpperCase();

    return normalized == 'GET' ||
        normalized == 'HEAD' ||
        normalized == 'OPTIONS';
  }

  // ============================================================
  // ERRORES QUE PUEDEN REINTENTARSE
  // ============================================================

  bool _esErrorReintentable(
    DioException error,
  ) {
    if (error.type ==
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
                .receiveTimeout) {
      return true;
    }

    final statusCode =
        error.response?.statusCode;

    if (statusCode != null &&
        statusCode >= 500) {
      return true;
    }

    return false;
  }

  // ============================================================
  // RENOVAR ACCESS TOKEN
  // ============================================================

  Future<String?>
      _refreshAccessToken() async {
    if (_refreshFuture != null) {
      if (ApiConfig.enableLogs &&
          kDebugMode) {
        debugPrint(
          'AUTH Ya existe una renovación '
          'en curso. Esperando resultado...',
        );
      }

      return await _refreshFuture!;
    }

    _refreshFuture =
        _performRefresh();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  // ============================================================
  // PETICIÓN REAL DE REFRESH
  // ============================================================

  Future<String?>
      _performRefresh() async {
    try {
      final refreshToken =
          await SecureStorageService
              .getRefreshToken();

      if (refreshToken == null ||
          refreshToken.isEmpty) {
        if (ApiConfig.enableLogs &&
            kDebugMode) {
          debugPrint(
            'AUTH No existe refresh token.',
          );
        }

        return null;
      }

      /*
        Se usa un Dio separado para evitar
        que la petición de refresh vuelva
        a entrar al interceptor principal.
      */
      final refreshDio = Dio(
        BaseOptions(
          baseUrl:
              ApiConfig.baseUrl,
          connectTimeout:
              ApiConfig.connectTimeout,
          receiveTimeout:
              ApiConfig.receiveTimeout,
          sendTimeout:
              ApiConfig.connectTimeout,
          contentType:
              Headers.jsonContentType,
          responseType:
              ResponseType.json,
          validateStatus: (status) {
            return status != null &&
                status < 500;
          },
        ),
      );

      if (ApiConfig.enableLogs &&
          kDebugMode) {
        debugPrint(
          'AUTH POST '
          '${ApiConfig.baseUrl}'
          '/api/auth/refresh',
        );
      }

      final response =
          await refreshDio.post(
        '/api/auth/refresh',
        data: {
          'refresh_token':
              refreshToken,
        },
      );

      if (ApiConfig.enableLogs &&
          kDebugMode) {
        debugPrint(
          'AUTH Refresh respondió HTTP '
          '${response.statusCode}.',
        );
      }

      if (response.statusCode != 200) {
        return null;
      }

      if (response.data is! Map) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final accessToken =
          data['access_token']
              ?.toString();

      if (accessToken == null ||
          accessToken.isEmpty) {
        return null;
      }

      await SecureStorageService
          .saveToken(
        accessToken,
      );

      return accessToken;
    } catch (e) {
      if (ApiConfig.enableLogs &&
          kDebugMode) {
        debugPrint(
          'AUTH Falló la petición '
          'de refresh: $e',
        );
      }

      return null;
    }
  }
}