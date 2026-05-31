import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'token_provider.dart';

enum OpenWeatherValidationStatus {
  ok,
  invalidKey,
  invalidCity,
  rateLimited,
  networkError,
  unknownError,
}

class OpenWeatherValidationResult extends ValidationResult {
  final OpenWeatherValidationStatus status;
  final double? lat;
  final double? lon;

  const OpenWeatherValidationResult(
    this.status, {
    super.message,
    this.lat,
    this.lon,
  }) : super(status == OpenWeatherValidationStatus.ok);
}

@lazySingleton
class OpenWeatherTokenRepository
    extends TokenProvider<OpenWeatherValidationResult> {
  OpenWeatherTokenRepository() : super('openweather');

  // City trust/cache (optional quality-of-life)
  final Set<String> _trustedCities = {};
  final Map<String, bool> _cityCache = {};
  String _norm(String s) => s.trim().toLowerCase();

  void trustCity(String city) {
    final n = _norm(city);
    if (n.isEmpty) return;
    _trustedCities.add(n);
    _cityCache[n] = true;
  }

  bool get isCityTrusted => _trustedCities.isNotEmpty; // or expose a check

  @override
  Future<OpenWeatherValidationResult> validateToken(
    backmsg.GetTokenT token,
  ) async {
    const timeout = Duration(seconds: 5);
    final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': 'Berlin',
      'limit': '1',
      'appid': token.accessToken,
    });
    try {
      final r = await http.get(url).timeout(timeout);
      return switch (r.statusCode) {
        200 => const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.ok,
        ),
        401 => const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.invalidKey,
        ),
        429 => const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.rateLimited,
        ),
        _ => const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.unknownError,
        ),
      };
    } on TimeoutException {
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.networkError,
      );
    } catch (_) {
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.networkError,
      );
    }
  }

  Future<OpenWeatherValidationResult> checkCity({
    required String city,
    String? apiKey, // if null uses repo.tokenOrNull
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final n = _norm(city);
    if (n.isEmpty) {
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.invalidCity,
        message: 'City is empty.',
      );
    }

    if (_trustedCities.contains(n)) {
      return const OpenWeatherValidationResult(OpenWeatherValidationStatus.ok);
    }
    final cached = _cityCache[n];
    if (cached != null) {
      return cached
          ? const OpenWeatherValidationResult(OpenWeatherValidationStatus.ok)
          : const OpenWeatherValidationResult(
              OpenWeatherValidationStatus.invalidCity,
              message: 'City not found.',
            );
    }

    final token = (apiKey ?? accessTokenOrNull ?? '').trim();
    if (token.isEmpty) {
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.invalidKey,
        message: 'Missing API key.',
      );
    }

    final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': city,
      'limit': '1',
      'appid': token,
    });

    try {
      final r = await http.get(url).timeout(timeout);
      if (r.statusCode == 200) {
        try {
          final decoded = jsonDecode(r.body);
          if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
            final Map first = decoded.first as Map;

            // lat/lon are numbers -> cast via num?.toDouble()
            final double? lat = (first['lat'] as num?)?.toDouble();
            final double? lon = (first['lon'] as num?)?.toDouble();

            if (lat != null && lon != null) {
              _cityCache[n] = true;
              _trustedCities.add(n);

              return OpenWeatherValidationResult(
                lat: lat,
                lon: lon,
                OpenWeatherValidationStatus.ok,
              );
            }
          }
          return const OpenWeatherValidationResult(
            OpenWeatherValidationStatus.invalidCity,
            message: 'City not found.',
          );
        } catch (_) {
          return const OpenWeatherValidationResult(
            OpenWeatherValidationStatus.unknownError,
            message: 'Unexpected response format.',
          );
        }
      }
      if (r.statusCode == 401) {
        return const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.invalidKey,
          message: 'Invalid API key.',
        );
      }
      if (r.statusCode == 429) {
        return const OpenWeatherValidationResult(
          OpenWeatherValidationStatus.rateLimited,
          message: 'Rate limited.',
        );
      }
      return OpenWeatherValidationResult(
        OpenWeatherValidationStatus.unknownError,
        message: 'HTTP ${r.statusCode}',
      );
    } on TimeoutException catch (e) {
      return OpenWeatherValidationResult(
        OpenWeatherValidationStatus.networkError,
        message: e.message ?? 'Request timed out.',
      );
    } catch (e) {
      return OpenWeatherValidationResult(
        OpenWeatherValidationStatus.networkError,
        message: e.toString(),
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
      refreshToken: '',
      tokenType: '',
      expiresAtMs: 0,
      adminPassword: GetIt.I<WebSocketService>().password,
    ));
  }

  Future<OpenWeatherValidationResult> checkLocation({
    required double lat,
    required double lon,
    String? apiKey,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final token = (apiKey ?? accessTokenOrNull ?? '').trim();
    if (token.isEmpty) {
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.invalidKey,
        message: 'Missing API key.',
      );
    }

    final url = Uri.https('api.openweathermap.org', '/geo/1.0/reverse', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'limit': '1',
      'appid': token,
    });

    try {
      final r = await http.get(url).timeout(timeout);
      if (r.statusCode == 200) {
        final decoded = jsonDecode(r.body);
        if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          final first = decoded.first as Map;
          final String? cityName = first['name'] as String?;
          if (cityName != null) {
            return OpenWeatherValidationResult(
              OpenWeatherValidationStatus.ok,
              lat: lat,
              lon: lon,
              message: cityName,
            );
          }
        }
        return OpenWeatherValidationResult(
          OpenWeatherValidationStatus.ok,
          lat: lat,
          lon: lon,
          message: 'Unknown Location',
        );
      }
      return const OpenWeatherValidationResult(
        OpenWeatherValidationStatus.unknownError,
        message: 'Failed to reverse geocode.',
      );
    } catch (e) {
      return OpenWeatherValidationResult(
        OpenWeatherValidationStatus.networkError,
        message: e.toString(),
      );
    }
  }

  @override
  void resetToken() {
    _trustedCities.clear();
    _cityCache.clear();
    super.resetToken();
  }
}
