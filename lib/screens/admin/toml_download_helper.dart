import 'toml_download_stub.dart'
    if (dart.library.js) 'toml_download_web.dart' as impl;

void triggerWebDownload(String content, String fileName) {
  impl.triggerWebDownload(content, fileName);
}
