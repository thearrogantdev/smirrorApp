import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:smirror_app/services/binary_saver.dart'
    if (dart.library.js_interop) 'package:smirror_app/services/binary_saver_web.dart'
    if (dart.library.io) 'package:smirror_app/services/binary_saver_native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/database/home_dashboard.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;
import 'package:smirror_wire/generated/back_app_back_app_generated.dart'
    as backmsg;
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart'
    as dash;
import 'package:smirror_wire/generated/frame_frame_data_generated.dart'
    as frame_data;
import 'package:smirror_wire/generated/view_view_structure_generated.dart' as vs;
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:smirror_app/database/view_store.dart';
import 'package:smirror_app/database/binary_database.dart';
import 'package:smirror_app/database/view_structor_mapper.dart';
import 'package:smirror_app/services/binary_transfer_repository.dart';
import 'package:smirror_app/services/google_token_service.dart';
import 'package:smirror_app/services/session_context_service.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/services/backend_http_proxy_service.dart';
import 'back_app_websocket_state.dart';

class BackAppWebSocketBloc extends Cubit<BackAppWebSocketState> {
  final WebSocketService service = GetIt.I<WebSocketService>();
  final BinaryTransferRepository repo = GetIt.I<BinaryTransferRepository>();
  final SessionContextService features = GetIt.I<SessionContextService>();
  final ViewStore viewStore = GetIt.I<ViewStore>();
  final HomeAssistantStore haStore = GetIt.I<HomeAssistantStore>();
  final UserService user = GetIt.I<UserService>();

  // Accumulates chunks for in-progress incoming transfers
  final _incoming = <int, _BinaryReceiveBuffer>{};

  // Track dashboard updates that were explicitly requested/initiated by the user
  final Set<int> _userInitiatedDashboardUpdates = {};

  void registerUserInitiatedDashboardUpdate(int backendId) {
    _userInitiatedDashboardUpdates.add(backendId);
  }

  BackAppWebSocketBloc() : super(BackAppWebSocketInitial()) {
    _listen();
  }

