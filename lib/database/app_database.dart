import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Financiamientos almacenados localmente.
///
/// Permite conservar una copia de los datos obtenidos desde la API
/// para que FinanSmart pueda consultarlos sin conexión.
class Financiamientos extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  RealColumn get interestRate => real()();

  IntColumn get minTerm => integer()();

  IntColumn get maxTerm => integer()();

  TextColumn get status => text()();

  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cola de operaciones realizadas mientras no existe conexión.
class PendingOperations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Identificador generado por el cliente para evitar duplicados.
  TextColumn get clientId => text().unique()();

  TextColumn get operationType => text()();

  TextColumn get payload => text()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
}

@DriftDatabase(
  tables: [
    Financiamientos,
    PendingOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Elimina todos los datos locales cuando el usuario cierra sesión.
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(pendingOperations).go();
      await delete(financiamientos).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final file = File(
      p.join(directory.path, 'finansmart.sqlite'),
    );

    return NativeDatabase.createInBackground(file);
  });
}