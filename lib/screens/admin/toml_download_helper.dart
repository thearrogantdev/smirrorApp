import 'toml_download_stub.dart'
    if (dart.library.js_interop) 'toml_download_web.dart' as impl;

void triggerWebDownload(String content, String fileName) {
  impl.triggerWebDownload(content, fileName);
}
