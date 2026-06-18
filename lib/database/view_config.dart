import 'dart:typed_data';
import 'package:smirror_app/database/device.dart';
import 'relations_compatibility.dart';

class UserEntity {
  int id;
  String username;
  final device = ToOne<DeviceEntity>();

  UserEntity({this.id = 0, required this.username});
}

class ViewEntity {
  int id;
  int backendId;
  int userId;
  int timestamp;
  String language;
  int theme;
  bool dirty;
  final pages = ToMany<PageEntity>();

  ViewEntity({
    this.id = 0,
    required this.userId,
    this.timestamp = 0,
    this.language = '',
    this.theme = 0,
    this.backendId = 0,
    this.dirty = false,
  });
}

class PageEntity {
  int id;
  int number;
  final view = ToOne<ViewEntity>();
  final widgets = ToMany<WidgetEntity>();

  PageEntity({this.id = 0, required this.number});
}

class WidgetEntity {
  int id;
  int widgetId;
  double xPos;
  double yPos;
  double width;
  double height;
  final page = ToOne<PageEntity>();
  final properties = ToMany<WidgetPropertyEntity>();

  WidgetEntity({
    this.id = 0,
    required this.widgetId,
    this.xPos = 0,
    this.yPos = 0,
    this.width = 0,
    this.height = 0,
  });
}

class WidgetPropertyEntity {
  int id;
  int keyId;
  int type;
  final widget = ToOne<WidgetEntity>();

  final stringValues = ToMany<WidgetPropertyStringEntity>();
  final intValues = ToMany<WidgetPropertyIntEntity>();
  final floatValues = ToMany<WidgetPropertyFloatEntity>();
  final boolValues = ToMany<WidgetPropertyBoolEntity>();
  final rawBytes = ToMany<WidgetPropertyRawBytesEntity>();

  WidgetPropertyEntity({this.id = 0, required this.keyId, required this.type});
}

class WidgetPropertyStringEntity {
  int id;
  final property = ToOne<WidgetPropertyEntity>();
  String value;

  WidgetPropertyStringEntity({this.id = 0, required this.value});
}

class WidgetPropertyIntEntity {
  int id;
  final property = ToOne<WidgetPropertyEntity>();
  int value;

  WidgetPropertyIntEntity({this.id = 0, required this.value});
}

class WidgetPropertyFloatEntity {
  int id;
  final property = ToOne<WidgetPropertyEntity>();
  double value;

  WidgetPropertyFloatEntity({this.id = 0, required this.value});
}

class WidgetPropertyBoolEntity {
  int id;
  final property = ToOne<WidgetPropertyEntity>();
  bool value;

  WidgetPropertyBoolEntity({this.id = 0, required this.value});
}

class WidgetPropertyRawBytesEntity {
  int id;
  final property = ToOne<WidgetPropertyEntity>();
  Uint8List value;

  WidgetPropertyRawBytesEntity({this.id = 0, required this.value});
}
