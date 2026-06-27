import 'web_database_cleaner_stub.dart'
    if (dart.library.js_interop) 'web_database_cleaner_web.dart' as impl;

Future<void> cleanWebDatabases() async {
  await impl.cleanWebDatabases();
}
