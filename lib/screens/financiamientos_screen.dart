import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/async_content.dart';
import '../components/financing_card.dart';
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

  bool loading = true;
  String? errorMessage;
  List<dynamic> financiamientos = [];

  @override
  void initState() {
    super.initState();
    cargarFinanciamientos();
  }

  Future<void> cargarFinanciamientos() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/financiamientos',
        ),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        setState(() {
          financiamientos =
              data['data'] ?? [];
        });
      } else {
        setState(() {
          errorMessage =
              'El servidor respondió con '
              'HTTP ${response.statusCode}.';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage =
            'No fue posible comunicarse '
            'con FinanSmart API.';
      });
    } finally {
      setState(() {
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
                            item['nombre'] ??
                                'Sin nombre',
                        description:
                            item['descripcion'] ??
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
                            item['estado'] ??
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
          value.toString(),
        ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }
}