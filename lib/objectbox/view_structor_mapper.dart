import 'dart:typed_data';
import 'dart:ui' show Offset, Size;
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/generated/view_view_structure_generated.dart' as vs;

class ViewStructureMapper {
  static List<ViewConfigPage> pagesFromView(vs.View view) {
    final data = view.data;
    if (data == null || data.isEmpty) return [];

    final buffer = data is Uint8List ? data : Uint8List.fromList(data);
    final bufferContext = fb.BufferContext.fromBytes(buffer);

    final fbPages = const fb.ListReader<vs.Page>(
      vs.Page.reader,
    ).read(bufferContext, 0);

    return [for (var i = 0; i < fbPages.length; i++) _mapPage(fbPages[i])];
  }

  static ViewConfigPage _mapPage(vs.Page page) {
    final items = <ViewConfigItem>[];
    for (var i = 0; i < (page.widgets?.length ?? 0); i++) {
      final widget = page.widgets?[i];
      if (widget == null) continue;
      items.add(_mapWidget(widget));
    }
    return ViewConfigPage(
      id: page.id.toInt(),
      pageNumber: page.number,
      items: items,
    );
  }

  static ViewConfigItem _mapWidget(vs.Widget widget) {
    final properties = <ViewConfigProperty>[];
    for (var i = 0; i < (widget.properties?.length ?? 0); i++) {
      final prop = widget.properties?[i];
      if (prop == null) continue;
      final mapped = _mapProperty(prop);
      if (mapped != null) properties.add(mapped);
    }
    return ViewConfigItem(
      id: widget.id.toInt(),
      position: Offset((widget.xPos).toDouble(), (widget.yPos).toDouble()),
      size: Size((widget.width).toDouble(), (widget.height).toDouble()),
      widgetType: widget.widgetId,
      properties: properties,
    );
  }

  static ViewConfigProperty? _mapProperty(vs.WidgetProperty prop) {
    final keyId = prop.keyId;
    return switch (prop.valueType) {
      vs.WidgetPropertyValueTypeId.StringValue => ViewConfigProperty(
        key: keyId,
        type: ViewConfigPropertyType.string,
        stringValue: (prop.value as vs.StringValue?)?.value ?? '',
      ),
      vs.WidgetPropertyValueTypeId.IntValue => ViewConfigProperty(
        key: keyId,
        type: ViewConfigPropertyType.int,
        intValue: (prop.value as vs.IntValue?)?.value ?? 0,
      ),
      vs.WidgetPropertyValueTypeId.FloatValue => ViewConfigProperty(
        key: keyId,
        type: ViewConfigPropertyType.float,
        floatValue: (prop.value as vs.FloatValue?)?.value ?? 0.0,
      ),
      vs.WidgetPropertyValueTypeId.BoolValue => ViewConfigProperty(
        key: keyId,
        type: ViewConfigPropertyType.bool,
        boolValue: (prop.value as vs.BoolValue?)?.value ?? false,
      ),
      vs.WidgetPropertyValueTypeId.RawBytes => ViewConfigProperty(
        key: keyId,
        type: ViewConfigPropertyType.rawBytes,
        rawBytes: (prop.value as vs.RawBytes?)?.data != null
            ? Uint8List.fromList((prop.value as vs.RawBytes).data!)
            : null,
      ),
      _ => null,
    };
  }
}
