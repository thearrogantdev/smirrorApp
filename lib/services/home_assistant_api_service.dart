import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_models.dart';
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smirror_app/services/token_provider.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_app/services/backend_http_proxy_service.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;

enum HAValidationStatus { ok, invalidToken, unreachable, unknownError }

DashboardItemType detectEntityType(HAEntityState entity) {
  final state = entity.state.toLowerCase();
  final attributes = entity.attributes;

  if (attributes.containsKey('unit_of_measurement') &&
      attributes['unit_of_measurement'] != null) {
    return DashboardItemType.Numeric;
  }

  const binaryKeywords = {
    'on',
    'off',
    'home',
    'not_home',
    'open',
    'closed',
    'locked',
    'unlocked',
    'true',
    'false',
    'connected',
    'disconnected',
  };

  if (binaryKeywords.contains(state)) {
    return DashboardItemType.Boolean;
  }

  if (double.tryParse(state) != null) {
    return DashboardItemType.Numeric;
  }

  // If it's not a number and not a known binary, it's a String/State type
  return DashboardItemType.String;
}

class HAValidationResult extends ValidationResult {
  final HAValidationStatus status;

  const HAValidationResult(this.status, {super.message})
    : super(status == HAValidationStatus.ok);
}

@lazySingleton
class HomeAssistantApiService extends TokenProvider<HAValidationResult> {
  String _url = "";
  String get url => _url;

  HomeAssistantApiService() : super('HomeAssistant');

  void setUrl(String url) {
    _url = url;
  }

  Future<http.Response> _makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    String? body,
    required Duration timeout,
  }) async {
    if (kIsWeb) {
      return GetIt.I<BackendHttpProxyService>().request(
        url: url,
        method: method,
        headers: headers,
        body: body,
        timeout: timeout,
      );
    } else {
      final uri = Uri.parse(url);
      if (method.toUpperCase() == 'GET') {
        return http.get(uri, headers: headers).timeout(timeout);
      } else if (method.toUpperCase() == 'POST') {
        return http.post(uri, headers: headers, body: body).timeout(timeout);
      } else {
        throw UnimplementedError('HTTP Method $method not supported direct');
      }
    }
  }

  /// Implementation of the TokenProvider's abstract method
  @override
  Future<HAValidationResult> validateToken(backmsg.GetTokenT token) async {
    if (token.url != null && token.url!.isNotEmpty) {
      _url = token.url!;
    }

    if (_url.isEmpty) {
      return const HAValidationResult(HAValidationStatus.unreachable);
    }
    try {
      final response = await _makeRequest(
        url: '$_url/api/config',
        method: 'GET',
        headers: {'Authorization': 'Bearer ${token.accessToken}'},
        timeout: const Duration(seconds: 5),
      );

      return response.statusCode == 200
          ? const HAValidationResult(HAValidationStatus.ok)
          : const HAValidationResult(HAValidationStatus.invalidToken);
    } catch (_) {
      return const HAValidationResult(HAValidationStatus.unreachable);
    }
  }

  /// Checks the connection to Home Assistant using a minimal API call.
  /// Can be called from anywhere in the app to verify settings.
  Future<HAValidationResult> checkConnection({
    required AppWebSocketBloc appBloc,
    required Stream<BackAppWebSocketState> backStream,
  }) async {
    try {
      await ensureTokenPresent(
        appBloc: appBloc,
        backStream: backStream,
        force: true,
      );

      final token = getToken();
      if (token == null || (token.accessToken?.isEmpty ?? true)) {
        return const HAValidationResult(
          HAValidationStatus.invalidToken,
          message: "Could not acquire a token from the backend.",
        );
      }

      final response = await _makeRequest(
        url: '${_url.endsWith('/') ? _url : '$_url/'}api/',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer $accessTokenOrNull',
          'Content-Type': 'application/json',
        },
        timeout: const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        return const HAValidationResult(HAValidationStatus.ok);
      } else if (response.statusCode == 401) {
        return const HAValidationResult(
          HAValidationStatus.invalidToken,
          message: "The token is unauthorized.",
        );
      } else {
        return HAValidationResult(
          HAValidationStatus.unreachable,
          message: "Server returned status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      return HAValidationResult(
        HAValidationStatus.unreachable,
        message: "Connection failed: ${e.toString()}",
      );
    }
  }

  /// Tests a specific URL and Token without affecting the current state.
  /// Used in the configuration form before saving.
  Future<HAValidationResult> testConnection(String url, String token) async {
    if (url.isEmpty || token.isEmpty) {
      return const HAValidationResult(
        HAValidationStatus.unreachable,
        message: "URL and Token are required.",
      );
    }

    try {
      final cleanUrl = url.endsWith('/') ? url : '$url/';
      final response = await _makeRequest(
        url: '${cleanUrl}api/',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        timeout: const Duration(seconds: 7),
      );

      if (response.statusCode == 200) {
        return const HAValidationResult(HAValidationStatus.ok);
      } else if (response.statusCode == 401) {
        return const HAValidationResult(
          HAValidationStatus.invalidToken,
          message: "The provided token is invalid.",
        );
      } else {
        return HAValidationResult(
          HAValidationStatus.unreachable,
          message: "Server returned code: ${response.statusCode}",
        );
      }
    } catch (e) {
      return HAValidationResult(
        HAValidationStatus.unreachable,
        message: "Failed to reach server: $e",
      );
    }
  }

  @override
  void sendToBackend({
    required AppWebSocketBloc appBloc,
    String? accessToken,
  }) {
    final token = accessToken ?? accessTokenOrNull;
    if (token == null || token.isEmpty) return;

    appBloc.add(AppWebSocketSendToken(
      provider: provider,
      accessToken: token,
      url: url,
      tokenType: 'Bearer',
      expiresAtMs: 0,
      adminPassword: GetIt.I<WebSocketService>().password,
    ));
  }

  @override
  void resetToken() {
    _url = "";
    super.resetToken();
  }

  /// Fetches entities from Home Assistant.
  /// Automatically handles token retrieval via WebSocket and validation.
  Future<List<HAEntityState>> getEntities() async {
    if (_url.isEmpty) throw Exception("Service not initialized with URL");

    final token = (accessTokenOrNull ?? '').trim();
    if (token.isEmpty) {
      return [];
    }

    // 2. Perform the actual data request
    final response = await _makeRequest(
      url: '$_url/api/states',
      method: 'GET',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      timeout: const Duration(seconds: 10),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HAEntityState.fromJson(json)).toList();
    } else {
      throw Exception('Home Assistant API Error: ${response.statusCode}');
    }
  }
}