  void _listen() {
    service.stream.listen((data) async {
      final rawMessage = backmsg.BackAppMessage(data);
      final message = rawMessage.unpack();

      switch (message.payloadType) {
        case backmsg.BackAppPayloadTypeId.Result:
          final result = (rawMessage.payload as backmsg.Result).unpack();
          emit(BackAppWebSocketResultReceived(result));

          if (result.transferId != 0) {
            switch (result.errorCode) {
              case backmsg.ErrorCode.BINARY_CHUNK_OK:
                repo.notifyChunkAck(result.transferId);
                break;
              case backmsg.ErrorCode.BINARY_ACCEPTED:
                repo.notifyAccepted(result.transferId);
                break;
              case backmsg.ErrorCode.BINARY_COMPLETE:
              default:
                repo.completeTransfer(result.transferId, result);
                break;
            }
          }
          break;

        case backmsg.BackAppPayloadTypeId.BinaryPathes:
          final path = rawMessage.payload as backmsg.BinaryPathes;
          final items = path.pathes ?? [];
          final map = <int, String>{};
          for (var i = 0; i < items.length; i++) {
            final row = items[i];
            map[row.id] = row.path ?? '';
          }
          repo.ingestPaths(map);
          break;

        case backmsg.BackAppPayloadTypeId.dashboardStructure_DashboardSaved:
          final saved = rawMessage.payload as dash.DashboardSaved;
          final localId = saved.id.toInt();
          final backendId = saved.backendId.toInt();

          if (localId == 0 || backendId == 0) break;

          final dashboard = haStore.getDashboardByLocalId(localId);
          if (dashboard == null) break;

          dashboard.backendId = backendId;
          haStore.saveDashboard(dashboard);
          break;

        case backmsg.BackAppPayloadTypeId.dashboardStructure_Dashboard:
          final remoteDash = rawMessage.payload as dash.Dashboard;
          final backendId = remoteDash.backendId.toInt();
          if (backendId == 0) break;

          final rawData = remoteDash.dashboardData;
          if (rawData == null || rawData.isEmpty) break;

          final dashboardDataT = dash.DashboardData(rawData).unpack();

          final dashboard =
              haStore.getDashboardByBackendId(backendId) ??
                  Dashboard(name: remoteDash.name ?? '', order: 0);

          dashboard.backendId = backendId;
          dashboard.name = remoteDash.name ?? dashboard.name;
          dashboard.timestamp = remoteDash.timestamp.toInt();
          dashboard.backgroundImageId = dashboardDataT.backgroundImageId;
          final bgId = dashboardDataT.backgroundImageId;
          if (bgId != 0) {
            final localPath = await GetIt.I<BinaryDatabase>().getBinaryPath(bgId);
            if (localPath != null && localPath.isNotEmpty && (kIsWeb || await File(localPath).exists())) {
              dashboard.backgroundImagePath = localPath;
            } else {
              dashboard.backgroundImagePath = null;
              _sendUpdateBinary([bgId]);
            }
          } else {
            dashboard.backgroundImagePath = null;
          }
          dashboard.width = dashboardDataT.width;
          dashboard.height = dashboardDataT.height;

          final newItems = (dashboardDataT.items ?? []).map((fbItem) {
            final item = DashboardItem(
              entityId: fbItem.entityId ?? '',
              displayName: fbItem.displayName ?? '',
              dbType: fbItem.type.index,
              standardIconCodePoint: fbItem.standardIconCodePoint,
              standardColorValue: fbItem.standardColorValue,
              x: fbItem.xPos,
              y: fbItem.yPos,
              width: fbItem.width,
              height: fbItem.height,
              unitOverride: fbItem.unitOverride,
              valueFontSize: fbItem.valueFontSize,
              valuePosition: fbItem.valuePosition.value,
            );
            item.thresholds.addAll(
              (fbItem.thresholds ?? []).map(
                    (t) => ThresholdConfig(
                  triggerValue: t.triggerValue,
                  iconCodePoint: t.iconCodePoint,
                  colorValue: t.colorValue,
                ),
              ),
            );
            return item;
          }).toList();

          final isUserInitiated = _userInitiatedDashboardUpdates.remove(backendId);
          haStore.saveDashboardWithItems(dashboard, newItems);
          emit(BackAppWebSocketDashboardSynced(backendId, isUserInitiated: isUserInitiated));
          break;

        case backmsg.BackAppPayloadTypeId.dashboardStructure_AllDashboardInfo:
          final allInfos = rawMessage.payload as dash.AllDashboardInfo;
          final infos = allInfos.infos;
          if (infos == null || infos.isEmpty) break;

          emit(BackAppWebSocketGotDashboardInfo(infos));
          break;

        case backmsg.BackAppPayloadTypeId.GetToken:
          final token = rawMessage.payload as backmsg.GetToken;
          emit(BackAppWebSocketGotToken(token.unpack()));
          break;

        case backmsg.BackAppPayloadTypeId.GoogleSecret:
          final secret = rawMessage.payload as backmsg.GoogleSecret;
          final newId = secret.id ?? "";
          if (newId.isNotEmpty) {
            GetIt.I<GoogleTokenRepository>().setCredentials(
              id: newId,
              secret: secret.secret ?? "",
            );
          }
          break;

        case backmsg.BackAppPayloadTypeId.VerificationCode:
          final code = rawMessage.payload as backmsg.VerificationCode;
          emit(BackAppWebSocketVerificationCodeReceived(code.unpack()));
          break;


        case backmsg.BackAppPayloadTypeId.viewStructure_View:
          final fbView = rawMessage.payload as vs.View;

          final pages = ViewStructureMapper.pagesFromView(fbView);

          final allIds = await viewStore.syncViewFromBackend(
            user.currentUser?.username ?? "",
            pages,
            timestamp: fbView.timestamp.toInt(),
            language: fbView.language ?? '',
            theme: fbView.theme,
            deviceId: viewStore.currentDeviceId ?? 0,
          );

          // Check if binary exists locally by checking the new database.
          // If it exists, use the path locally; if not, ask the backend.
          final missingIds = <int>[];
          for (final id in allIds) {
            final localPath = await GetIt.I<BinaryDatabase>().getBinaryPath(id);
            if (localPath != null && localPath.isNotEmpty && (kIsWeb || await File(localPath).exists())) {
              await viewStore.updateBinaryPath(id, localPath);
            } else {
              missingIds.add(id);
            }
          }

          if (missingIds.isNotEmpty) {
            _sendUpdateBinary(missingIds);
          }

          emit(BackAppWebSocketGotNewView());
          break;

        case backmsg.BackAppPayloadTypeId.Status:
          final status = rawMessage.payload as backmsg.Status;
          emit(BackAppWebSocketStatusReceived(status.unpack()));
          break;

        case backmsg.BackAppPayloadTypeId.Binary:
          final binary = (rawMessage.payload as backmsg.Binary).unpack();
          final tid = binary.transferId;

          switch (binary.phase) {
            case backmsg.BinaryPhase.SINGLE:
              // Complete in one shot — write immediately and notify
              final data = Uint8List.fromList(binary.data ?? []);
              final path = await _writeBinary(binary.fileName ?? '$tid', data);
              repo.ingestPaths({tid: path});
              await viewStore.updateBinaryPath(binary.binaryIndex, path);
              await GetIt.I<BinaryDatabase>().insertBinary(binary.binaryIndex, path);
              await haStore.updateDashboardBackgroundPath(binary.binaryIndex, path);
              await _sendResultToBackend(
                tid,
                backmsg.ErrorCode.BINARY_COMPLETE,
              );
              break;

            case backmsg.BinaryPhase.BEGIN:
              // Prepare buffer, ack so backend starts sending chunks
              _incoming[tid] = _BinaryReceiveBuffer(
                fileName: binary.fileName ?? '$tid',
                totalSize: binary.totalSize,
              );
              await _sendResultToBackend(
                tid,
                backmsg.ErrorCode.BINARY_ACCEPTED,
              );
              break;

            case backmsg.BinaryPhase.CHUNK:
              final buf = _incoming[tid];
              if (buf == null) break; // unexpected chunk, ignore
              buf.append(Uint8List.fromList(binary.data ?? []));
              // Backpressure ack — mirrors what the backend does for us when we upload
              await _sendResultToBackend(
                tid,
                backmsg.ErrorCode.BINARY_CHUNK_OK,
              );
              break;

            case backmsg.BinaryPhase.END:
              final buf = _incoming.remove(tid);
              if (buf == null) break;
              final assembled = buf.assemble();
              final path = await _writeBinary(buf.fileName, assembled);
              repo.ingestPaths({tid: path});
              await viewStore.updateBinaryPath(binary.binaryIndex, path);
              await GetIt.I<BinaryDatabase>().insertBinary(binary.binaryIndex, path);
              await haStore.updateDashboardBackgroundPath(binary.binaryIndex, path);
              await _sendResultToBackend(
                tid,
                backmsg.ErrorCode.BINARY_COMPLETE,
              );
              break;
          }
          break;

        case backmsg.BackAppPayloadTypeId.WelcomeMessage:
          final welcome = rawMessage.payload as backmsg.WelcomeMessage;
          final s = welcome.unpack();
          if (s.maxMessageSize != 0) {
            repo.setMaxMessageSize(s.maxMessageSize);
          }
          if (s.features != null) {
            features.updateFeatures(s.features!);
          }
          features.updateRights(s.rights);
          features.updateDeviceName(s.deviceName);
          if (s.deviceName != null && s.deviceName!.isNotEmpty && service.activeDevice != null) {
            service.updateDeviceName(service.activeDevice!.id, s.deviceName!);
          }
          if (s.viewTimestamp != 0) {
            final needUpdate = viewStore.checkTimestamp(
              user.currentUser?.localUserId ?? 0,
              s.viewTimestamp,
            );
            int viewId = 0;
            bool isDirty = false;
            if (needUpdate) {
              final existingView = viewStore.getViewForUser(
                user.currentUser?.localUserId ?? 0,
              );
              viewId = existingView?.id ?? 0;
              isDirty = existingView?.dirty ?? false;
            }
            emit(
              BackAppWebSocketWelcomeReceived(
                s,
                needUpdate,
                viewId,
                isDirty: isDirty,
              ),
            );
          } else {
            emit(BackAppWebSocketWelcomeReceived(s, false, 0, isDirty: false));
          }
          break;

        case backmsg.BackAppPayloadTypeId.Logs:
          final logs = rawMessage.payload as backmsg.Logs;
          emit(BackAppWebSocketGotLogs(logs.logs ?? [""]));
          break;

        case backmsg.BackAppPayloadTypeId.AdminInfo:
          final adminInfo = (rawMessage.payload as backmsg.AdminInfo).unpack();
          features.updateDeviceName(adminInfo.deviceName);
          if (adminInfo.deviceName != null && adminInfo.deviceName!.isNotEmpty && service.activeDevice != null) {
            service.updateDeviceName(service.activeDevice!.id, adminInfo.deviceName!);
          }
          emit(BackAppWebSocketGotAdminInfo(info: adminInfo));
          break;

        case backmsg.BackAppPayloadTypeId.NewUpdateAvailable:
          final updateInfo =
              (rawMessage.payload as backmsg.NewUpdateAvailable).unpack();
          emit(BackAppWebSocketGotNewUpdateAvailable(updateInfo));
          break;
         
         
        case backmsg.BackAppPayloadTypeId.FrameData_Frame:
          final frame = (rawMessage.payload as frame_data.Frame).unpack();
          emit(BackAppWebSocketGotFrame(frame));
          break;

        case backmsg.BackAppPayloadTypeId.FrameData_Meta:
          final meta = (rawMessage.payload as frame_data.Meta).unpack();
          emit(BackAppWebSocketGotCameraMeta(meta));
          break;

        case backmsg.BackAppPayloadTypeId.TomlConfig:
          final tomlConfig = (rawMessage.payload as backmsg.TomlConfig).unpack();
          emit(BackAppWebSocketGotTomlConfig(tomlConfig));
          break;

        case backmsg.BackAppPayloadTypeId.ProxyHttpResponse:
          final response = (rawMessage.payload as backmsg.ProxyHttpResponse).unpack();
          GetIt.I<BackendHttpProxyService>().handleResponse(response);
          emit(BackAppWebSocketProxyResponseReceived(response));
          break;


        default:
          emit(
            BackAppWebSocketUnknownPayload(message.payloadType?.value ?? -1),
          );
          break;
      }
    }, onError: (err) => emit(BackAppWebSocketFailure(err.toString())));
  }

