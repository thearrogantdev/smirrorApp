import 'dart:js' as js;

void triggerWebDownload(String content, String fileName) {
  try {
    js.context.callMethod('eval', [
      "const blob = new Blob([`$content`], {type: 'text/plain'});"
      "const url = URL.createObjectURL(blob);"
      "const a = document.createElement('a');"
      "a.href = url;"
      "a.download = '$fileName';"
      "a.click();"
      "URL.revokeObjectURL(url);"
    ]);
  } catch (e) {
    print('Failed to trigger web download: $e');
  }
}
