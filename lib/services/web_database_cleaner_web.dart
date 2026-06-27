import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

Future<void> cleanWebDatabases() async {
  try {
    final probe = await WasmDatabase.probe(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    for (final existing in probe.existingDatabases) {
      final dbName = existing.$2;
      if (dbName == 'smirror' || dbName == 'smirror_binaries') {
        if (kDebugMode) {
          print('Deleting web database: $dbName');
        }
        await probe.deleteDatabase(existing);
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to clean web databases: $e');
    }
  }
}
