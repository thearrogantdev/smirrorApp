import 'relations_compatibility.dart';

enum DashboardItemType { boolean, numeric, string }

class Dashboard {
  int id;
  int backendId;
  String name;
  int order;
  int timestamp;
  String? backgroundImagePath;
  int backgroundImageId;
  double width;
  double height;
  final items = ToMany<DashboardItem>();

  Dashboard({
    required this.name,
    this.id = 0,
    this.order = 0,
    this.backgroundImagePath,
    this.backgroundImageId = 0,
    this.backendId = 0,
    this.timestamp = 0,
    this.width = 1920.0,
    this.height = 1080.0,
  });
}

class DashboardItem {
  int id;
  String entityId;
  String displayName;
  double x;
  double y;
  double width;
  double height;
  int dbType;

  DashboardItemType get type => DashboardItemType.values[dbType];
  set type(DashboardItemType value) => dbType = value.index;

  int standardIconCodePoint;
  int standardColorValue;
  String? unitOverride;

  final dashboard = ToOne<Dashboard>();
  final thresholds = ToMany<ThresholdConfig>();

  DashboardItem({
    this.id = 0,
    required this.entityId,
    required this.displayName,
    required this.dbType,
    required this.standardIconCodePoint,
    required this.standardColorValue,
    this.x = 0,
    this.y = 0,
    this.width = 1,
    this.height = 1,
    this.unitOverride,
  });
}

class ThresholdConfig {
  int id;
  double triggerValue;
  int iconCodePoint;
  int colorValue;
  final item = ToOne<DashboardItem>();

  ThresholdConfig({
    this.id = 0,
    required this.triggerValue,
    required this.iconCodePoint,
    required this.colorValue,
  });
}
