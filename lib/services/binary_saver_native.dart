import 'dart:io';
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/path_service.dart';

Future<String> saveBinaryData(String fileName, Uint8List data) async {
  final directory = await GetIt.I<PathService>().getRootDir();
  final dir = Directory('$directory/binaries');
  if (!await dir.exists()) await dir.create(recursive: true);
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(data, flush: true);
  return file.path;
}