  void _sendUpdateBinary(List<int> ids) {
    final b = fb.Builder(initialSize: 64 + ids.length * 8);
    final msgT = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.UpdateBinary,
      payload: appmsg.UpdateBinaryT(ids: ids),
    );
    b.finish(msgT.pack(b));
    service.send(b.buffer);
  }

  Future<void> _sendResultToBackend(
    int transferId,
    backmsg.ErrorCode code,
  ) async {
    final b = fb.Builder(initialSize: 128);
    final resultT = appmsg.ResultT(
      transferId: transferId,
      errorCode: appmsg.ErrorCode.values.byName(code.name),
    );
    final msgT = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.Result,
      payload: resultT,
    );
    b.finish(msgT.pack(b));
    service.send(b.buffer);
  }

  Future<String> _writeBinary(String fileName, Uint8List data) async {
    return saveBinaryData(fileName, data);
  }

  void sendGetScreenshot() {
    final b = fb.Builder(initialSize: 64);
    final msgT = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.SimpleCommand,
      payload: appmsg.SimpleCommandT(
        type: appmsg.AppSimpleCommandType.GET_SCREENSHOT,
      ),
    );
    b.finish(msgT.pack(b));
    service.send(b.buffer);
  }

  void sendGetCameraMeta() {
    final b = fb.Builder(initialSize: 64);
    final msgT = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.SimpleCommand,
      payload: appmsg.SimpleCommandT(
        type: appmsg.AppSimpleCommandType.GET_CAMERA_META,
      ),
    );
    b.finish(msgT.pack(b));
    service.send(b.buffer);
  }
}


class _BinaryReceiveBuffer {
  final String fileName;
  final int totalSize;
  final List<Uint8List> _chunks = [];

  _BinaryReceiveBuffer({required this.fileName, required this.totalSize});

  void append(Uint8List chunk) => _chunks.add(chunk);

  Uint8List assemble() {
    final out = Uint8List(
      totalSize > 0 ? totalSize : _chunks.fold(0, (s, c) => s + c.length),
    );
    int offset = 0;
    for (final chunk in _chunks) {
      out.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return out;
  }
}
