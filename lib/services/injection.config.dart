// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:smirror_app/objectbox/database.dart' as _i186;
import 'package:smirror_app/objectbox/home_assistant_store.dart' as _i26;
import 'package:smirror_app/objectbox/view_store.dart' as _i369;
import 'package:smirror_app/router/app_router.dart' as _i339;
import 'package:smirror_app/services/binary_transfer_repository.dart' as _i321;
import 'package:smirror_app/services/google_token_service.dart' as _i753;
import 'package:smirror_app/services/home_assistant_api_service.dart' as _i1058;
import 'package:smirror_app/services/location_service.dart' as _i571;
import 'package:smirror_app/services/open_weather_validation_service.dart'
    as _i1048;
import 'package:smirror_app/services/path_service.dart' as _i472;
import 'package:smirror_app/services/session_context_service.dart' as _i252;
import 'package:smirror_app/services/user_service.dart' as _i875;
import 'package:smirror_app/services/websocket_service.dart' as _i904;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i186.AppDatabase>(() => _i186.AppDatabase());
    gh.singletonAsync<_i26.HomeAssistantStore>(() {
      final i = _i26.HomeAssistantStore();
      return i.init().then((_) => i);
    });
    gh.singletonAsync<_i369.ViewStore>(() {
      final i = _i369.ViewStore();
      return i.init().then((_) => i);
    });
    gh.singleton<_i339.AppRouter>(() => _i339.AppRouter());
    gh.singletonAsync<_i571.LocationService>(() {
      final i = _i571.LocationService();
      return i.init().then((_) => i);
    });
    gh.singleton<_i875.UserService>(() => _i875.UserService());
    gh.lazySingleton<_i321.BinaryTransferRepository>(
      () => _i321.BinaryTransferRepository(),
    );
    gh.lazySingleton<_i753.GoogleTokenRepository>(
      () => _i753.GoogleTokenRepository(),
    );
    gh.lazySingleton<_i1058.HomeAssistantApiService>(
      () => _i1058.HomeAssistantApiService(),
    );
    gh.lazySingleton<_i1048.OpenWeatherTokenRepository>(
      () => _i1048.OpenWeatherTokenRepository(),
    );
    gh.lazySingleton<_i472.PathService>(() => _i472.PathService());
    gh.lazySingleton<_i252.SessionContextService>(
      () => _i252.SessionContextService(),
    );
    gh.lazySingleton<_i904.WebSocketService>(() => _i904.WebSocketService());
    return this;
  }
}
