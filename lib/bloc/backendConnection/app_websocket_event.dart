import 'dart:core';
import 'package:equatable/equatable.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart'
    show ViewConfigPage;
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;

abstract class AppWebSocketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppWebSocketConnectRequested extends AppWebSocketEvent {
  final String url;
  final Map<String, String> headers;
  AppWebSocketConnectRequested({required this.url, required this.headers});
}

class AppWebSocketDisconnectRequested extends AppWebSocketEvent {}

/// Generic event for sending raw bytes
class AppWebSocketMessageSendRequested extends AppWebSocketEvent {
  final List<int> message;
  AppWebSocketMessageSendRequested(this.message);
}

class AppWebSocketRequestDashboardUpdate extends AppWebSocketEvent {
  final int dashboardBackendId;
  AppWebSocketRequestDashboardUpdate({required this.dashboardBackendId});

  @override
  List<Object?> get props => [dashboardBackendId];
}

class AppWebSocketRequestLogs extends AppWebSocketEvent {
  final int numOfMessages;
  AppWebSocketRequestLogs({required this.numOfMessages});

  @override
  List<Object?> get props => [numOfMessages];
}

class AppWebSocketSendSimpleCommandRequested extends AppWebSocketEvent {
  final appmsg.AppSimpleCommandType commandType;

  AppWebSocketSendSimpleCommandRequested({required this.commandType});

  @override
  List<Object?> get props => [commandType];
}

class AppWebSocketActivateUserRequested extends AppWebSocketEvent {}

class AppWebSocketStartFaceTrainingRequested extends AppWebSocketEvent {}

class AppWebSocketSendViewRequest extends AppWebSocketEvent {
  final List<ViewConfigPage> currentView;
  AppWebSocketSendViewRequest(this.currentView);

  @override
  List<Object?> get props => [currentView];
}

class AppWebSocketSendToken extends AppWebSocketEvent {
  final String provider;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresAtMs;
  final String adminPassword;

  final String url;

  AppWebSocketSendToken({
    required this.provider,
    required this.accessToken,
    required this.adminPassword,
    this.refreshToken = "",
    this.tokenType = "",
    this.expiresAtMs = 0,
    this.url = "",
  });

  @override
  List<Object?> get props => [
    provider,
    accessToken,
    refreshToken,
    tokenType,
    expiresAtMs,
    adminPassword,
    url,
  ];
}

class AppWebSocketAddTokenToUser extends AppWebSocketEvent {
  final int userId;
  final String userPassword;
  final String adminPassword;
  final String provider;

  AppWebSocketAddTokenToUser({
    required this.userId,
    required this.userPassword,
    required this.adminPassword,
    required this.provider,
  });

  @override
  List<Object?> get props => [userId, userPassword, adminPassword, provider];
}

class AppWebSocketGetToken extends AppWebSocketEvent {
  final String provider;

  AppWebSocketGetToken({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class AppWebSocketSendDashboardRequest extends AppWebSocketEvent {
  final int dashboardId;
  AppWebSocketSendDashboardRequest(this.dashboardId);
}

class AppWebSocketChangeUserPermission extends AppWebSocketEvent {
  final int userId;
  final int rights;
  AppWebSocketChangeUserPermission({
    required this.userId,
    required this.rights,
  });
}

class AppWebSocketDeleteUser extends AppWebSocketEvent {
  final int userId;
  AppWebSocketDeleteUser(this.userId);
}

class AppWebSocketChangeDeviceSettings extends AppWebSocketEvent {
  final bool autoSwitch;
  final String deviceName;
  AppWebSocketChangeDeviceSettings({
    required this.autoSwitch,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [autoSwitch, deviceName];
}

class AppWebSocketChangePassword extends AppWebSocketEvent {
  final String newPassword;
  AppWebSocketChangePassword({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class AppWebSocketChangeLEDs extends AppWebSocketEvent {
  final int red;
  final int green;
  final int blue;
  final int brightness;

  AppWebSocketChangeLEDs({
    required this.red,
    required this.green,
    required this.blue,
    required this.brightness,
  });

  @override
  List<Object?> get props => [red, green, blue, brightness];
}

class AppWebSocketDeleteToken extends AppWebSocketEvent {
  final String provider;
  final int userID;

  AppWebSocketDeleteToken({required this.provider, this.userID = 0});

  @override
  List<Object?> get props => [provider, userID];
}

class AppWebSocketDeleteDashboardRequest extends AppWebSocketEvent {
  final int dashboardBackendId;
  AppWebSocketDeleteDashboardRequest({required this.dashboardBackendId});

  @override
  List<Object?> get props => [dashboardBackendId];
}

class AppWebSocketUploadConfig extends AppWebSocketEvent {
  final String config;

  AppWebSocketUploadConfig({required this.config});

  @override
  List<Object?> get props => [config];
}

class AppWebSocketRequestGoogleToken extends AppWebSocketEvent {
  final String code;
  final String adminPassword;

  AppWebSocketRequestGoogleToken({
    required this.code,
    required this.adminPassword
  });

  @override
  List<Object?> get props => [code, adminPassword];
}
