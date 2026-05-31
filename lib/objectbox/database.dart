import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

part 'database.g.dart';

// 1. Devices Table
@DataClassName('DeviceRow')
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get connectionId => text().unique()();
  TextColumn get name => text()();
  TextColumn get ip => text()();
  IntColumn get port => integer()();
}

// 2. Users Table
@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  IntColumn get deviceId => integer().references(Devices, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {username, deviceId}
      ];
}

// 3. Views Table
@DataClassName('ViewRow')
class Views extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get timestamp => integer().withDefault(const Constant(0))();
  TextColumn get language => text().withDefault(const Constant(''))();
  IntColumn get theme => integer().withDefault(const Constant(0))();
}

// 4. Pages Table
@DataClassName('PageRow')
class Pages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get number => integer()();
  IntColumn get viewId => integer().references(Views, #id, onDelete: KeyAction.cascade)();
}

// 5. Widgets Table
@DataClassName('WidgetRow')
class Widgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get widgetId => integer()();
  RealColumn get xPos => real().withDefault(const Constant(0.0))();
  RealColumn get yPos => real().withDefault(const Constant(0.0))();
  RealColumn get width => real().withDefault(const Constant(0.0))();
  RealColumn get height => real().withDefault(const Constant(0.0))();
  IntColumn get pageId => integer().references(Pages, #id, onDelete: KeyAction.cascade)();
}

// 6. WidgetProperties Table
@DataClassName('WidgetPropertyRow')
class WidgetProperties extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get keyId => integer()();
  IntColumn get type => integer()();
  IntColumn get widgetId => integer().references(Widgets, #id, onDelete: KeyAction.cascade)();
}

// 7. WidgetPropertyStrings Table
@DataClassName('WidgetPropertyStringRow')
class WidgetPropertyStrings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get propertyId => integer().references(WidgetProperties, #id, onDelete: KeyAction.cascade)();
  TextColumn get value => text()();
}

// 8. WidgetPropertyInts Table
@DataClassName('WidgetPropertyIntRow')
class WidgetPropertyInts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get propertyId => integer().references(WidgetProperties, #id, onDelete: KeyAction.cascade)();
  IntColumn get value => integer()();
}

// 9. WidgetPropertyFloats Table
@DataClassName('WidgetPropertyFloatRow')
class WidgetPropertyFloats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get propertyId => integer().references(WidgetProperties, #id, onDelete: KeyAction.cascade)();
  RealColumn get value => real()();
}

// 10. WidgetPropertyBools Table
@DataClassName('WidgetPropertyBoolRow')
class WidgetPropertyBools extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get propertyId => integer().references(WidgetProperties, #id, onDelete: KeyAction.cascade)();
  BoolColumn get value => boolean()();
}

// 11. WidgetPropertyRawBytesList Table
@DataClassName('WidgetPropertyRawBytesRow')
class WidgetPropertyRawBytesList extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get propertyId => integer().references(WidgetProperties, #id, onDelete: KeyAction.cascade)();
  BlobColumn get value => blob()();
}

// 12. Dashboards Table
@DataClassName('DashboardRow')
class Dashboards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  TextColumn get name => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  IntColumn get timestamp => integer().withDefault(const Constant(0))();
  TextColumn get backgroundImagePath => text().nullable()();
  IntColumn get backgroundImageId => integer().withDefault(const Constant(0))();
  RealColumn get width => real().withDefault(const Constant(1920.0))();
  RealColumn get height => real().withDefault(const Constant(1080.0))();
}

// 13. DashboardItems Table
@DataClassName('DashboardItemRow')
class DashboardItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityId => text()();
  TextColumn get displayName => text()();
  IntColumn get dbType => integer()();
  RealColumn get x => real().withDefault(const Constant(0.0))();
  RealColumn get y => real().withDefault(const Constant(0.0))();
  RealColumn get width => real().withDefault(const Constant(1.0))();
  RealColumn get height => real().withDefault(const Constant(1.0))();
  IntColumn get standardIconCodePoint => integer()();
  IntColumn get standardColorValue => integer()();
  TextColumn get unitOverride => text().nullable()();
  IntColumn get dashboardId => integer().references(Dashboards, #id, onDelete: KeyAction.cascade)();
}

// 14. ThresholdConfigs Table
@DataClassName('ThresholdConfigRow')
class ThresholdConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get triggerValue => real()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get colorValue => integer()();
  IntColumn get itemId => integer().references(DashboardItems, #id, onDelete: KeyAction.cascade)();
}

@DriftDatabase(tables: [
  Devices,
  Users,
  Views,
  Pages,
  Widgets,
  WidgetProperties,
  WidgetPropertyStrings,
  WidgetPropertyInts,
  WidgetPropertyFloats,
  WidgetPropertyBools,
  WidgetPropertyRawBytesList,
  Dashboards,
  DashboardItems,
  ThresholdConfigs,
])
@singleton
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'smirror',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Enable foreign key support
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
