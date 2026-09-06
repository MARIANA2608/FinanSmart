import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../services/sync_service.dart';
import '../theme/app_spacing.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({
    super.key,
  });

  @override
  State<NuevaSolicitudScreen> createState() =>
      _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState
    extends State<NuevaSolicitudScreen> {
  final AppDatabase _database = AppDatabase();

  final TextEditingController _montoController =
      TextEditingController();

  final TextEditingController _plazoController =
      TextEditingController();

  final Uuid _uuid = const Uuid();

  int _financiamientoId = 1;
  bool _guardando = false;
  String? _estadoOperacion;

  @override
  void initState() {
    super.initState();
    _actualizarEstadoPendiente();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _plazoController.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _guardarSolicitud() async {
    final monto = double.tryParse(
      _montoController.text.trim(),
    );

    final plazo = int.tryParse(
      _plazoController.text.trim(),
    );

    if (monto == null || monto <= 0) {
      _mostrarMensaje(
        'Ingrese un monto válido.',
      );
      return;
    }

    if (plazo == null || plazo <= 0) {
      _mostrarMensaje(
        'Ingrese un plazo válido.',
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final clientId = _uuid.v4();

      final payload = {
        'client_id': clientId,
        'financiamiento_id':
            _financiamientoId,
        'monto': monto,
        'plazo_meses': plazo,
      };

      await _database
          .into(_database.pendingOperations)
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
        'Solicitud guardada sin conexión.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        'No fue posible guardar la solicitud.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _actualizarEstadoPendiente() async {
    final pendientes = await _database
        .select(_database.pendingOperations)
        .get();

    if (!mounted) {
      return;
    }

    final cantidad = pendientes
        .where(
          (item) =>
              item.syncStatus == 'pending',
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

  void _mostrarMensaje(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva solicitud',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitud de financiamiento',
                style:
                    theme.textTheme.headlineMedium,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                'Si no existe conexión, '
                'la solicitud quedará guardada '
                'en el dispositivo y se enviará '
                'cuando vuelva Internet.',
                style:
                    theme.textTheme.bodyMedium,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              DropdownButtonFormField<int>(
                initialValue:
                    _financiamientoId,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Tipo de financiamiento',
                  border:
                      OutlineInputBorder(),
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
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              TextField(
                controller:
                    _montoController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Monto solicitado',
                  prefixText: '\$ ',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              TextField(
                controller:
                    _plazoController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Plazo en meses',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardando
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
                          Icons.save_outlined,
                        ),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : 'Guardar solicitud',
                  ),
                ),
              ),

              if (_estadoOperacion !=
                  null) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
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
                        Icons
                            .schedule_outlined,
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