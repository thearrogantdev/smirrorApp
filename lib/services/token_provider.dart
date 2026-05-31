import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/models/device_connection.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;

enum TokenStatus { unknown, checking, present, absent }

extension TokenStatusX on TokenStatus {
  bool get isTerminal => switch (this) {
    TokenStatus.present => true,
    _ => false,
  };
}

/// Base result type for token validation (const-friendly)
abstract class ValidationResult {
  final bool ok;
  final String? message;
  const ValidationResult(this.ok, {this.message});
}

/// Generic base for all token providers.
/// NOTE: TValidation is NON-null in general, but `lastResult` is nullable.
abstract class TokenProvider<TValidation extends ValidationResult> {
  TokenProvider(this.provider) {
    _userSub = GetIt.I<UserService>().onUserChanged.listen(
      (_) => resetToken(),
    );
  }

  final String provider;
  StreamSubscription<User?>? _userSub;
  StreamSubscription<DeviceConnection?>? _deviceSub;

  final ValueNotifier<TokenStatus> status = ValueNotifier<TokenStatus>(
    TokenStatus.unknown,
  );

  /// Last validation result (nullable to allow "no result yet")
  final ValueNotifier<TValidation?> lastResult = ValueNotifier<TValidation?>(
    null,
  );

  backmsg.GetTokenT? _token;
  Completer<void>? _inflight;

  bool get hasToken => status.value == TokenStatus.present;
  String? get accessTokenOrNull => _token?.accessToken;
  backmsg.GetTokenT? getToken() {
    return _token;
  }

  /// Ensure token exists (ask backend + validate via subclass)
  Future<void> ensureTokenPresent({
    required AppWebSocketBloc appBloc,
    required Stream<BackAppWebSocketState> backStream,
    Duration requestTimeout = const Duration(seconds: 6),
    bool force = false,
  }) async {
    if (!force && status.value.isTerminal) return;
    if (_inflight != null) return _inflight!.future;

    _inflight = Completer<void>();
    Future.microtask(() => status.value = TokenStatus.checking);

    try {
      // Subscribe BEFORE sending the command to avoid race conditions
      final responseFuture = backStream
          .where((s) => s is BackAppWebSocketGotToken)
          .cast<BackAppWebSocketGotToken>()
          .firstWhere((s) => s.token.provider?.toLowerCase() == provider.toLowerCase())
          .timeout(requestTimeout);

      appBloc.add(AppWebSocketGetToken(provider: provider));

      final got = await responseFuture;

      final t = (got.token.accessToken?.toString() ?? '').trim();
      if (t.isEmpty) {
        _token = null;
        lastResult.value = null;
        status.value = TokenStatus.absent;
        return;
      }

      final valid = await validateToken(got.token); // returns TValidation
      lastResult.value = valid;

      _token = got.token;
      if (valid.ok) {
        status.value = TokenStatus.present;
      } else {
        status.value = TokenStatus.absent;
      }
    } catch (e) {
      debugPrint('TokenProvider[$provider]: Error fetching token: $e');
      _token = null;
      lastResult.value = null;
      status.value = TokenStatus.absent;
    } finally {
      _inflight?.complete();
      _inflight = null;
    }
  }

  /// Called when the active user changes.
  /// Override in subclasses to reset provider-specific state (e.g. URLs).
  /// Always call super.onUserReset() when overriding.
  @mustCallSuper
  void resetToken() => reset();

  /// Subclasses must return their concrete validation type.
  Future<TValidation> validateToken(backmsg.GetTokenT token);

  /// Sends the current or a new token to the backend for the current user.
  void sendToBackend({
    required AppWebSocketBloc appBloc,
    String? accessToken,
  });

  void setTokenFromUserInput(String token, {String? url}) {
    if (token.isNotEmpty) {
      _token = backmsg.GetTokenT(accessToken: token, url: url);
      status.value = TokenStatus.present;
    }
  }

  void dispose() {
    _userSub?.cancel();
    _deviceSub?.cancel();
  }

  void reset() {
    _token = null;
    status.value = TokenStatus.unknown;
    lastResult.value = null;
  }
}
