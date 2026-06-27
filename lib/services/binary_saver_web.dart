import 'dart:convert';
import 'dart:typed_data';

Future<String> saveBinaryData(String fileName, Uint8List data) async {
  final mimeType = _guessMimeType(fileName);
  final base64Str = base64Encode(data);
  return 'data:$mimeType;base64,$base64Str';
}

String _guessMimeType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.bmp')) return 'image/bmp';
  return 'image/png'; // default fallback for image loading
}
