import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/dialogs/initial_setup_dialog.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:smirror_wire/generated/app_back_app_back_generated.dart' as appmsg;
import 'backend_result_handler.dart';

class BackendResponseListener extends StatefulWidget {
  final Widget child;

  const BackendResponseListener({super.key, required this.child});

  @override
  State<BackendResponseListener> createState() => _BackendResponseListenerState();
}

class _BackendResponseListenerState extends State<BackendResponseListener> {
  StreamSubscription<User?>? _userSub;
  bool _setupDialogShown = false;
  String? _shownUpdateMessage;
  bool _viewUpdatedWithoutAsking = false;

  @override
  void initState() {
    super.initState();
    final userService = GetIt.I<UserService>();
    _userSub = userService.onUserChanged.listen((user) {
      if (user?.username != 'admin') {
        _setupDialogShown = false;
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  String? _buildUpdateAvailableMessage(
    AppLocalizations loc,
    backmsg.WelcomeMessageT welcomeMessage,
  ) {
    final updateAvailable = welcomeMessage.updateAvailable;
    if (updateAvailable == null) {
      return null;
    }

    final frontendVersion = updateAvailable.versionFrontend?.trim() ?? '';
    final backendVersion = updateAvailable.versionBackend?.trim() ?? '';
    final webappVersion = updateAvailable.versionWebapp?.trim() ?? '';
    final lines = <String>[
      if (frontendVersion.isNotEmpty)
        loc.welcomeFrontendUpdateAvailable(frontendVersion),
      if (backendVersion.isNotEmpty)
        loc.welcomeBackendUpdateAvailable(backendVersion),
      if (webappVersion.isNotEmpty)
        loc.welcomeWebappUpdateAvailable(webappVersion),
    ];

    if (lines.isEmpty) {
      return null;
    }

    lines.add('');
    lines.add(loc.welcomeUpdateAvailableAction);
    return lines.join('\n');
  }

  Future<void> _showUpdateAvailableDialog(
    BuildContext context,
    String message,
  ) async {
    if (_shownUpdateMessage == message) {
      return;
    }
    _shownUpdateMessage = message;

    final loc = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.welcomeUpdateAvailableTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketResultReceived) {
          BackendResultHandler.handle(context, state.result);
        }

        if (state is BackAppWebSocketWelcomeReceived) {
          final deviceName = state.welcomeMessage.deviceName;
          final currentUsername =
              GetIt.I<UserService>().currentUser?.username;
          if (deviceName == 'default' && currentUsername == 'admin') {
            // Automatically request admin info to get settings (autoSwitch) and trigger the dialog
            context.read<AppWebSocketBloc>().add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
              ),
            );
          }

          final loc = AppLocalizations.of(context)!;
          if (state.needUpdate) {
            if (state.viewId == 0 || !state.isDirty) {
              _viewUpdatedWithoutAsking = true;
              context.read<AppWebSocketBloc>().add(
                AppWebSocketSendSimpleCommandRequested(
                  commandType:
                      appmsg.AppSimpleCommandType.GET_CURRENT_USER_VIEW,
                ),
              );

              final updateMessage = _buildUpdateAvailableMessage(
                loc,
                state.welcomeMessage,
              );
              if (updateMessage != null) {
                _showUpdateAvailableDialog(context, updateMessage);
              }
            } else {
              final updateMessage = _buildUpdateAvailableMessage(
                loc,
                state.welcomeMessage,
              );
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(loc.syncAvailableTitle),
                  content: Text(loc.syncAvailableMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(loc.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(loc.update),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true && context.mounted) {
                  context.read<AppWebSocketBloc>().add(
                    AppWebSocketSendSimpleCommandRequested(
                      commandType: appmsg
                          .AppSimpleCommandType
                          .GET_CURRENT_USER_VIEW,
                    ),
                  );
                }

                if (updateMessage != null && context.mounted) {
                  _showUpdateAvailableDialog(context, updateMessage);
                }
              });
            }
          } else {
            final updateMessage = _buildUpdateAvailableMessage(
              loc,
              state.welcomeMessage,
            );
            if (updateMessage != null) {
              _showUpdateAvailableDialog(context, updateMessage);
            }
          }
        }

        if (state is BackAppWebSocketGotNewView) {
          if (_viewUpdatedWithoutAsking) {
            _viewUpdatedWithoutAsking = false;
            final loc = AppLocalizations.of(context);
            if (loc != null) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    loc.viewUpdatedNotification,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }

        if (state is BackAppWebSocketDashboardSynced) {
          if (!state.isUserInitiated) {
            final loc = AppLocalizations.of(context);
            if (loc != null) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    loc.dashboardUpdatedNotification,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }

        if (state is BackAppWebSocketGotAdminInfo) {
          final deviceName = state.info.deviceName;
          final currentUsername =
              GetIt.I<UserService>().currentUser?.username;

          if (deviceName == 'default' &&
              currentUsername == 'admin' &&
              !_setupDialogShown) {
            _setupDialogShown = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => InitialSetupDialog(
                initialAutoSwitch: state.info.autoSwitch,
              ),
            );
          }
        }
      },
      child: widget.child,
    );
  }
}
