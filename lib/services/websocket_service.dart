import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smirror_app/objectbox/device.dart';
import 'package:smirror_app/objectbox/view_store.dart';
import 'package:smirror_app/services/user_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smirror_app/models/device_connection.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WsStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  unauthorized,
}

enum LoginResult { success, unauthorized, otherError }

enum TestConnectionResult { success, unauthorized, outdated, failed }

@lazySingleton
class WebSocketService {
  WebSocketService() {
    loadSavedCredentials();
    loadVersionInfo();
  }

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final UserService _userService = GetIt.I<UserService>();
  final ViewStore _viewStore = GetIt.I<ViewStore>();

  final _incoming = StreamController<List<int>>.broadcast();
  final _status = StreamController<WsStatus>.broadcast();

  final _devicesController =
      StreamController<List<DeviceConnection>>.broadcast();
  final _activeDeviceController =
      StreamController<DeviceConnection?>.broadcast();

  List<DeviceConnection> _devicesList = [];
  DeviceConnection? _activeDevice;

  static const _keySavedDevices = 'ws_saved_devices';
  static const _keyActiveDeviceId = 'ws_active_device_id';

  Stream<List<DeviceConnection>> get devices$ => _devicesController.stream;
  Stream<DeviceConnection?> get activeDevice$ => _activeDeviceController.stream;
  List<DeviceConnection> get devices => _devicesList;
  DeviceConnection? get activeDevice => _activeDevice;

  // Optional send queue to buffer payloads while (re)connecting
  final Queue<List<int>> _outbox = Queue<List<int>>();

  bool _isDisposed = false;
  int _retryDelay = 1;

  // Credentials used for header auth
  String _username = '';
  String _password = '';
  String _version = '';
  static const _keyUsername = 'ws_username';
  static const _keyPassword = 'ws_password';

  final _storage = const FlutterSecureStorage();

  // If we received a 401 during handshake, stop retrying until creds change
  bool _authRejected = false;
  // If we received a 426 during handshake, stop retrying
  bool _upgradeRejected = false;


  final _upgradeRequired = StreamController<void>.broadcast();
  Stream<void> get upgradeRequired$ => _upgradeRequired.stream;

  // A "ready" completer that completes when connected (replaced on disconnect)
  Completer<void>? _readyCompleter;

  // ---- connection serializer (never more than one attempt at a time) ----
  Future<void>? _connectingFuture;
  int _connectionSessionId = 0;



  final _guestLoginFallbackController = StreamController<void>.broadcast();
  Stream<void> get guestLoginFallback$ => _guestLoginFallbackController.stream;

  Stream<List<int>> get stream => _incoming.stream;
  Stream<WsStatus> get status$ => _status.stream;
  WsStatus _statusValue = WsStatus.disconnected;

  WsStatus get statusValue => _statusValue;

  String get username => _username;
  String get password => _password;
  String get version => _version;

  Map<String, String> get _headers => {
    'v': _version,
    'un': _username,
    'pw': _password,
  };

  Map<String, String> _getWebHandshakeHeaders(String version) => {
    'v': version,
    'un': _username,
    'pw': _password,
    'Connection': 'Upgrade',
    'Upgrade': 'websocket',
    'Sec-WebSocket-Version': '13',
    'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==',
  };

