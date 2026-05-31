import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smirror_wire/generated/view_view_structure_generated.dart' as fbm;

enum ViewConfigPropertyType { none, string, int, float, bool, rawBytes }

class ViewConfigProperty {
  final int key;
  final ViewConfigPropertyType type;

  String? stringValue;
  int? intValue;
  final double? floatValue;
  final bool? boolValue;
  final Uint8List? rawBytes;

  ViewConfigProperty({
    required this.key,
    required this.type,
    this.stringValue,
    this.intValue,
    this.floatValue,
    this.boolValue,
    this.rawBytes,
  });

  dynamic get value {
    switch (type) {
      case ViewConfigPropertyType.string:
        return stringValue;
      case ViewConfigPropertyType.int:
        return intValue;
      case ViewConfigPropertyType.float:
        return floatValue;
      case ViewConfigPropertyType.bool:
        return boolValue;
      case ViewConfigPropertyType.rawBytes:
        return rawBytes;
      case ViewConfigPropertyType.none:
        return null;
    }
  }
}

/// Domain model representing a single draggable widget on a page
class ViewConfigItem {
  final int id;
  final Offset position;
  final Size size;
  final int widgetType;
  final List<ViewConfigProperty> properties;

  ViewConfigItem({
    required this.id,
    required this.position,
    required this.size,
    required this.widgetType,
    required this.properties,
  });

  ViewConfigItem copyWith({
    Offset? position,
    Size? size,
    List<ViewConfigProperty>? properties,
  }) {
    return ViewConfigItem(
      id: id,
      position: position ?? this.position,
      size: size ?? this.size,
      widgetType: widgetType,
      properties: properties ?? this.properties,
    );
  }
}

/// Domain model representing a page containing items
class ViewConfigPage {
  final int id;
  final int pageNumber;
  final List<ViewConfigItem> items;

  ViewConfigPage({
    required this.id,
    required this.pageNumber,
    this.items = const [],
  });

  ViewConfigPage copyWith({List<ViewConfigItem>? items}) {
    return ViewConfigPage(
      id: id,
      pageNumber: pageNumber,
      items: items ?? this.items,
    );
  }
}

extension ViewConfigPageFlatbuf on ViewConfigPage {
  fbm.PageT toFlatbuf() {
    return fbm.PageT(
      id: id,
      number: pageNumber,
      widgets: items.map((item) => item.toFlatbuf()).toList(),
    );
  }
}

extension ViewConfigItemFlatbuf on ViewConfigItem {
  fbm.WidgetT toFlatbuf() {
    return fbm.WidgetT(
      id: id,
      widgetId: widgetType,
      xPos: position.dx,
      yPos: position.dy,
      width: size.width,
      height: size.height,
      properties: properties.map((prop) => prop.toFlatbuf()).toList(),
    );
  }
}

extension ViewConfigPropertyFlatbuf on ViewConfigProperty {
  fbm.WidgetPropertyT toFlatbuf() {
    final property = fbm.WidgetPropertyT()..keyId = key;

    switch (type) {
      case ViewConfigPropertyType.string:
        property.type = fbm.WidgetPropertyType.String;
        property.valueType = fbm.WidgetPropertyValueTypeId.StringValue;
        property.value = fbm.StringValueT(value: stringValue ?? "");
        break;
      case ViewConfigPropertyType.int:
        property.type = fbm.WidgetPropertyType.Int;
        property.valueType = fbm.WidgetPropertyValueTypeId.IntValue;
        property.value = fbm.IntValueT(value: intValue ?? 0);
        break;
      case ViewConfigPropertyType.float:
        property.type = fbm.WidgetPropertyType.Float;
        property.valueType = fbm.WidgetPropertyValueTypeId.FloatValue;
        property.value = fbm.FloatValueT(value: floatValue ?? 0.0);
        break;
      case ViewConfigPropertyType.bool:
        property.type = fbm.WidgetPropertyType.Bool;
        property.valueType = fbm.WidgetPropertyValueTypeId.BoolValue;
        property.value = fbm.BoolValueT(value: boolValue ?? false);
        break;
      case ViewConfigPropertyType.rawBytes:
        property.type = fbm.WidgetPropertyType.RawBytes;
        property.valueType = fbm.WidgetPropertyValueTypeId.RawBytes;
        property.value = fbm.RawBytesT(data: rawBytes ?? []);
        break;
      case ViewConfigPropertyType.none:
        property.type = fbm.WidgetPropertyType.None;
        property.valueType = fbm.WidgetPropertyValueTypeId.NONE;
        property.value = null;
        break;
    }

    return property;
  }
}
