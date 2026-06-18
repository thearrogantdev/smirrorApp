import 'package:equatable/equatable.dart';
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart'
    as dash;
import 'package:smirror_wire/generated/frame_frame_data_generated.dart'
    as frame_data;
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;


abstract class BackAppWebSocketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BackAppWebSocketInitial extends BackAppWebSocketState {}

class BackAppWebSocketFailure extends BackAppWebSocketState {
  final String error;
  BackAppWebSocketFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class BackAppWebSocketResultReceived extends BackAppWebSocketState {
  final backmsg.ResultT result;
  BackAppWebSocketResultReceived(this.result);
  @override
  List<Object?> get props => [result];
}

class BackAppWebSocketStatusReceived extends BackAppWebSocketState {
  final backmsg.StatusT status;
  BackAppWebSocketStatusReceived(this.status);
  @override
  List<Object?> get props => [status];
}

class BackAppWebSocketGotNewView extends BackAppWebSocketState {}

class BackAppWebSocketWelcomeReceived extends BackAppWebSocketState {
  final backmsg.WelcomeMessageT welcomeMessage;
  final bool needUpdate;
  final int viewId;
  final bool isDirty;
  BackAppWebSocketWelcomeReceived(
    this.welcomeMessage,
    this.needUpdate,
    this.viewId, {
    this.isDirty = false,
  });
  @override
  List<Object?> get props => [welcomeMessage, needUpdate, viewId, isDirty];
}

class BackAppWebSocketUnknownPayload extends BackAppWebSocketState {
  final int payloadType;
  BackAppWebSocketUnknownPayload(this.payloadType);
  @override
  List<Object?> get props => [payloadType];
}

class BackAppWebSocketGotLogs extends BackAppWebSocketState {
  final List<String> logs;
  BackAppWebSocketGotLogs(this.logs);
  @override
  List<Object?> get props => [logs];
}

class BackAppWebSocketGotAdminInfo extends BackAppWebSocketState {
  final backmsg.AdminInfoT info;
  BackAppWebSocketGotAdminInfo({required this.info});
  @override
  List<Object?> get props => [info];
}

class BackAppWebSocketGotNewUpdateAvailable extends BackAppWebSocketState {
  final backmsg.NewUpdateAvailableT updateInfo;
  BackAppWebSocketGotNewUpdateAvailable(this.updateInfo);
  @override
  List<Object?> get props => [updateInfo];
}

class BackAppWebSocketGotToken extends BackAppWebSocketState {
  final backmsg.GetTokenT token;
  BackAppWebSocketGotToken(this.token);
  @override
  List<Object?> get props => [token];
}

class BackAppWebSocketGotDashboardInfo extends BackAppWebSocketState {
  final List<dash.DashboardInfo> dashboardInfo;
  BackAppWebSocketGotDashboardInfo(this.dashboardInfo);
  @override
  List<Object?> get props => [dashboardInfo];
}


class BackAppWebSocketGotFrame extends BackAppWebSocketState {
  final frame_data.FrameT frame;
  BackAppWebSocketGotFrame(this.frame);
  @override
  List<Object?> get props => [frame];
}

class BackAppWebSocketDashboardSynced extends BackAppWebSocketState {
  final int backendId;
  BackAppWebSocketDashboardSynced(this.backendId);
  @override
  List<Object?> get props => [backendId];
}

class BackAppWebSocketVerificationCodeReceived extends BackAppWebSocketState {
  final backmsg.VerificationCodeT code;
  BackAppWebSocketVerificationCodeReceived(this.code);
  @override
  List<Object?> get props => [code];
}

class BackAppWebSocketGotTomlConfig extends BackAppWebSocketState {
  final backmsg.TomlConfigT tomlConfig;
  BackAppWebSocketGotTomlConfig(this.tomlConfig);
  @override
  List<Object?> get props => [tomlConfig];
}
