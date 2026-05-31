import 'package:flutter/material.dart';
import '../router/app_router.dart';

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      title: 'App → Backend WebSocket Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
