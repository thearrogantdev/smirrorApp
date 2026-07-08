import 'dart:async';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'token_provider.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'dart:convert';
// --- mobile/web/macos sign-in (unused on Windows) ---
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class GoogleCalendarEntry {
  final String id;
  final String summary;
  final bool primary;

  GoogleCalendarEntry({
    required this.id,
    required this.summary,
    this.primary = false,
  });

  factory GoogleCalendarEntry.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarEntry(
      id: json['id'] as String,
      summary: json['summary'] as String,
      primary: json['primary'] as bool? ?? false,
    );
  }
}

class GoogleTaskListEntry {
  final String id;
  final String title;

  GoogleTaskListEntry({
    required this.id,
    required this.title,
  });

  factory GoogleTaskListEntry.fromJson(Map<String, dynamic> json) {
    return GoogleTaskListEntry(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

class GoogleValidationResult extends ValidationResult {
  const GoogleValidationResult(super.ok, {super.message});
}

@lazySingleton
class GoogleTokenRepository extends TokenProvider<GoogleValidationResult> {
  GoogleTokenRepository() : super('google') {
    // Set up the event listener immediately
    if (_isGsiSupported) {
      _authSub = _gsi.authenticationEvents.listen(
        (e) {
          switch (e) {
            case gsi.GoogleSignInAuthenticationEventSignIn():
              _currentUser = e.user;
              currentUserNotifier.value = e.user;
            case gsi.GoogleSignInAuthenticationEventSignOut():
              _currentUser = null;
              currentUserNotifier.value = null;
          }
        },
        onError: (_) {
          _currentUser = null;
          currentUserNotifier.value = null;
        },
      );
    }
  }

  final ValueNotifier<gsi.GoogleSignInAccount?> currentUserNotifier =
      ValueNotifier<gsi.GoogleSignInAccount?>(null);

  gsi.GoogleSignInAccount? get currentUser => _currentUser;

  // ---------- App Credentials ----------
  String? _clientId;
  String? _clientSecret;

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  DateTime? _cachedExpiry;

  // ---------- Platform gate ----------
  bool get _isGsiSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.macOS);

  bool get _isDesktopOAuth =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  String? get clientId => _clientId;
  String? get clientSecret => _clientSecret;

  // ---------- v6 google_sign_in wiring (mobile/web/macos) ----------
  final gsi.GoogleSignIn _gsi = gsi.GoogleSignIn.instance;
  StreamSubscription<gsi.GoogleSignInAuthenticationEvent>? _authSub;
  gsi.GoogleSignInAccount? _currentUser;

  // Set credentials from the outside (e.g., in BLoC when receiving them from the backend)
  void setCredentials({required String id, String? secret}) {
    _clientId = id;
    _clientSecret = secret;

    if (_isGsiSupported) {
      // Initialize GSI and attempt to restore previous session now that we have the clientId
      unawaited(_gsi.initialize(clientId: _clientId));
      unawaited(Future(() async {
        final user = await _gsi.attemptLightweightAuthentication();
        if (user != null) {
          _currentUser = user;
          currentUserNotifier.value = user;
        }
      }));
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
  }

  // ---------- TokenProvider contract ----------
  @override
  Future<GoogleValidationResult> validateToken(backmsg.GetTokenT token) async {
    // The backend already validated and stored the token when the admin
    // configured it. A non-empty access token is sufficient proof that
    // the credential is present and usable.
    final accessToken = token.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      return const GoogleValidationResult(false, message: 'googleErrorInvalid');
    }
    _cachedAccessToken = accessToken;
    return const GoogleValidationResult(true);
  }

  // ---------- Common helpers ----------
  String? extractAccessToken(Map<String, String> headers) {
    final v = headers['Authorization'] ?? headers['authorization'];
    const prefix = 'Bearer ';
    if (v == null) return null;
    return v.startsWith(prefix) ? v.substring(prefix.length) : null;
  }

  @override
  void sendToBackend({
    required AppWebSocketBloc appBloc,
    String? accessToken,
  }) {
    final token = accessToken ?? _cachedAccessToken ?? accessTokenOrNull;
    if (token == null) return;

    final expiresAtMs = _cachedExpiry?.millisecondsSinceEpoch ?? 0;

    appBloc.add(
      AppWebSocketSendToken(
        provider: provider,
        accessToken: token,
        refreshToken: _cachedRefreshToken ?? "",
        tokenType: "Bearer",
        expiresAtMs: expiresAtMs,
        adminPassword: GetIt.I<WebSocketService>().password,
      ),
    );

    if (_cachedAccessToken != null) {
      setTokenFromUserInput(_cachedAccessToken!);
    }
  }

  // ---------- Authorization headers (platform-aware) ----------
  Future<Map<String, String>?> ensureAuthorizationHeaders({
    bool fromUserGesture = false,
    required List<String> scopes,
  }) async {
    if (_cachedAccessToken != null) {
      return {'Authorization': 'Bearer $_cachedAccessToken'};
    }

    if (_isGsiSupported) {
      return _ensureHeadersWithGSI(scopes, fromUserGesture: fromUserGesture);
    }
    if (_isDesktopOAuth) {
      return _ensureHeadersWithDesktopOAuth(scopes);
    }
    // Unsupported platform TODO what we want to do here?
    return null;
  }

  // ---- google_sign_in (Android/iOS/Web/macOS) ----
  Future<Map<String, String>?> _ensureHeadersWithGSI(
    List<String> scopes, {
    required bool fromUserGesture,
  }) async {
    var user = _currentUser;
    if (user == null) {
      if (!_gsi.supportsAuthenticate()) {
        if (!fromUserGesture) return null;
      }
      try {
        await _gsi.authenticate();
      } catch (_) {
        return null;
      }
      user = _currentUser;
      if (user == null) return null;
    }

    final existing = await user.authorizationClient.authorizationForScopes(
      scopes,
    );
    if (existing != null) {
      //final auth = user.authentication;
      // _cachedAccessToken = ;
      // Note: google_sign_in doesn't expose refresh tokens directly
      // but it handles refresh internally when calling authorizationHeaders

      return user.authorizationClient.authorizationHeaders(scopes);
    }

    if (!fromUserGesture) return null;
    try {
      await user.authorizationClient.authorizeScopes(scopes);
      //final auth = user.authentication;

      return user.authorizationClient.authorizationHeaders(scopes);
    } catch (_) {
      return null;
    }
  }

  // ---- googleapis_auth (Windows/Linux desktop) ----
  Future<Map<String, String>?> _ensureHeadersWithDesktopOAuth(
    List<String> scopes,
  ) async {
    if (_clientId == null || _clientId!.isEmpty) {
      return null;
    }

    final cid = gauth.ClientId(_clientId!, _clientSecret);
    final httpClient = http.Client();
    try {
      final creds = await gauth.obtainAccessCredentialsViaUserConsent(
        cid,
        scopes,
        httpClient,
        (authUrl) async {
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
          }
        },
        listenPort: 7357,
      );

      _cachedAccessToken = creds.accessToken.data;
      _cachedRefreshToken = creds.refreshToken;
      _cachedExpiry = creds.accessToken.expiry;

      return _cachedAccessToken == null || _cachedAccessToken!.isEmpty
          ? null
          : {'Authorization': 'Bearer $_cachedAccessToken'};
    } catch (e, st) {
      debugPrint('OAuth failed: $e\n$st');
      return null;
    } finally {
      httpClient.close();
    }
  }

  @override
  void resetToken() {
    _authSub?.cancel();
    _authSub = null;
    _currentUser = null;
    currentUserNotifier.value = null;
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedExpiry = null;
    // Note: We don't reset _clientId / _clientSecret here so they persist
    // across user sign-outs until manually re-initialized by the BLoC.
    super.resetToken();
  }

  @override
  void reset() {
    _currentUser = null;
    currentUserNotifier.value = null;
    super.reset();
  }

  Future<List<GoogleCalendarEntry>> fetchCalendars() async {
    final headers = await ensureAuthorizationHeaders(
      scopes: const [
        'https://www.googleapis.com/auth/calendar.readonly',
        'https://www.googleapis.com/auth/tasks',
      ],
    );
    if (headers == null) return [];

    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('https://www.googleapis.com/calendar/v3/users/me/calendarList'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map(
              (item) =>
                  GoogleCalendarEntry.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        debugPrint(
          'Failed to fetch calendars: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching calendars: $e');
      return [];
    } finally {
      client.close();
    }
  }

  Future<List<GoogleTaskListEntry>> fetchTaskLists() async {
    final headers = await ensureAuthorizationHeaders(
      scopes: const [
        'https://www.googleapis.com/auth/calendar.readonly',
        'https://www.googleapis.com/auth/tasks',
      ],
    );
    if (headers == null) return [];

    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('https://tasks.googleapis.com/tasks/v1/users/@me/lists'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map(
              (item) =>
                  GoogleTaskListEntry.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        debugPrint(
          'Failed to fetch task lists: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching task lists: $e');
      return [];
    } finally {
      client.close();
    }
  }
}
