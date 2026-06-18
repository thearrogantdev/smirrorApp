import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:smirror_app/database/database.dart';

import 'injection.config.dart'; // generated

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  final globalDb = AppDatabase('smirror');
  getIt.registerSingleton<AppDatabase>(globalDb, instanceName: 'global');
  getIt.registerSingleton<AppDatabase>(globalDb);
  getIt.init();
}
