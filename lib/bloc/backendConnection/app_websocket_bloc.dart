import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:get_it/get_it.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart'
    as backmsg;
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart'
    as dash;
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:smirror_app/database/view_store.dart';
import 'package:smirror_app/database/binary_database.dart';
import 'package:smirror_app/services/binary_transfer_repository.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;
import 'package:smirror_wire/generated/view_view_structure_generated.dart'
    as vs;
import 'app_websocket_event.dart';
import 'app_websocket_state.dart';
import '../../services/websocket_service.dart';

class AppWebSocketBloc extends Bloc<AppWebSocketEvent, AppWebSocketState> {
  final WebSocketService _websocketService = GetIt.I<WebSocketService>();
  final BinaryTransferRepository _binaryRepo =
      GetIt.I<BinaryTransferRepository>();
  final _haStore = GetIt.I<HomeAssistantStore>();
  final int _headroom = 2048; // envelope safety
  final UserService _userService = GetIt.I<UserService>();

  AppWebSocketBloc() : super(AppWebSocketInitial()) {
    on<AppWebSocketSendSimpleCommandRequested>(_onSendSimpleCommand);
    on<AppWebSocketActivateUserRequested>(_onActivateUser);
    on<AppWebSocketStartFaceTrainingRequested>(_onStartFaceTraining);
    on<AppWebSocketSendViewRequest>(_onSendViewCommand);
    on<AppWebSocketSendToken>(_onSendToken);
    on<AppWebSocketAddTokenToUser>(_onAddTokenToUser);
    on<AppWebSocketRequestGoogleToken>(_onRequestGoogleToken);
    on<AppWebSocketGetToken>(_onGetToken);
    on<AppWebSocketRequestLogs>(_onRequestLogs);
    on<AppWebSocketSendDashboardRequest>(_onSendDashboard);
    on<AppWebSocketRequestDashboardUpdate>(_onRequestDashboardUpdate);
    on<AppWebSocketChangeUserPermission>(_onChangeUserPermission);
    on<AppWebSocketDeleteUser>(_onDeleteUser);
    on<AppWebSocketChangeDeviceSettings>(_onChangeDeviceSettings);
    on<AppWebSocketChangePassword>(_onChangePassword);
    on<AppWebSocketChangeLEDs>(_onChangeLEDs);
    on<AppWebSocketDeleteToken>(_onDeleteToken);
    on<AppWebSocketDeleteDashboardRequest>(_onDeleteDashboard);
    on<AppWebSocketUploadConfig>(_onUploadConfig);
  }

