import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../services/api_service.dart';

class MisSolicitudesScreen extends StatefulWidget {
  final AppDatabase database;

  const MisSolicitudesScreen({
    super.key,
    required this.database,
  });

  @override
  State<MisSolicitudesScreen> createState() =>
      _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState
    extends State<MisSolicitudesScreen> {
  final CancelToken _cancelToken = CancelToken();

  bool loading = true;
  String? errorMessage;

  List<Map<String, dynamic>> solicitudesServidor = [];

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  @override
  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel(
        'Pantalla Mis solicitudes cerrada.',
      );
    }

    super.dispose();
  }

  // ============================================================
  // CARGAR SOLICITUDES DEL SERVIDOR
  // ============================================================

  Future<void> _cargarSolicitudes() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final response =
          await ApiService.obtenerSolicitudes(
        cancelToken: _cancelToken,
      );

      final dynamic rawData =
          response['data'] ??
          response['solicitudes'];

      final List<Map<String, dynamic>> data = [];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map) {
            data.add(
              Map<String, dynamic>.from(
                item,
              ),
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        solicitudesServidor = data;
        loading = false;
        errorMessage = null;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        errorMessage = _mensajeDio(e);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        errorMessage = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis solicitudes',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                loading
                    ? null
                    : _cargarSolicitudes,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<PendingOperation>>(
          stream: widget.database
              .select(
                widget.database.pendingOperations,
              )
              .watch(),
          builder: (context, snapshot) {
            final pendientes =
                snapshot.data ??
                <PendingOperation>[];

            if (loading &&
                solicitudesServidor.isEmpty &&
                pendientes.isEmpty) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (solicitudesServidor.isEmpty &&
                pendientes.isEmpty &&
                errorMessage != null) {
              return _ErrorSolicitudes(
                message: errorMessage!,
                onRetry: _cargarSolicitudes,
              );
            }

            if (solicitudesServidor.isEmpty &&
                pendientes.isEmpty) {
              return RefreshIndicator(
                onRefresh: _cargarSolicitudes,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 180,
                    ),
                    _EmptySolicitudes(),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _cargarSolicitudes,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(16),
                children: [
                  // ==================================================
                  // AVISO OFFLINE / ERROR DE RED
                  // ==================================================

                  if (errorMessage != null &&
                      pendientes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            const Color(
                          0xFFE8F0FF,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            color:
                                Color(
                              0xFF1746A2,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              '$errorMessage '
                              'Se muestran las operaciones '
                              'guardadas localmente.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],

                  // ==================================================
                  // SOLICITUDES DEL SERVIDOR
                  // ==================================================

                  if (solicitudesServidor.isNotEmpty) ...[
                    const Text(
                      'Solicitudes registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    for (final solicitud
                        in solicitudesServidor) ...[
                      _SolicitudServidorCard(
                        solicitud: solicitud,
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ],

                  // ==================================================
                  // OPERACIONES PENDIENTES OFFLINE
                  // ==================================================

                  if (pendientes.isNotEmpty) ...[
                    if (solicitudesServidor.isNotEmpty)
                      const SizedBox(
                        height: 12,
                      ),

                    const Text(
                      'Pendientes de sincronización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    for (final solicitud
                        in pendientes) ...[
                      _SolicitudPendienteCard(
                        solicitud: solicitud,
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MENSAJES DE ERROR
  // ============================================================

  String _mensajeDio(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La solicitud tardó demasiado.';

      case DioExceptionType.connectionError:
        return 'Sin conexión con FinanSmart API.';

      case DioExceptionType.badResponse:
        final status =
            error.response?.statusCode;

        if (status == 401) {
          return 'La sesión expiró y no pudo renovarse.';
        }

        if (status != null &&
            status >= 500) {
          return 'El servidor no está disponible temporalmente.';
        }

        return 'No fue posible consultar las solicitudes.';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';

      default:
        return 'No fue posible comunicarse con FinanSmart API.';
    }
  }
}

// ============================================================
// TARJETA DE SOLICITUD REGISTRADA EN SERVIDOR
// ============================================================

class _SolicitudServidorCard
    extends StatelessWidget {
  final Map<String, dynamic> solicitud;

  const _SolicitudServidorCard({
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    final monto =
        _toDouble(
      solicitud['monto'],
    );

    final plazo =
        _toInt(
      solicitud['plazo_meses'],
    );

    final financiamientoId =
        _toInt(
      solicitud['financiamiento_id'],
    );

    final estado =
        solicitud['estado']
                ?.toString() ??
            'Registrada';

    final clientId =
        solicitud['client_id']
                ?.toString() ??
            '';

    final actualizado =
        solicitud['actualizado_en'] ??
        solicitud['updated_at'];

    return Card(
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFE8F0FF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  21,
                ),
              ),
              child: const Icon(
                Icons.description,
                color:
                    Color(
                  0xFF1746A2,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solicitud de financiamiento',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Financiamiento: $financiamientoId',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    'Monto: \$${monto.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    'Plazo: $plazo meses',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black54,
                    ),
                  ),

                  if (actualizado != null) ...[
                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Actualizada: ${_formatDate(actualizado)}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black45,
                      ),
                    ),
                  ],

                  if (clientId.isNotEmpty) ...[
                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'ID: ${_shortId(clientId)}',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFE8F0FF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
              child: Text(
                _estadoTexto(
                  estado,
                ),
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Color(
                    0xFF1746A2,
                  ),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _toInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(
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

  static String _estadoTexto(
    String estado,
  ) {
    switch (estado.toLowerCase()) {
      case 'created':
        return 'Creada';

      case 'registered':
        return 'Registrada';

      case 'pending':
        return 'Pendiente';

      case 'approved':
        return 'Aprobada';

      case 'rejected':
        return 'Rechazada';

      default:
        return estado;
    }
  }

  static String _shortId(
    String value,
  ) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(
      0,
      8,
    );
  }

  static String _formatDate(
    dynamic value,
  ) {
    final date =
        DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final local =
        date.toLocal();

    String twoDigits(
      int number,
    ) {
      return number
          .toString()
          .padLeft(
            2,
            '0',
          );
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }
}

// ============================================================
// TARJETA DE OPERACIÓN PENDIENTE OFFLINE
// ============================================================

class _SolicitudPendienteCard
    extends StatelessWidget {
  final PendingOperation solicitud;

  const _SolicitudPendienteCard({
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFFFF4D8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  21,
                ),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color:
                    Color(
                  0xFF9A6700,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solicitud pendiente',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'Operación: '
                    '${solicitud.operationType}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    'Intentos: '
                    '${solicitud.retryCount}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      Colors.black26,
                ),
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color:
                        Color(
                      0xFF1746A2,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    _estadoTexto(
                      solicitud.syncStatus,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _estadoTexto(
    String estado,
  ) {
    switch (estado.toLowerCase()) {
      case 'synced':
        return 'Enviada';

      case 'failed':
        return 'Error';

      case 'pending':
        return 'Pendiente';

      default:
        return estado;
    }
  }
}

// ============================================================
// SIN SOLICITUDES
// ============================================================

class _EmptySolicitudes
    extends StatelessWidget {
  const _EmptySolicitudes();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 60,
              color:
                  Color(
                0xFF1746A2,
              ),
            ),

            SizedBox(
              height: 16,
            ),

            Text(
              'No tienes solicitudes registradas.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorSolicitudes
    extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorSolicitudes({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color:
                  Color(
                0xFF1746A2,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed: () {
                onRetry();
              },
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}