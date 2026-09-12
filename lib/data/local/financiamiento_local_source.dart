import 'package:drift/drift.dart' as drift;

import '../../database/app_database.dart';
import '../../models/financiamiento_model.dart';

class FinanciamientoLocalSource {
  final AppDatabase database;

  const FinanciamientoLocalSource({
    required this.database,
  });

  // ============================================================
  // OBTENER FINANCIAMIENTOS GUARDADOS EN DRIFT
  // ============================================================

  Future<List<FinanciamientoModel>>
      obtenerFinanciamientos() async {
    final rows = await database
        .select(
          database.financiamientos,
        )
        .get();

    return rows.map((row) {
      return FinanciamientoModel.fromJson({
        'id_tipo': row.id,
        'nombre': row.title,
        'descripcion': row.description,
        'tasa_interes': row.interestRate,
        'plazo_minimo': row.minTerm,
        'plazo_maximo': row.maxTerm,
        'estado': row.status,
        'updated_at':
            row.serverUpdatedAt
                ?.toIso8601String(),
      });
    }).toList();
  }

  // ============================================================
  // GUARDAR FINANCIAMIENTOS EN DRIFT
  // ============================================================

  Future<void> guardarFinanciamientos(
    List<FinanciamientoModel> financiamientos,
  ) async {
    final syncTime = DateTime.now();

    final companions =
        <FinanciamientosCompanion>[];

    for (final item in financiamientos) {
      companions.add(
        FinanciamientosCompanion.insert(
          id: drift.Value(
            item.id,
          ),
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

          // updatedAt viene como String?
          // desde el modelo y Drift necesita DateTime?.
          serverUpdatedAt:
              drift.Value(
            _parseDateTime(
              item.updatedAt,
            ),
          ),

          lastSyncedAt:
              syncTime,
        ),
      );
    }

    await database.transaction(
      () async {
        await database
            .delete(
              database.financiamientos,
            )
            .go();

        if (companions.isNotEmpty) {
          await database.batch(
            (batch) {
              batch.insertAll(
                database.financiamientos,
                companions,
              );
            },
          );
        }
      },
    );
  }

  // ============================================================
  // ÚLTIMA SINCRONIZACIÓN
  // ============================================================

  Future<DateTime?>
      obtenerUltimaSincronizacion() async {
    final rows = await database
        .select(
          database.financiamientos,
        )
        .get();

    DateTime? newest;

    for (final row in rows) {
      if (newest == null ||
          row.lastSyncedAt.isAfter(
            newest,
          )) {
        newest =
            row.lastSyncedAt;
      }
    }

    return newest;
  }

  // ============================================================
  // CONVERSIÓN STRING → DATETIME
  // ============================================================

  DateTime? _parseDateTime(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      value,
    );
  }
}