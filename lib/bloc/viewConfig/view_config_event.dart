import 'dart:ui' show Offset, Size;
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart'
    show ViewConfigProperty, ViewConfigItem;
import 'package:smirror_app/services/user_service.dart';

abstract class ViewConfigEvent {}

class AddPageEvent extends ViewConfigEvent {}

class RemovePageEvent extends ViewConfigEvent {}

class SwitchPageEvent extends ViewConfigEvent {
  final int index;
  SwitchPageEvent(this.index);
}

class AddItemEvent extends ViewConfigEvent {
  final Offset position;
  final Size size;
  final int widgetType;
  final List<ViewConfigProperty> properties;
  AddItemEvent(this.position, this.size, this.widgetType, this.properties);
}

class UpdateItemEvent extends ViewConfigEvent {
  final ViewConfigItem updatedItem;

  UpdateItemEvent(this.updatedItem);
}

class RemoveItemEvent extends ViewConfigEvent {
  final ViewConfigItem item;
  RemoveItemEvent(this.item);
}

class ToggleSnapEvent extends ViewConfigEvent {}

class SetThemeEvent extends ViewConfigEvent {
  final int theme;
  SetThemeEvent(this.theme);
}

class SetLanguageEvent extends ViewConfigEvent {
  final String language;
  SetLanguageEvent(this.language);
}

class UserChangedEvent extends ViewConfigEvent {
  final User? user;
  UserChangedEvent(this.user);
}