  Future<TestConnectionResult> testConnection(String ip, int port) async {
    if (_version.isEmpty) {
      await loadVersionInfo();
    }
    final currentVersion = _version.isEmpty ? '0.1' : _version;
    if (kIsWeb) {
      try {
        final httpUri = Uri.parse('http://$ip:$port/flutter');
        final response = await http.get(
          httpUri,
          headers: _getWebHandshakeHeaders(currentVersion),
        ).timeout(const Duration(seconds: 3));
        
        if (response.statusCode == 401) {
          return TestConnectionResult.unauthorized;
        }
        if (response.statusCode == 426) {
          return TestConnectionResult.outdated;
        }
        if (response.statusCode == 101 || response.statusCode == 200) {
          return TestConnectionResult.success;
        }
        return TestConnectionResult.failed;
      } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('401') || msg.contains('unauthorized')) {
          return TestConnectionResult.unauthorized;
        }
        if (msg.contains('426') || msg.contains('upgrade')) {
          return TestConnectionResult.outdated;
        }
        return TestConnectionResult.failed;
      }
    } else {
      try {
        final socket = await WebSocket.connect(
          'ws://$ip:$port/flutter',
          headers: {'v': currentVersion, 'un': _username, 'pw': _password},
        ).timeout(const Duration(seconds: 3));
        await socket.close();
        return TestConnectionResult.success;
      } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('401') || msg.contains('unauthorized')) {
          return TestConnectionResult.unauthorized;
        }
        if (msg.contains('426') || msg.contains('upgrade')) {
          return TestConnectionResult.outdated;
        }
        return TestConnectionResult.failed;
      }
    }
  }

  Future<void> loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final currentHost = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      _activeDevice = DeviceConnection(
        id: 'web_localhost',
        name: currentHost == 'localhost' ? 'Localhost' : currentHost,
        ip: currentHost,
        port: 9002,
      );
      _devicesList = [_activeDevice!];
      _devicesController.add(_devicesList);
      _activeDeviceController.add(_activeDevice);

      final entity = _viewStore.getDeviceByConnectionId(_activeDevice!.id);
      if (entity == null) {
        final newId = _viewStore.putDevice(
          DeviceEntity(
            connectionId: _activeDevice!.id,
            name: _activeDevice!.name,
            ip: _activeDevice!.ip,
            port: _activeDevice!.port,
          ),
        );
        _viewStore.setCurrentDevice(newId);
      } else {
        _viewStore.setCurrentDevice(entity.id);
      }
    } else {
      // 1. Try loading from ObjectBox
      final entities = _viewStore.getAllDevices();

      if (entities.isEmpty) {
        // 2. Migration: Load from SharedPreferences if legacy data exists
        final devicesJson = prefs.getStringList(_keySavedDevices) ?? [];
        if (devicesJson.isNotEmpty) {
          for (final s in devicesJson) {
            final d = DeviceConnection.fromJson(jsonDecode(s));
            _viewStore.putDevice(
              DeviceEntity(
                connectionId: d.id,
                name: d.name,
                ip: d.ip,
                port: d.port,
              ),
            );
          }
          // Clear legacy data
          await prefs.remove(_keySavedDevices);
          _devicesList = devicesJson
              .map((s) => DeviceConnection.fromJson(jsonDecode(s)))
              .toList();
        }
      } else {
        _devicesList = entities
            .map(
              (e) => DeviceConnection(
                id: e.connectionId,
                name: e.name,
                ip: e.ip,
                port: e.port,
              ),
            )
            .toList();
      }
      _devicesController.add(_devicesList);

      // 3. Load active device
      final activeId = prefs.getString(_keyActiveDeviceId);
      if (activeId != null) {
        _activeDevice = _devicesList.where((d) => d.id == activeId).firstOrNull;
      }

      // If no active device but we have devices, auto-select first
      if (_activeDevice == null && _devicesList.isNotEmpty) {
        _activeDevice = _devicesList.first;
        prefs.setString(_keyActiveDeviceId, _activeDevice!.id);
      }

      if (_activeDevice != null) {
        final entity = _viewStore.getDeviceByConnectionId(_activeDevice!.id);
        if (entity != null) {
          _viewStore.setCurrentDevice(entity.id);
        }
      }
      _activeDeviceController.add(_activeDevice);
    }

    final String username;
    final String password;
    if (kIsWeb) {
      username = prefs.getString(_keyUsername) ?? '';
      password = prefs.getString(_keyPassword) ?? '';
    } else {
      username = await _storage.read(key: _keyUsername) ?? '';
      password = await _storage.read(key: _keyPassword) ?? '';
    }
    await applyCredentialsAndConnect(
      username: username,
      password: password,
      isAutomatic: true,
    );
  }

  /// Resolves the local user ID based on the current username and active device,
  /// then notifies the app of the user change to trigger UI/Store refreshes.
  Future<void> _refreshUserContext() async {
    if (_activeDevice == null) return;

    final deviceEntity = _viewStore.getDeviceByConnectionId(_activeDevice!.id);
    if (deviceEntity != null) {
      final localUserId = _viewStore.getOrCreateUserByName(
        _username,
        deviceEntity.id,
      );
      _userService.changeUser(
        User(localUserId: localUserId, username: _username),
      );
      await saveCredentials(); // Ensure persistent for next launch
    }
  }

  Future<void> addDevice(DeviceConnection device) async {
    if (kIsWeb) return;
    _viewStore.putDevice(
      DeviceEntity(
        connectionId: device.id,
        name: device.name,
        ip: device.ip,
        port: device.port,
      ),
    );

    _devicesList = [..._devicesList, device];
    _devicesController.add(_devicesList);

    if (_activeDevice == null) {
      await setActiveDevice(device);
    }
  }

  Future<void> removeDevice(String id) async {
    if (kIsWeb) return;
    final entity = _viewStore.getDeviceByConnectionId(id);
    if (entity != null) {
      _viewStore.removeDevice(entity.id);
    }

    _devicesList = _devicesList.where((d) => d.id != id).toList();
    _devicesController.add(_devicesList);

    if (_activeDevice?.id == id) {
      await setActiveDevice(
        _devicesList.isNotEmpty ? _devicesList.first : null,
      );
    }
  }

  Future<void> updateDeviceName(String id, String name) async {
    if (kIsWeb) return;
    final index = _devicesList.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final oldDevice = _devicesList[index];
    if (oldDevice.name == name) return;

    final updatedDevice = DeviceConnection(
      id: oldDevice.id,
      name: name,
      ip: oldDevice.ip,
      port: oldDevice.port,
    );

    final newList = List<DeviceConnection>.from(_devicesList);
    newList[index] = updatedDevice;
    _devicesList = newList;
    _devicesController.add(_devicesList);

    if (_activeDevice?.id == id) {
      _activeDevice = updatedDevice;
      _activeDeviceController.add(_activeDevice);
    }

    final entity = _viewStore.getDeviceByConnectionId(id);
    if (entity != null) {
      entity.name = name;
      _viewStore.putDevice(entity);
    }
  }

  Future<void> setActiveDevice(DeviceConnection? device) async {
    if (kIsWeb) return;
    final changed = _activeDevice?.id != device?.id;
    _activeDevice = device;
    _activeDeviceController.add(_activeDevice);

    if (device != null) {
      final entity = _viewStore.getDeviceByConnectionId(device.id);
      if (entity != null) {
        _viewStore.setCurrentDevice(entity.id);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (device != null) {
      await prefs.setString(_keyActiveDeviceId, device.id);
    } else {
      await prefs.remove(_keyActiveDeviceId);
    }
    if (changed) {
      await reconnect();
    }
  }

  Future<void> saveCredentials({String? username, String? password}) async {
    if (username != null) _username = username;
    if (password != null) _password = password;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, _username);
      await prefs.setString(_keyPassword, _password);
    } else {
      await _storage.write(key: _keyUsername, value: _username);
      await _storage.write(key: _keyPassword, value: _password);
    }
  }

  Future<void> clearCredentials() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyPassword);
    } else {
      await _storage.deleteAll();
    }
  }

  Future<void> logout() async {
    _connectionSessionId++;
    _connectingFuture = null;
    await clearCredentials();
    _username = '';
    _password = '';
    _authRejected = false;
    _upgradeRejected = false;

    if (_channel != null) {
      final oldChannel = _channel!;
      _channel = null;
      try {
        unawaited(oldChannel.sink.close());
      } catch (_) {}
    }

    _setStatus(WsStatus.disconnected);

    _userService.changeUser(null);
  }


  // Public: single entrypoint for (re)connecting; serialized by _connectingFuture.
  Future<void> _connect() {
    // Reuse in-flight attempt if present.
    if (_connectingFuture != null) return _connectingFuture!;

    // Create a new attempt.
    _connectingFuture = _connectLoop().whenComplete(() {
      // Allow future attempts once this one completes (success or give-up).
      _connectingFuture = null;
    });

    return _connectingFuture!;
  }

  bool _isUnauthorizedError(Object e) {
    final msg = e.toString().toLowerCase();
    // dart:io doesn't expose the HTTP status directly on failure, so we parse
    return msg.contains('401') || msg.contains('unauthorized');
  }

  Future<bool> _checkDeviceReachable(String ip, int port) async {
    try {
      final httpUri = Uri.parse('http://$ip:$port/flutter');
      await http.get(httpUri).timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('refused') || msg.contains('timeout') || msg.contains('unreachable')) {
        return false;
      }
      return true;
    }
  }

  Future<void> _connectLoop() async {
    final sessionId = _connectionSessionId;
    if (_isDisposed || _authRejected || _upgradeRejected) return;
    if (sessionId != _connectionSessionId) return;

    if (_version.isEmpty) {
      await loadVersionInfo();
    }
    if (sessionId != _connectionSessionId) return;

    _setStatus(
      _statusValue == WsStatus.disconnected
          ? WsStatus.connecting
          : WsStatus.reconnecting,
    );


    try {
      if (_activeDevice == null) {
        await Future.delayed(const Duration(seconds: 2));
        if (sessionId != _connectionSessionId) return;
        _setStatus(WsStatus.disconnected);
        return; // Cannot connect without device
      }

      // If credentials are not configured, perform reachability check and short-circuit
      if (_username.isEmpty || _password.isEmpty) {
        final reachable = await _checkDeviceReachable(_activeDevice!.ip, _activeDevice!.port);
        if (sessionId != _connectionSessionId) return;
        if (reachable) {
          _setStatus(WsStatus.unauthorized);
        } else {
          _setStatus(WsStatus.disconnected);
        }
        return;
      }

      if (kIsWeb) {
        final wsUri = Uri.parse('ws://${_activeDevice!.ip}:${_activeDevice!.port}/flutter').replace(
          queryParameters: {
            'v': _version,
            'un': _username,
            'pw': _password,
          },
        );
        print('WS: Connecting to WebSocket at $wsUri');
        _channel = WebSocketChannel.connect(wsUri);
        try {
          await _channel!.ready.timeout(const Duration(seconds: 5));
          print('WS: WebSocket connection established successfully.');
        } catch (webSocketError) {
          if (sessionId != _connectionSessionId) return;
          print('WS: WebSocket handshake failed. Error: $webSocketError. Initiating HTTP diagnostics...');

          // Pre-flight check via HTTP to detect 401 or 426
          try {
            final httpUri = Uri.parse('http://${_activeDevice!.ip}:${_activeDevice!.port}/flutter').replace(
              queryParameters: {
                'v': _version,
                'un': _username,
                'pw': _password,
              },
            );
            print('WS diagnostic: HTTP GET check starting...');
            final response = await http.get(
              httpUri,
              headers: _getWebHandshakeHeaders(_version.isEmpty ? '0.1' : _version),
            ).timeout(const Duration(seconds: 3));
            print('WS diagnostic: HTTP GET check response: ${response.statusCode}');
            
            if (sessionId != _connectionSessionId) return;

            if (response.statusCode == 401) {
              _authRejected = true;
              _setStatus(WsStatus.unauthorized);
              return;
            } else if (response.statusCode == 426) {
              _upgradeRejected = true;
              _upgradeRequired.add(null);
              _setStatus(WsStatus.disconnected);
              return;
            }
          } catch (e) {
            if (sessionId != _connectionSessionId) return;
            final msg = e.toString().toLowerCase();
            if (msg.contains('401') || msg.contains('unauthorized')) {
              _authRejected = true;
              _setStatus(WsStatus.unauthorized);
              return;
            }
            if (msg.contains('426') || msg.contains('upgrade')) {
              _upgradeRejected = true;
              _upgradeRequired.add(null);
              _setStatus(WsStatus.disconnected);
              return;
            }
          }

          final reachable = await _checkDeviceReachable(_activeDevice!.ip, _activeDevice!.port);
          if (sessionId != _connectionSessionId) return;
          if (reachable) {
            _authRejected = true;
            _setStatus(WsStatus.unauthorized);
          } else {
            _setStatus(WsStatus.disconnected);
          }
          rethrow;
        }
      } else {
        final socket = await WebSocket.connect(
          'ws://${_activeDevice!.ip}:${_activeDevice!.port}/flutter',
          headers: _headers,
        ).timeout(const Duration(seconds: 5));
        if (sessionId != _connectionSessionId) return;
        _channel = IOWebSocketChannel(socket);
      }
      if (sessionId != _connectionSessionId) return;
      _retryDelay = 1;

      _listen();
      await _refreshUserContext();
      if (sessionId != _connectionSessionId) return;
      _setStatus(WsStatus.connected);

      // Complete the ready gate (only if not already completed)
      if (!(_readyCompleter?.isCompleted ?? true)) {
        _readyCompleter?.complete();
      }

      _flushOutbox();
      return; // success
    } catch (e) {
      if (sessionId != _connectionSessionId) return;
      if (_authRejected || _isUnauthorizedError(e)) {
        // Stop all retries until credentials change
        _authRejected = true;
        _setStatus(WsStatus.unauthorized);
        return;
      }
      final msg = e.toString().toLowerCase();
      if (msg.contains('426') || msg.contains('upgrade')) {
        _upgradeRejected = true;
        _upgradeRequired.add(null);
        _setStatus(WsStatus.disconnected);
        return;
      }
      print('WS initial connect failed: $e');

      // The initial attempt failed. Set status to disconnected
      // so the UI knows immediately and can show the landing page.
      _setStatus(WsStatus.disconnected);

      // Trigger background retry loop asynchronously
      _startBackgroundRetryLoop();
    }
  }

  void _startBackgroundRetryLoop() {
    unawaited(_runBackgroundRetryLoop());
  }

  Future<void> _runBackgroundRetryLoop() async {
    final sessionId = _connectionSessionId;
    if (_isDisposed || _authRejected || _upgradeRejected || _channel != null) return;
    if (sessionId != _connectionSessionId) return;

    _setStatus(WsStatus.reconnecting);

    while (!_isDisposed &&
        !_authRejected &&
        !_upgradeRejected &&
        _channel == null &&
        sessionId == _connectionSessionId) {
      try {
        if (_activeDevice == null) {
          await Future.delayed(const Duration(seconds: 2));
          if (sessionId != _connectionSessionId) return;
          continue; // Cannot connect without device
        }

        // If credentials are not configured, perform reachability check and short-circuit
        if (_username.isEmpty || _password.isEmpty) {
          final reachable = await _checkDeviceReachable(_activeDevice!.ip, _activeDevice!.port);
          if (sessionId != _connectionSessionId) return;
          if (reachable) {
            _setStatus(WsStatus.unauthorized);
          } else {
            _setStatus(WsStatus.disconnected);
          }
          return;
        }

        if (_version.isEmpty) {
          await loadVersionInfo();
        }
        if (sessionId != _connectionSessionId) return;


        if (kIsWeb) {
          final wsUri = Uri.parse('ws://${_activeDevice!.ip}:${_activeDevice!.port}/flutter').replace(
            queryParameters: {
              'v': _version,
              'un': _username,
              'pw': _password,
            },
          );
          print('WS background retry: Connecting to WebSocket at $wsUri');
          _channel = WebSocketChannel.connect(wsUri);
          try {
            await _channel!.ready.timeout(const Duration(seconds: 5));
            print('WS background retry: WebSocket connection established successfully.');
          } catch (webSocketError) {
            if (sessionId != _connectionSessionId) return;
            print('WS background retry: WebSocket handshake failed. Error: $webSocketError. Initiating HTTP diagnostics...');

            // Pre-flight check via HTTP to detect 401 or 426
            try {
              final httpUri = Uri.parse('http://${_activeDevice!.ip}:${_activeDevice!.port}/flutter').replace(
                queryParameters: {
                  'v': _version,
                  'un': _username,
                  'pw': _password,
                },
              );
              print('WS background retry diagnostic: HTTP GET check starting...');
              final response = await http.get(
                httpUri,
                headers: _getWebHandshakeHeaders(_version.isEmpty ? '0.1' : _version),
              ).timeout(const Duration(seconds: 3));
              print('WS background retry diagnostic: HTTP GET check response: ${response.statusCode}');
              
              if (sessionId != _connectionSessionId) return;

              if (response.statusCode == 401) {
                _authRejected = true;
                _setStatus(WsStatus.unauthorized);
                return;
              } else if (response.statusCode == 426) {
                _upgradeRejected = true;
                _upgradeRequired.add(null);
                _setStatus(WsStatus.disconnected);
                return;
              }
            } catch (e) {
              if (sessionId != _connectionSessionId) return;
              final msg = e.toString().toLowerCase();
              if (msg.contains('401') || msg.contains('unauthorized')) {
                _authRejected = true;
                _setStatus(WsStatus.unauthorized);
                return;
              }
              if (msg.contains('426') || msg.contains('upgrade')) {
                _upgradeRejected = true;
                _upgradeRequired.add(null);
                _setStatus(WsStatus.disconnected);
                return;
              }
            }

            final reachable = await _checkDeviceReachable(_activeDevice!.ip, _activeDevice!.port);
            if (sessionId != _connectionSessionId) return;
            if (reachable) {
              _authRejected = true;
              _setStatus(WsStatus.unauthorized);
            } else {
              _setStatus(WsStatus.disconnected);
            }
            rethrow;
          }
        } else {
          final socket = await WebSocket.connect(
            'ws://${_activeDevice!.ip}:${_activeDevice!.port}/flutter',
            headers: _headers,
          ).timeout(const Duration(seconds: 5));
          if (sessionId != _connectionSessionId) return;
          _channel = IOWebSocketChannel(socket);
        }
        if (sessionId != _connectionSessionId) return;
        _retryDelay = 1;

        _listen();
        await _refreshUserContext();
        if (sessionId != _connectionSessionId) return;
        _setStatus(WsStatus.connected);

        // Complete the ready gate (only if not already completed)
        if (!(_readyCompleter?.isCompleted ?? true)) {
          _readyCompleter?.complete();
        }

        _flushOutbox();
        return; // success
      } catch (e) {
        if (sessionId != _connectionSessionId) return;
        if (_authRejected || _isUnauthorizedError(e)) {
          // Stop all retries until credentials change
          _authRejected = true;
          _setStatus(WsStatus.unauthorized);
          return;
        }
        final msg = e.toString().toLowerCase();
        if (msg.contains('426') || msg.contains('upgrade')) {
          _upgradeRejected = true;
          _upgradeRequired.add(null);
          _setStatus(WsStatus.disconnected);
          return;
        }
        print('WS background retry failed: $e');

        final waitEnd = DateTime.now().add(Duration(seconds: _retryDelay));
        final currentDeviceId = _activeDevice?.id;
        while (DateTime.now().isBefore(waitEnd)) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (sessionId != _connectionSessionId) return;
          if (_activeDevice?.id != currentDeviceId ||
              _isDisposed ||
              _channel != null) {
            break; // Break the delay early if device changed
          }
        }

        _retryDelay = (_retryDelay * 2).clamp(1, 5);
      }
    }
  }

  /// Try new credentials and attempt a connection via the serialized connect lane.
  /// Returns a [LoginResult]. On success, keeps the connection open.
  Future<LoginResult> applyCredentialsAndConnect({
    required String username,
    required String password,
    bool isAutomatic = false,
  }) async {
    _connectionSessionId++;
    _connectingFuture = null; // Clear the old serializer to force a new loop
    final changed = username != _username || password != _password;
    _username = username;
    _password = password;


    // Clear the 401 lock so we attempt again with new creds
    _authRejected = false;
    _upgradeRejected = false;

    // Force close any existing socket so headers are used next time (fire-and-forget)
    if (_channel != null) {
      final oldChannel = _channel!;
      _channel = null;
      try {
        unawaited(oldChannel.sink.close());
      } catch (_) {}
    }

    // Prepare a fresh ready gate for this attempt
    _readyCompleter ??= Completer<void>();
    if (_readyCompleter!.isCompleted) {
      _readyCompleter = Completer<void>();
    }

    await _connect();

    // Infer outcome from current state after _connect() returns (it awaits _connectLoop)
    if (_channel != null && _statusValue == WsStatus.connected) {
      return LoginResult.success;
    }
    if (_authRejected) {
      return LoginResult.unauthorized;
    }

    // If we got here, either we’re disposed, or retries gave up for now.
    // Optionally schedule background retries only if creds weren't changed?
    if (!changed && !_isDisposed && !_authRejected) {
      // Safe: this funnels through the serializer.
      unawaited(_connect());
    }
    return LoginResult.otherError;
  }

  /// Will not retry if 401 was seen previously; uses the serialized lane.
  Future<void> reconnect() async {
    _authRejected = false; // allow retry with existing creds
    _upgradeRejected = false;

    // Close the old connection aggressively (fire-and-forget)
    if (_channel != null) {
      final oldChannel = _channel!;
      _channel = null;
      try {
        unawaited(oldChannel.sink.close());
      } catch (_) {}
    }

    // Prepare a new ready gate if needed
    _readyCompleter ??= Completer<void>();
    if (_readyCompleter!.isCompleted) {
      _readyCompleter = Completer<void>();
    }

    await applyCredentialsAndConnect(
      username: _username,
      password: _password,
      isAutomatic: true,
    );
  }

  void _listen() {
    print('WS listening to channel stream...');
    _subscription = _channel!.stream.listen(
      (data) {
        print('WS raw data received. Type: ${data.runtimeType}, Size/Length: ${data is List<int> ? data.length : (data is ByteBuffer ? data.lengthInBytes : "unknown")}');
        if (data is List<int>) {
          _incoming.add(data);
        } else if (data is ByteBuffer) {
          _incoming.add(data.asUint8List());
        } else if (data is TypedData) {
          final buffer = data.buffer;
          _incoming.add(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        } else if (data is String) {
          print('WS string data (unexpected text frame): $data');
          _incoming.add(utf8.encode(data));
        }
      },
      onError: (err) {
        print('WebSocket error: $err');
        _handleDisconnect();
      },
      onDone: () {
        print('WebSocket channel onDone triggered.');
        _handleDisconnect();
      },
      cancelOnError: true,
    );
  }

  void _handleDisconnect() {
    print('WS handling disconnect. Flags - isDisposed: $_isDisposed, authRejected: $_authRejected, upgradeRejected: $_upgradeRejected');
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    // New gate for next connect
    _readyCompleter = Completer<void>();

    if (_isDisposed) {
      _setStatus(WsStatus.disconnected);
      return;
    }



    if (_authRejected) {
      // Stay disconnected until creds change
      _setStatus(WsStatus.unauthorized);
      return;
    }

    if (_upgradeRejected) {
      // Stay disconnected when upgrade is required
      _setStatus(WsStatus.disconnected);
      return;
    }

    _setStatus(WsStatus.reconnecting);
    // Reconnect through the serialized lane
    unawaited(_connect());
  }

  void _setStatus(WsStatus s) {
    if (_statusValue == s) return;
    _statusValue = s;
    _status.add(s);
  }

  void send(List<int> data) {
    final ch = _channel;
    if (ch != null && _statusValue == WsStatus.connected) {
      ch.sink.add(data);
    } else {
      _outbox.addLast(List<int>.from(data)); // copy defensively
    }
  }

  void _flushOutbox() {
    if (_channel == null || _statusValue != WsStatus.connected) return;
    while (_outbox.isNotEmpty) {
      _channel!.sink.add(_outbox.removeFirst());
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    await _incoming.close();
    await _status.close();
    await _upgradeRequired.close();
    await _guestLoginFallbackController.close();
  }
}
