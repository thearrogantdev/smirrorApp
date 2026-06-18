import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

void triggerWebDownload(String content, String fileName) {
  try {
    final blob = web.Blob([content.toJS].toJS, web.BlobPropertyBag(type: 'text/plain'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = fileName;
    
    web.document.body?.appendChild(anchor);
    anchor.click();
    
    // Delay removal and revocation to give the browser time to initiate the download
    Future.delayed(const Duration(milliseconds: 200), () {
      anchor.remove();
      web.URL.revokeObjectURL(url);
    });
  } catch (e) {
    if (kDebugMode) {
      print('Failed to trigger web download: $e');
    }
  }
}
