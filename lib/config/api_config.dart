class ApiConfig {
  static const String environment = String.fromEnvironment(
    'AMBIENTE',
    defaultValue: 'dev',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
   defaultValue: 'http://192.168.1.92:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);

  static const Duration receiveTimeout = Duration(seconds: 15);

  static bool get isProduction => environment == 'prod';

  static bool get enableLogs => !isProduction;

  static void validate() {
    if (isProduction && !baseUrl.startsWith('https://')) {
      throw StateError(
        'La configuración de producción requiere HTTPS.',
      );
    }
  }
}