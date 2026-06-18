import 'dart:typed_data';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/database/relations_compatibility.dart';
import 'package:smirror_app/database/view_config.dart';

class ViewConfigPropertyMapper {
  /// Convert in-memory `ViewConfigProperty` to a `WidgetPropertyEntity` + associated typed value(s).
  static WidgetPropertyEntity toEntity(ViewConfigProperty prop, int widgetId) {
    final propEntity = WidgetPropertyEntity(
      keyId: prop.key,
      type: prop.type.index,
    )..widget.targetId = widgetId;

    switch (prop.type) {
      case ViewConfigPropertyType.string:
        final v = WidgetPropertyStringEntity(value: prop.stringValue ?? '');
        v.property.target = propEntity;
        propEntity.stringValues.add(v);
        break;

      case ViewConfigPropertyType.int:
        final v = WidgetPropertyIntEntity(value: prop.intValue ?? 0);
        v.property.target = propEntity;
        propEntity.intValues.add(v);
        break;

      case ViewConfigPropertyType.float:
        final v = WidgetPropertyFloatEntity(value: prop.floatValue ?? 0.0);
        v.property.target = propEntity;
        propEntity.floatValues.add(v);
        break;

      case ViewConfigPropertyType.bool:
        final v = WidgetPropertyBoolEntity(value: prop.boolValue ?? false);
        v.property.target = propEntity;
        propEntity.boolValues.add(v);
        break;

      case ViewConfigPropertyType.rawBytes:
        final v = WidgetPropertyRawBytesEntity(
          value: prop.rawBytes ?? Uint8List(0),
        );
        v.property.target = propEntity;
        propEntity.rawBytes.add(v);
        break;

      case ViewConfigPropertyType.none:
        break;
    }

    return propEntity;
  }

  /// Convert a list of DB `WidgetPropertyEntity` back to `ViewConfigProperty`s, sorted by key.
  static List<ViewConfigProperty> fromEntities(
    ToMany<WidgetPropertyEntity> dbProps,
  ) {
    final sorted = dbProps.toList()..sort((a, b) => a.keyId.compareTo(b.keyId));

    return sorted.map((p) {
      final type = ViewConfigPropertyType.values[p.type];

      switch (type) {
        case ViewConfigPropertyType.string:
          return ViewConfigProperty(
            key: p.keyId,
            type: type,
            stringValue: p.stringValues.firstOrNull?.value,
          );

        case ViewConfigPropertyType.int:
          return ViewConfigProperty(
            key: p.keyId,
            type: type,
            intValue: p.intValues.firstOrNull?.value,
          );

        case ViewConfigPropertyType.float:
          return ViewConfigProperty(
            key: p.keyId,
            type: type,
            floatValue: p.floatValues.firstOrNull?.value,
          );

        case ViewConfigPropertyType.bool:
          return ViewConfigProperty(
            key: p.keyId,
            type: type,
            boolValue: p.boolValues.firstOrNull?.value,
          );

        case ViewConfigPropertyType.rawBytes:
          return ViewConfigProperty(
            key: p.keyId,
            type: type,
            rawBytes: p.rawBytes.firstOrNull?.value,
          );

        case ViewConfigPropertyType.none:
          return ViewConfigProperty(key: p.keyId, type: type);
      }
    }).toList();
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
