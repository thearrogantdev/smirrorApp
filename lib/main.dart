import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_bloc.dart';
import 'package:smirror_app/bloc/session_context_cubit.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_bloc.dart';
import 'package:smirror_app/services/injection.dart';
import 'package:smirror_app/core/theme/app_theme.dart';
import 'bloc/setup_cubit.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'bloc/backendConnection/app_websocket_bloc.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  configureDependencies();

  await GetIt.I.allReady();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppWebSocketBloc()),
        BlocProvider(create: (_) => BackAppWebSocketBloc()),
        BlocProvider(create: (_) => SetupCubit()),
        BlocProvider(create: (_) => ViewConfigBloc(initialViewId: 0)),
        BlocProvider(create: (_) => HABloc()),
        BlocProvider(create: (_) => SessionContextCubit()),
      ],
      child: MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, setupState) {
        return MaterialApp.router(
          routerConfig: GetIt.I<AppRouter>().config(),
          themeMode: setupState.themeMode,
          locale: setupState.locale,
          supportedLocales: const [Locale('en'), Locale('de')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          localeResolutionCallback: (locale, supportedLocales) {
            // Fallback logic
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en'); // Default to English
          },
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        );
      },
    );
  }
}
