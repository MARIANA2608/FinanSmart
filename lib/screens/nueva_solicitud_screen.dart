import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import '../theme/app_spacing.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  final AppDatabase database;

  const NuevaSolicitudScreen({
    super.key,
    required this.database,
  });

  @override
  State<NuevaSolicitudScreen> createState() =>
      _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState
    extends State<NuevaSolicitudScreen> {
  final TextEditingController _montoController =
      TextEditingController();

  final TextEditingController _plazoController =
      TextEditingController();

  final Uuid _uuid = const Uuid();

  int _financiamientoId = 1;

  bool _guardando = false;

  String? _estadoOperacion;

  String? _errorFinanciamiento;
  String? _errorMonto;
  String? _errorPlazo;

  @override
  void initState() {
    super.initState();
    _actualizarEstadoPendiente();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _plazoController.dispose();

    // NO cerramos la base de datos aquí.
    // La instancia pertenece a toda la aplicación.
    super.dispose();
  }

  // ============================================================
  // GUARDAR SOLICITUD
  // ============================================================

  Future<void> _guardarSolicitud() async {
    final montoTexto =
        _montoController.text.trim();

    final plazoTexto =
        _plazoController.text.trim();

    final monto = double.tryParse(
      montoTexto,
    );

    final plazo = int.tryParse(
      plazoTexto,
    );

    setState(() {
      _errorFinanciamiento = null;
      _errorMonto = null;
      _errorPlazo = null;
    });

    if (monto == null) {
      setState(() {
        _errorMonto =
            'Ingrese un monto válido.';
      });
      return;
    }

    if (plazo == null) {
      setState(() {
        _errorPlazo =
            'Ingrese un plazo válido.';
      });
      return;
    }

    setState(() {
      _guardando = true;
    });

    final clientId = _uuid.v4();

    final payload = {
      'client_id': clientId,
      'financiamiento_id':
          _financiamientoId,
      'monto': monto,
      'plazo_meses': plazo,
    };

    try {
      // Primero se intenta enviar al backend real.
      await ApiService.crearSolicitud(
        clientId: clientId,
        financiamientoId:
            _financiamientoId,
        monto: monto,
        plazoMeses: plazo,
      );

      if (!mounted) {
        return;
      }

      _montoController.clear();
      _plazoController.clear();

      setState(() {
        _estadoOperacion =
            'Solicitud enviada correctamente.';
      });

      _mostrarMensaje(
        'Solicitud registrada correctamente.',
      );
    }

    // ==========================================================
    // HTTP 422
    // ==========================================================

    on ValidationException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorFinanciamiento =
            e.errors['financiamiento_id'];

        _errorMonto =
            e.errors['monto'];

        _errorPlazo =
            e.errors['plazo_meses'];
      });

      _mostrarMensaje(
        'Revise los campos indicados.',
      );
    }

    // ==========================================================
    // ERROR DE CONEXIÓN
    // ==========================================================

    on DioException catch (e) {
      if (_esErrorDeConexion(e)) {
        await _guardarEnCola(
          clientId: clientId,
          payload: payload,
        );

        if (!mounted) {
          return;
        }

        _montoController.clear();
        _plazoController.clear();

        setState(() {
          _estadoOperacion =
              'Solicitud guardada localmente. '
              'Pendiente de sincronizar.';
        });

        _mostrarMensaje(
          'Sin conexión. '
          'La solicitud quedó pendiente.',
        );
      } else {
        if (!mounted) {
          return;
        }

        _mostrarMensaje(
          _mensajeDio(e),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      final mensaje = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      _mostrarMensaje(
        mensaje.isEmpty
            ? 'No fue posible procesar '
                'la solicitud.'
            : mensaje,
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }

      await _actualizarEstadoPendiente();
    }
  }

  // ============================================================
  // GUARDAR EN OUTBOX
  // ============================================================

  Future<void> _guardarEnCola({
    required String clientId,
    required Map<String, dynamic> payload,
  }) async {
    await widget.database
        .into(
          widget.database.pendingOperations,
        )
        .insert(
          PendingOperationsCompanion.insert(
            clientId: clientId,
            operationType:
                'create_request',
            payload:
                SyncService.encodePayload(
              payload,
            ),
            createdAt:
                DateTime.now(),
            retryCount:
                const Value(0),
            syncStatus:
                const Value('pending'),
          ),
        );
  }

  // ============================================================
  // ESTADO DE LA OUTBOX
  // ============================================================

  Future<void>
      _actualizarEstadoPendiente() async {
    final pendientes =
        await widget.database
            .select(
              widget.database
                  .pendingOperations,
            )
            .get();

    if (!mounted) {
      return;
    }

    final cantidad = pendientes
        .where(
          (item) =>
              item.syncStatus ==
              'pending',
        )
        .length;

    if (cantidad > 0) {
      setState(() {
        _estadoOperacion =
            '$cantidad operación(es) '
            'pendiente(s) de sincronizar.';
      });
    }
  }

  // ============================================================
  // ERRORES DE CONEXIÓN
  // ============================================================

  bool _esErrorDeConexion(
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

  String _mensajeDio(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La solicitud tardó demasiado. '
            'Intente nuevamente.';

      case DioExceptionType.connectionError:
        return 'No existe conexión '
            'con el servidor.';

      case DioExceptionType.badResponse:
        final status =
            error.response?.statusCode;

        if (status == 401) {
          return 'La sesión expiró '
              'y no pudo renovarse.';
        }

        if (status != null &&
            status >= 500) {
          return 'El servidor no está '
              'disponible temporalmente.';
        }

        return 'No fue posible procesar '
            'la solicitud.';

      case DioExceptionType.cancel:
        return 'La solicitud fue cancelada.';

      default:
        return 'No fue posible comunicarse '
            'con FinanSmart API.';
    }
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void _mostrarMensaje(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
        ),
      ),
    );
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva solicitud',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitud de financiamiento',
                style: theme
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                'La solicitud se enviará '
                'al servidor. Si no existe '
                'conexión, quedará guardada '
                'en el dispositivo y se '
                'sincronizará posteriormente.',
                style: theme
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // FINANCIAMIENTO
              // ==================================================

              DropdownButtonFormField<int>(
                initialValue:
                    _financiamientoId,
                decoration:
                    InputDecoration(
                  labelText:
                      'Tipo de financiamiento',
                  border:
                      const OutlineInputBorder(),
                  errorText:
                      _errorFinanciamiento,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(
                      'Microcrédito personal',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(
                      'Microcrédito emprendedor',
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _financiamientoId =
                          value;
                      _errorFinanciamiento =
                          null;
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ==================================================
              // MONTO
              // ==================================================

              TextField(
                controller:
                    _montoController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  if (_errorMonto !=
                      null) {
                    setState(() {
                      _errorMonto =
                          null;
                    });
                  }
                },
                decoration:
                    InputDecoration(
                  labelText:
                      'Monto solicitado',
                  prefixText: '\$ ',
                  border:
                      const OutlineInputBorder(),
                  errorText:
                      _errorMonto,
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ==================================================
              // PLAZO
              // ==================================================

              TextField(
                controller:
                    _plazoController,
                keyboardType:
                    TextInputType.number,
                onChanged: (_) {
                  if (_errorPlazo !=
                      null) {
                    setState(() {
                      _errorPlazo =
                          null;
                    });
                  }
                },
                decoration:
                    InputDecoration(
                  labelText:
                      'Plazo en meses',
                  border:
                      const OutlineInputBorder(),
                  errorText:
                      _errorPlazo,
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // ENVIAR
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton.icon(
                  onPressed:
                      _guardando
                          ? null
                          : _guardarSolicitud,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                        ),
                  label: Text(
                    _guardando
                        ? 'Procesando...'
                        : 'Enviar solicitud',
                  ),
                ),
              ),

              // ==================================================
              // ESTADO
              // ==================================================

              if (_estadoOperacion !=
                  null) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  decoration:
                      BoxDecoration(
                    color: theme
                        .colorScheme
                        .secondaryContainer,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync_outlined,
                        color: theme
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                      const SizedBox(
                        width:
                            AppSpacing.sm,
                      ),
                      Expanded(
                        child: Text(
                          _estadoOperacion!,
                          style: theme
                              .textTheme
                              .bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}