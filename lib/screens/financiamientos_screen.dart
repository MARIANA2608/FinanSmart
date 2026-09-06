import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/async_content.dart';
import '../components/financing_card.dart';
import '../database/app_database.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class FinanciamientosScreen extends StatefulWidget {
  const FinanciamientosScreen({
    super.key,
  });

  @override
  State<FinanciamientosScreen> createState() =>
      _FinanciamientosScreenState();
}

class _FinanciamientosScreenState
    extends State<FinanciamientosScreen> {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final AppDatabase _database = AppDatabase();

  bool loading = true;
  bool showingLocalData = false;

  String? errorMessage;
  DateTime? lastSync;

  List<dynamic> financiamientos = [];

  @override
  void initState() {
    super.initState();
    cargarFinanciamientos();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> cargarFinanciamientos() async {
    if (mounted) {
      setState(() {
        loading = financiamientos.isEmpty;
        errorMessage = null;
      });
    }

    // Primero intenta mostrar información guardada localmente.
    await _cargarDatosLocales();

    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/financiamientos',
            ),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(
          response.body,
        );

        final List<dynamic> data =
            decoded['data'] ?? [];

        // Guarda la respuesta de la API en Drift.
        await _guardarDatosLocales(data);

        if (!mounted) {
          return;
        }

        setState(() {
          financiamientos = data;
          showingLocalData = false;
          errorMessage = null;
          loading = false;
        });
      } else {
        await _usarCacheOError(
          'El servidor respondió con '
          'HTTP ${response.statusCode}.',
        );
      }
    } catch (_) {
      await _usarCacheOError(
        'No fue posible comunicarse '
        'con FinanSmart API.',
      );
    }
  }

  /// Lee los financiamientos almacenados en el dispositivo.
  Future<void> _cargarDatosLocales() async {
    final rows = await _database
        .select(_database.financiamientos)
        .get();

    if (rows.isEmpty) {
      return;
    }

    final data = rows.map((row) {
      return {
        'id': row.id,
        'nombre': row.title,
        'descripcion': row.description,
        'tasa_interes': row.interestRate,
        'plazo_minimo': row.minTerm,
        'plazo_maximo': row.maxTerm,
        'estado': row.status,
      };
    }).toList();

    DateTime? newestSync;

    for (final row in rows) {
      if (newestSync == null ||
          row.lastSyncedAt.isAfter(newestSync)) {
        newestSync = row.lastSyncedAt;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      financiamientos = data;
      lastSync = newestSync;
      loading = false;
    });
  }

  /// Guarda en la base local los datos obtenidos desde la API.
  Future<void> _guardarDatosLocales(
    List<dynamic> data,
  ) async {
    final syncTime = DateTime.now();

    final companions =
        <FinanciamientosCompanion>[];

    for (var index = 0;
        index < data.length;
        index++) {
      final item = data[index];

      companions.add(
        FinanciamientosCompanion.insert(
          id: drift.Value(
            _toInt(
              item['id'] ?? index + 1,
            ),
          ),
          title:
              item['nombre']?.toString() ??
              'Sin nombre',
          description:
              item['descripcion']?.toString() ??
              'Sin descripción',
          interestRate: _toDouble(
            item['tasa_interes'],
          ),
          minTerm: _toInt(
            item['plazo_minimo'],
          ),
          maxTerm: _toInt(
            item['plazo_maximo'],
          ),
          status:
              item['estado']?.toString() ??
              'Sin estado',
          serverUpdatedAt: drift.Value(
            _parseDateTime(
              item['updated_at'],
            ),
          ),
          lastSyncedAt: syncTime,
        ),
      );
    }

    await _database.transaction(() async {
      await _database
          .delete(
            _database.financiamientos,
          )
          .go();

      if (companions.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.financiamientos,
            companions,
          );
        });
      }
    });

    lastSync = syncTime;
  }

  /// Si la API falla, utiliza la copia local.
  /// Si tampoco existen datos locales, muestra el error.
  Future<void> _usarCacheOError(
    String message,
  ) async {
    final rows = await _database
        .select(_database.financiamientos)
        .get();

    if (!mounted) {
      return;
    }

    if (rows.isNotEmpty) {
      await _cargarDatosLocales();

      if (!mounted) {
        return;
      }

      setState(() {
        showingLocalData = true;
        errorMessage = null;
        loading = false;
      });
    } else {
      setState(() {
        errorMessage = message;
        showingLocalData = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financiamientos',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Opciones disponibles',
                style:
                    theme.textTheme.headlineMedium,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                'Consulta los tipos de '
                'financiamiento disponibles '
                'en FinanSmart.',
                style:
                    theme.textTheme.bodyLarge,
              ),

              if (showingLocalData) ...[
                const SizedBox(
                  height: AppSpacing.md,
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
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
                        Icons.cloud_off_outlined,
                        color: theme
                            .colorScheme
                            .onSecondaryContainer,
                      ),

                      const SizedBox(
                        width: AppSpacing.sm,
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
                              lastSync != null
                                  ? 'Sin conexión. '
                                      'Última sincronización: '
                                      '${_formatDate(lastSync!)}'
                                  : 'Sin conexión. '
                                      'Estos datos pueden '
                                      'estar desactualizados.',
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
                height: AppSpacing.lg,
              ),

              Expanded(
                child: AsyncContent(
                  loading: loading,
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
                  child: ListView.separated(
                    itemCount:
                        financiamientos.length,
                    separatorBuilder:
                        (context, index) {
                      return const SizedBox(
                        height:
                            AppSpacing.md,
                      );
                    },
                    itemBuilder:
                        (context, index) {
                      final item =
                          financiamientos[index];

                      return FinancingCard(
                        title:
                            item['nombre']
                                    ?.toString() ??
                                'Sin nombre',
                        description:
                            item['descripcion']
                                    ?.toString() ??
                                'Sin descripción',
                        interestRate:
                            _toDouble(
                          item['tasa_interes'],
                        ),
                        minTerm:
                            _toInt(
                          item['plazo_minimo'],
                        ),
                        maxTerm:
                            _toInt(
                          item['plazo_maximo'],
                        ),
                        status:
                            item['estado']
                                    ?.toString() ??
                                'Sin estado',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
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

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  DateTime? _parseDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _formatDate(
    DateTime value,
  ) {
    final local = value.toLocal();

    String twoDigits(int number) {
      return number
          .toString()
          .padLeft(2, '0');
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }
}