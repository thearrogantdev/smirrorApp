import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
@singleton
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      page: MainScaffold.page,
      path: '/',
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
        AutoRoute(page: ViewConfigRoute.page, path: 'viewConfig'),
        AutoRoute(page: AdminRoute.page, path: 'admin'),
        AutoRoute(page: LogRoute.page, path: 'logs'),
        AutoRoute(page: SetupRoute.page, path: 'setup'),
        AutoRoute(page: BiometricsRoute.page, path: 'biometrics'),
        AutoRoute(page: HomeAssistantMapRoute.page, path: 'homeAssistantMap'),
        AutoRoute(page: FrameRoute.page, path: 'screenshot'),
      ],


    ),
  ];
}
