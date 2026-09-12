import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../components/async_content.dart';
import '../components/financing_card.dart';
import '../data/local/financiamiento_local_source.dart';
import '../data/remote/financiamiento_remote_source.dart';
import '../database/app_database.dart';
import '../models/financiamiento_model.dart';
import '../repositories/financiamiento_repository.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class FinanciamientosScreen extends StatefulWidget {
  final AppDatabase database;

  const FinanciamientosScreen({
    super.key,
    required this.database,
  });

  @override
  State<FinanciamientosScreen> createState() =>
      _FinanciamientosScreenState();
}

class _FinanciamientosScreenState
    extends State<FinanciamientosScreen> {
  late final FinanciamientoRepository _repository;

  CancelToken _cancelToken = CancelToken();

  bool loading = true;
  bool showingLocalData = false;

  String? errorMessage;
  String? cacheMessage;

  DateTime? lastSync;

  List<FinanciamientoModel> financiamientos = [];

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  @override
  void initState() {
    super.initState();

    _repository = FinanciamientoRepository(
      remoteSource:
          const FinanciamientoRemoteSource(),
      localSource:
          FinanciamientoLocalSource(
        database: widget.database,
      ),
    );

    cargarFinanciamientos();
  }

  // ============================================================
  // CERRAR PANTALLA
  // ============================================================

  @override
  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel(
        'Pantalla de financiamientos cerrada.',
      );
    }

    // La base de datos no se cierra aquí porque
    // es compartida por toda la aplicación.
    super.dispose();
  }

  // ============================================================
  // CARGAR FINANCIAMIENTOS DESDE EL REPOSITORY
  // ============================================================

  Future<void> cargarFinanciamientos() async {
    if (_cancelToken.isCancelled) {
      _cancelToken = CancelToken();
    }

    if (mounted) {
      setState(() {
        loading = financiamientos.isEmpty;
        errorMessage = null;
        cacheMessage = null;
      });
    }

    try {
      final result =
          await _repository.obtenerFinanciamientos(
        cancelToken: _cancelToken,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        financiamientos =
            result.financiamientos;

        showingLocalData =
            result.desdeCache;

        lastSync =
            result.ultimaSincronizacion;

        cacheMessage =
            result.mensaje;

        errorMessage = null;
        loading = false;
      });
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        showingLocalData = false;
        errorMessage =
            _mensajeDio(error);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        showingLocalData = false;
        errorMessage =
            _mensajeError(error);
      });
    }
  }

  // ============================================================
  // MENSAJES DE ERROR PARA LA UI
  // ============================================================

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
        return 'Sin conexión con '
            'FinanSmart API.';

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

        if (status != null &&
            status >= 400) {
          return 'No fue posible '
              'procesar la solicitud.';
        }

        return 'Error de comunicación '
            'con FinanSmart API.';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';

      default:
        return 'No fue posible '
            'comunicarse con '
            'FinanSmart API.';
    }
  }

  String _mensajeError(
    Object error,
  ) {
    final message =
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );

    if (message.isEmpty) {
      return 'No fue posible cargar '
          'la información.';
    }

    return message;
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
          'Financiamientos',
        ),
        actions: [
          IconButton(
            tooltip:
                'Actualizar',
            onPressed:
                loading
                    ? null
                    : cargarFinanciamientos,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Opciones disponibles',
                style: theme
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              Text(
                'Consulta los tipos de '
                'financiamiento disponibles '
                'en FinanSmart.',
                style: theme
                    .textTheme
                    .bodyLarge,
              ),

              // ==================================================
              // AVISO DE DATOS LOCALES
              // ==================================================

              if (showingLocalData) ...[
                const SizedBox(
                  height:
                      AppSpacing.md,
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
                      AppRadius.md,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .cloud_off_outlined,
                        color: theme
                            .colorScheme
                            .onSecondaryContainer,
                      ),

                      const SizedBox(
                        width:
                            AppSpacing.sm,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Mostrando datos guardados',
                              style: theme
                                  .textTheme
                                  .titleMedium,
                            ),

                            const SizedBox(
                              height:
                                  AppSpacing.xs,
                            ),

                            Text(
                              _mensajeCache(),
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // CONTENIDO
              // ==================================================

              Expanded(
                child: AsyncContent(
                  loading:
                      loading,
                  errorMessage:
                      errorMessage,
                  isEmpty:
                      financiamientos.isEmpty,
                  onRetry:
                      cargarFinanciamientos,
                  emptyTitle:
                      'Sin financiamientos',
                  emptyMessage:
                      'Actualmente no existen '
                      'opciones disponibles.',
                  child:
                      RefreshIndicator(
                    onRefresh:
                        cargarFinanciamientos,
                    child:
                        ListView.separated(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          financiamientos.length,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height:
                              AppSpacing.md,
                        );
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final item =
                            financiamientos[
                                index];

                        return FinancingCard(
                          title:
                              item.nombre,
                          description:
                              item.descripcion,
                          interestRate:
                              item.tasaInteres,
                          minTerm:
                              item.plazoMinimo,
                          maxTerm:
                              item.plazoMaximo,
                          status:
                              item.estado,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENSAJE DE CACHÉ
  // ============================================================

  String _mensajeCache() {
    if (lastSync != null) {
      return 'Sin conexión. '
          'Última sincronización: '
          '${_formatDate(lastSync!)}';
    }

    if (cacheMessage != null &&
        cacheMessage!.isNotEmpty) {
      return cacheMessage!;
    }

    return 'Sin conexión. '
        'Estos datos pueden estar '
        'desactualizados.';
  }

  // ============================================================
  // FORMATO DE FECHA
  // ============================================================

  String _formatDate(
    DateTime value,
  ) {
    final local =
        value.toLocal();

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