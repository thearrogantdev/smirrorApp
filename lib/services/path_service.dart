import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class PathService {
  Future<String>? _cached;

  Future<String> getRootDir() => _cached ??= _resolve();

  Future<String> _resolve() async {
    try {
      debugPrint((await getApplicationSupportDirectory()).path);
      return (await getApplicationSupportDirectory()).path;
    } catch (_) {
      debugPrint((await getApplicationDocumentsDirectory()).path);
      return (await getApplicationDocumentsDirectory()).path;
    }
  }
}
