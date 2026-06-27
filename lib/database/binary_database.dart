import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'binary_database.g.dart';

@DataClassName('BinaryRow')
class Binaries extends Table {
  IntColumn get id => integer()();
  TextColumn get path => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Binaries])
class BinaryDatabase extends _$BinaryDatabase {
  BinaryDatabase(String name)
      : super(
          driftDatabase(
            name: name,
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  // Insert or update binary mapping
  Future<void> insertBinary(int id, String path) async {
    await into(binaries).insertOnConflictUpdate(
      BinariesCompanion(
        id: Value(id),
        path: Value(path),
      ),
    );
  }

  // Get binary path by ID
  Future<String?> getBinaryPath(int id) async {
    final query = select(binaries)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.path;
  }

  // Watch binary path by ID
  Stream<String?> watchBinaryPath(int id) {
    final query = select(binaries)..where((t) => t.id.equals(id));
    return query.map((row) => row.path).watchSingleOrNull();
  }
}