  void _onSendSimpleCommand(
    AppWebSocketSendSimpleCommandRequested event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.SimpleCommand,
      payload: appmsg.SimpleCommandT(type: event.commandType),
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onActivateUser(
    AppWebSocketActivateUserRequested event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = appmsg.ActivateUserT(
      userPassword: _websocketService.password,
    );
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.ActivateUser,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onStartFaceTraining(
    AppWebSocketStartFaceTrainingRequested event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = appmsg.StartFaceTrainingT(
      userPassword: _websocketService.password,
    );
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.StartFaceTraining,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  Future<void> _onSendViewCommand(
    AppWebSocketSendViewRequest event,
    Emitter<AppWebSocketState> emit,
  ) async {
    int index = 1;
    List<int> ids = [];
    for (final page in event.currentView) {
      for (final widget in page.items) {
        if (widget.widgetType != WidgetIds.image) continue;
        final propId = widget.properties.firstWhere(
          (p) => p.key == GeneralIds.binary,
        );
        if (propId.intValue != 0) {
          ids.add(propId.intValue!);
          continue; // already uploaded
        }
        final localPath =
            widget.properties
                .firstWhere((p) => p.key == GeneralIds.binaryPath)
                .stringValue ??
            "";
        if (localPath.isEmpty) continue;

        final file = File(localPath);

        if (!await file.exists()) {
          continue;
        }

        final bytes = await file.readAsBytes();
        final fileName = file.uri.pathSegments.last;
        final result = await _onSendBinaryAutoBytes(
          fileName,
          appmsg.ContentType.image,
          bytes,
        );
        final m = RegExp(r'id=(\d+)').firstMatch(result.errorMessage ?? '');
        final newId = m != null ? int.tryParse(m.group(1)!) : 0;
        if (newId != null && newId != 0) {
          propId.intValue = newId;
          ids.add(newId);
          await GetIt.I<BinaryDatabase>().insertBinary(newId, localPath);
          // is used by the ui to show the progress and to save the changed id
          emit(AppWebSocketBinaryCompletedForItem(widget, index));
        }
        ++index;
      }
    }
    // after everything is stored we get the path. We don't want to do it in the for loop
    // because the binary ID must be stored permanently the path should only be changed temporary
    final builder = fb.Builder(initialSize: 1024);

    final pathIds = appmsg.BinaryPathIdsT(ids: ids);

    final messageBinary = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.BinaryPathIds,
      payload: pathIds,
    );

    builder.finish(messageBinary.pack(builder));
    _websocketService.send(builder.buffer);

    final pathes = await _binaryRepo.waitPaths(
      ids,
      timeout: const Duration(seconds: 10),
    );
    Map<int, String> originalPathes = {};

    builder.reset();

    for (final page in event.currentView) {
      for (final widget in page.items) {
        if (widget.widgetType != WidgetIds.image) continue;
        final propId =
            widget.properties
                .firstWhere((p) => p.key == GeneralIds.binary)
                .intValue ??
            0;
        final localPath = widget.properties.firstWhere(
          (p) => p.key == GeneralIds.binaryPath,
        );
        originalPathes[propId] = localPath.stringValue ?? "";
        final resolved = pathes[propId];
        if (resolved != null && resolved.isNotEmpty) {
          localPath.stringValue = resolved;
        }
      }
    }

    final viewStore = GetIt.I<ViewStore>();
    final viewEntity = viewStore.getViewForUser(
      _userService.currentUser?.localUserId ?? 0,
    );

    // Capture the send moment as the new canonical timestamp.
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    // Serialize pages into the opaque blob — the backend stores and returns
    // these bytes unchanged, so the full widget graph stays Flutter-owned.
    final innerBuilder = fb.Builder();
    final pageOffsets = event.currentView
        .map((page) => page.toFlatbuf().pack(innerBuilder))
        .toList();
    innerBuilder.finish(innerBuilder.writeList(pageOffsets));
    final data = Uint8List.fromList(innerBuilder.buffer);

    final viewConfig = vs.ViewT(
      timestamp: timestamp,
      language: viewEntity?.language ?? 'en',
      theme: viewEntity?.theme ?? 0,
      data: data,
    );

    // Persist the timestamp so we can reject any backend echo older than this.
    if (viewEntity != null) {
      viewStore.updateViewTimestamp(viewEntity.id, timestamp);
    }

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.viewStructure_View,
      payload: viewConfig,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);

    // reset the pathes
    for (final page in event.currentView) {
      for (final widget in page.items) {
        if (widget.widgetType != WidgetIds.image) continue;
        final propId =
            widget.properties
                .firstWhere((p) => p.key == GeneralIds.binary)
                .intValue ??
            0;
        final localPath = widget.properties.firstWhere(
          (p) => p.key == GeneralIds.binaryPath,
        );
        final resolved = originalPathes[propId];
        if (resolved != null && resolved.isNotEmpty) {
          localPath.stringValue = resolved;
        }
      }
    }
  }

  Future<void> _onSendDashboard(
    AppWebSocketSendDashboardRequest event,
    Emitter<AppWebSocketState> emit,
  ) async {
    // Load data from ObjectBox
    final dashboard = _haStore.getDashboardByLocalId(event.dashboardId);
    if (dashboard == null) return;
    String backgroundPath = "";
    // --- Handle Background Image Upload ---
    if (dashboard.backgroundImagePath != null &&
        dashboard.backgroundImagePath!.isNotEmpty) {
      final file = File(dashboard.backgroundImagePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final result = await _onSendBinaryAutoBytes(
          file.uri.pathSegments.last,
          appmsg.ContentType.image,
          bytes,
        );

        final m = RegExp(r'id=(\d+)').firstMatch(result.errorMessage ?? '');
        final newId = m != null ? int.tryParse(m.group(1)!) : 0;

        if (newId != null && newId != 0) {
          final builder = fb.Builder(initialSize: 1024);

          final pathIds = appmsg.BinaryPathIdsT(ids: [newId]);

          final messageBinary = appmsg.AppBackMessageT(
            payloadType: appmsg.AppBackPayloadTypeId.BinaryPathIds,
            payload: pathIds,
          );

          builder.finish(messageBinary.pack(builder));
          _websocketService.send(builder.buffer);

          final pathes = await _binaryRepo.waitPaths([
            newId,
          ], timeout: const Duration(seconds: 10));
          backgroundPath = pathes[newId] ?? "";
          await GetIt.I<BinaryDatabase>().insertBinary(newId, dashboard.backgroundImagePath!);
          dashboard.backgroundImageId = newId;
          _haStore.saveDashboard(
            dashboard,
          ); // Update local ObjectBox with the new ID
        }
      }
    }

    final builder = fb.Builder(initialSize: 1024);

    // Serialize DashboardData as the opaque blob — backend stores bytes unchanged.
    final itemsT = dashboard.items.map((item) {
      final thresholdsT = item.thresholds
          .map(
            (t) => dash.ThresholdConfigT(
              id: t.id,
              triggerValue: t.triggerValue,
              iconCodePoint: t.iconCodePoint,
              colorValue: t.colorValue,
            ),
          )
          .toList();

      return dash.DashboardItemT(
        id: item.id,
        entityId: item.entityId,
        displayName: item.displayName,
        xPos: item.x,
        yPos: item.y,
        width: item.width,
        height: item.height,
        type: item.dbType == 0
            ? dash.DashboardItemType.Boolean
            : dash.DashboardItemType.Numeric,
        standardIconCodePoint: item.standardIconCodePoint,
        standardColorValue: item.standardColorValue,
        unitOverride: item.unitOverride ?? "",
        thresholds: thresholdsT,
      );
    }).toList();

    final innerBuilder = fb.Builder();
    final dashboardDataT = dash.DashboardDataT(
      items: itemsT,
      backgroundImageId: dashboard.backgroundImageId,
      backgroundImagePath: backgroundPath,
      width: dashboard.width,
      height: dashboard.height,
    );
    innerBuilder.finish(dashboardDataT.pack(innerBuilder));
    final dashboardData = Uint8List.fromList(innerBuilder.buffer);

    final timestamp = DateTime.now().microsecondsSinceEpoch;

    final dashboardT = dash.DashboardT(
      appId: dashboard.id,
      backendId: dashboard.backendId,
      name: dashboard.name,
      dashboardData: dashboardData,
      timestamp: timestamp,
    );

    _haStore.updateDashboardTimestamp(dashboard.id, timestamp);

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.dashboardStructure_Dashboard,
      payload: dashboardT,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onSendToken(
    AppWebSocketSendToken event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final add = appmsg.AddTokenT(
      provider: event.provider,
      accessToken: event.accessToken,
      refreshToken: event.refreshToken,
      tokenType: event.tokenType,
      expiresAt: event.expiresAtMs,
      userPassword: event.adminPassword,
      url: event.url,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.AddToken,
      payload: add,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onRequestGoogleToken(
    AppWebSocketRequestGoogleToken event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final add = appmsg.RequestGoogleTokenT(
      code: event.code,
      userPassword: event.adminPassword,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.RequestGoogleToken,
      payload: add,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onAddTokenToUser(
    AppWebSocketAddTokenToUser event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final add = appmsg.AddTokenToUserT(
      userId: event.userId,
      userPassword: event.userPassword,
      adminPassword: event.adminPassword,
      provider: event.provider,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.AddTokenToUser,
      payload: add,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onGetToken(
    AppWebSocketGetToken event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final add = appmsg.GetTokenT(provider: event.provider, userPassword: _websocketService.password);

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.GetToken,
      payload: add,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  Future<backmsg.ResultT> _onSendBinaryAutoBytes(
    String fileName,
    appmsg.ContentType contentType,
    Uint8List data,
  ) async {
    final cap = _binaryRepo.maxMessageSize.value ?? (512 * 1024);
    final maxSingle = cap - _headroom;
    final tid = DateTime.now().microsecondsSinceEpoch;

    // --- SINGLE PHASE ---
    if (data.lengthInBytes <= maxSingle) {
      final builder = fb.Builder(initialSize: 32 + data.lengthInBytes);
      final binT = appmsg.BinaryT(
        phase: appmsg.BinaryPhase.SINGLE,
        transferId: tid,
        fileName: fileName,
        contentType: contentType,
        totalSize: data.lengthInBytes,
        data: data,
      );
      final msgT = appmsg.AppBackMessageT(
        payloadType: appmsg.AppBackPayloadTypeId.Binary,
        payload: binT,
      );
      builder.finish(msgT.pack(builder));
      _websocketService.send(builder.buffer);

      return await _binaryRepo.registerTransfer(
        tid,
        timeout: const Duration(seconds: 15),
      );
    }

    // --- CHUNKED PHASE ---

    // BEGIN
    {
      final b = fb.Builder(initialSize: 256);
      final beginT = appmsg.BinaryT(
        phase: appmsg.BinaryPhase.BEGIN,
        transferId: tid,
        fileName: fileName,
        contentType: contentType,
        totalSize: data.lengthInBytes,
      );
      final msgT = appmsg.AppBackMessageT(
        payloadType: appmsg.AppBackPayloadTypeId.Binary,
        payload: beginT,
      );
      b.finish(msgT.pack(b));
      _websocketService.send(b.buffer);

      // WAIT for BINARY_ACCEPTED before sending the first chunk
      await _binaryRepo.acceptedSignals
          .firstWhere((id) => id == tid)
          .timeout(const Duration(seconds: 5));
    }

    // CHUNKS
    final maxChunkPayload = (cap - _headroom).clamp(8 * 1024, 512 * 1024);
    int idx = 0;
    for (int off = 0; off < data.length; off += maxChunkPayload) {
      final end = (off + maxChunkPayload < data.length)
          ? off + maxChunkPayload
          : data.length;
      final chunk = Uint8List.sublistView(data, off, end);

      final b = fb.Builder(initialSize: 32 + chunk.lengthInBytes);
      final chunkT = appmsg.BinaryT(
        phase: appmsg.BinaryPhase.CHUNK,
        transferId: tid,
        index: idx++,
        data: chunk,
      );
      final msgT = appmsg.AppBackMessageT(
        payloadType: appmsg.AppBackPayloadTypeId.Binary,
        payload: chunkT,
      );
      b.finish(msgT.pack(b));
      _websocketService.send(b.buffer);

      // CRITICAL: Wait for this specific chunk to be processed by C++
      // This provides the necessary backpressure
      await _binaryRepo.chunkAcks
          .firstWhere((id) => id == tid)
          .timeout(const Duration(seconds: 10));
    }

    final resultFuture = _binaryRepo.registerTransfer(
      tid,
      timeout: const Duration(seconds: 15),
    );
    // END
    {
      final b = fb.Builder(initialSize: 256);
      final endT = appmsg.BinaryT(
        phase: appmsg.BinaryPhase.END,
        transferId: tid,
      );
      final msgT = appmsg.AppBackMessageT(
        payloadType: appmsg.AppBackPayloadTypeId.Binary,
        payload: endT,
      );
      b.finish(msgT.pack(b));
      _websocketService.send(b.buffer);
    }

    // Final wait for BINARY_COMPLETE which contains the new ID
    return await resultFuture;
  }

  void _onRequestLogs(
    AppWebSocketRequestLogs event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = appmsg.GetLogsT(numOfMessages: event.numOfMessages);

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.GetLogs,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onRequestDashboardUpdate(
    AppWebSocketRequestDashboardUpdate event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = dash.UpdateT(backendId: event.dashboardBackendId);

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.dashboardStructure_Update,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onChangeUserPermission(
    AppWebSocketChangeUserPermission event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = appmsg.SetUserRightsT(
      rights: event.rights,
      userId: event.userId,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.SetUserRights,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onDeleteUser(
    AppWebSocketDeleteUser event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.DeleteUser,
      payload: appmsg.DeleteUserT(userId: event.userId),
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onChangeDeviceSettings(
    AppWebSocketChangeDeviceSettings event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final payload = appmsg.ChangeDeviceSettingsT(
      autoSwitch: event.autoSwitch,
      deviceName: event.deviceName,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.ChangeDeviceSettings,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onChangePassword(
    AppWebSocketChangePassword event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 512);
    final payload = appmsg.ChangeUserPasswordT(
      oldPassword: GetIt.I<WebSocketService>().password,
      newPassword: event.newPassword,
    );
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.ChangeUserPassword,
      payload: payload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onChangeLEDs(
    AppWebSocketChangeLEDs event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final led = appmsg.ChangeLedsT(
      red: event.red,
      green: event.green,
      blue: event.blue,
      brightness: event.brightness,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.ChangeLeds,
      payload: led,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onDeleteToken(
    AppWebSocketDeleteToken event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final deleteToken = appmsg.DeleteTokenT(
      provider: event.provider,
      userId: event.userID,
    );

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.DeleteToken,
      payload: deleteToken,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onDeleteDashboard(
    AppWebSocketDeleteDashboardRequest event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: 256);
    final deletePayload = dash.DeleteT(backendId: event.dashboardBackendId);

    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.dashboardStructure_Delete,
      payload: deletePayload,
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }

  void _onUploadConfig(
    AppWebSocketUploadConfig event,
    Emitter<AppWebSocketState> emit,
  ) {
    final builder = fb.Builder(initialSize: event.config.length + 256);
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.UploadConfig,
      payload: appmsg.UploadConfigT(config: event.config),
    );

    builder.finish(message.pack(builder));
    _websocketService.send(builder.buffer);
  }
}
