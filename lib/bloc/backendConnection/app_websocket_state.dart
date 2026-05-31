import 'package:equatable/equatable.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart';

abstract class AppWebSocketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppWebSocketInitial extends AppWebSocketState {}

class AppWebSocketConnecting extends AppWebSocketState {}

class AppWebSocketConnected extends AppWebSocketState {}

class AppWebSocketDisconnected extends AppWebSocketState {}

class AppWebSocketBinaryCompletedForItem extends AppWebSocketState {
  final ViewConfigItem updatedItem;
  final int index;

  AppWebSocketBinaryCompletedForItem(this.updatedItem, this.index);
  @override
  List<Object?> get props => [updatedItem, index];
}

class AppWebSocketBinaryCompleted extends AppWebSocketState {
  final ResultT result;
  AppWebSocketBinaryCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

class AppWebSocketFailure extends AppWebSocketState {
  final String error;
  AppWebSocketFailure(this.error);
  @override
  List<Object?> get props => [error];
}
