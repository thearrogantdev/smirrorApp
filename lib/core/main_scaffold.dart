import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/session_context_cubit.dart';
import 'package:smirror_app/services/session_context_service.dart';
import 'package:smirror_app/services/user_service.dart';
import 'main_scaffold_navigation.dart';
import '../services/websocket_service.dart';
import 'package:smirror_app/screens/device_connection_dialog.dart';
import 'package:smirror_app/models/device_connection.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'change_password_dialog.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/dialogs/login_dialog.dart';
import 'package:smirror_app/screens/landing_screen.dart';

import 'user_scaffold.dart';
import 'admin_scaffold.dart';

@RoutePage()
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final _session = GetIt.I<SessionContextService>();
  StreamSubscription<void>? _upgradeSub;
  StreamSubscription<WsStatus>? _statusSub;
  StreamSubscription<User?>? _userSub;
  bool _hasConnectedOnce = false;

  @override
  void initState() {
    super.initState();
    final ws = GetIt.I<WebSocketService>();
    _upgradeSub = ws.upgradeRequired$.listen((_) {
      if (mounted) _showUpgradeDialog();
    });

    _statusSub = ws.status$.listen((status) {
      if (status == WsStatus.connected && !_hasConnectedOnce) {
        setState(() {
          _hasConnectedOnce = true;
        });
      }
    });

    final userService = GetIt.I<UserService>();
    _userSub = userService.onUserChanged.listen((user) {
      if (user == null && _hasConnectedOnce) {
        setState(() {
          _hasConnectedOnce = false;
        });
      }
    });

    if (ws.statusValue == WsStatus.connected) {
      _hasConnectedOnce = true;
    }
  }

  @override
  void dispose() {
    _upgradeSub?.cancel();
    _statusSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  void _showUpgradeDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.upgradeRequiredTitle),
        content: Text(loc.upgradeRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close), // or OK
          ),
        ],
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionContextCubit, int>(
      builder: (context, rights) {
        return MultiBlocListener(
          listeners: [
            BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
              listener: (context, state) {
                if (state is BackAppWebSocketResultReceived) {
                  _handleBackendResult(context, state.result);
                }
              },
            ),
          ],
          child: Builder(
            builder: (context) {
              // Show LandingScreen if we haven't successfully connected since startup
              if (!_hasConnectedOnce) {
                return const LandingScreen();
              }

              if (_session.isAdmin) {
                return const AdminScaffold();
              } else {
                return const UserScaffold();
              }
            },
          ),
        );
      },
    );
  }

  void _handleBackendResult(BuildContext context, backmsg.ResultT result) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return;

    String? message;
    bool isSuccess = false;

    switch (result.errorCode) {
      case backmsg.ErrorCode.OK:
        if (result.success) {
          isSuccess = true;
          // For generic OK, we only show a snackbar if there is an explicit message
          // or if it's a known success case. Otherwise it might be too noisy.
          if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
            message = result.errorMessage;
          }
        }
        break;
      case backmsg.ErrorCode.UNKNOWN_ERROR:
        message = loc.errorUnknown;
        break;
      case backmsg.ErrorCode.INVALID_CREDENTIALS:
        message = loc.errorInvalidCredentials;
        break;
      case backmsg.ErrorCode.CONFIG_ERROR:
        message = loc.errorConfigError;
        break;
      case backmsg.ErrorCode.INVALID_MESSAGE:
        message = loc.errorInvalidMessage;
        break;
      case backmsg.ErrorCode.ADD_TOKEN:
        if (result.success) {
          message = loc.adminTokenAddSuccess;
          isSuccess = true;
        } else {
          message = loc.errorAddToken;
        }
        break;
      case backmsg.ErrorCode.FACE_TRAINING_SUCCESS:
        message = loc.errorFaceTrainingSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.FACE_TRAINING_FAILED:
        message = loc.errorFaceTrainingFailed;
        break;
      case backmsg.ErrorCode.ADD_CREATE_USER_SUCCESS:
        message = loc.errorAddCreateUserSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.ADD_CREATE_USER_FAILED:
        message = loc.errorAddCreateUserFailed;
        break;
      case backmsg.ErrorCode.UNAUTHORIZED:
        message = loc.errorUnauthorized;
        break;
      case backmsg.ErrorCode.SERVICE_NOT_AVAILABLE:
        message = loc.errorServiceNotAvailable;
        break;
      case backmsg.ErrorCode.PASSWORD_CHANGE_SUCCESS:
        message = loc.passwordChangeSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.PASSWORD_CHANGE_FAIL:
        message = loc.passwordChangeError;
        break;
      case backmsg.ErrorCode.FRONTEND_UPDATED:
        message = loc.errorFrontendUpdated;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.BACKEND_UPDATED:
        message = loc.errorBackendUpdated;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.UPDATED_FAILED:
        message = loc.errorUpdateFailed;
        break;
      case backmsg.ErrorCode.DASHBOARD_OK:
        message = loc.dashboardUploadSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.DASHBOARD_ERROR:
        message = loc.dashboardUploadError;
        break;
      case backmsg.ErrorCode.VIEW_OK:
        message = loc.viewUploadSuccess;
        isSuccess = true;
        break;
      case backmsg.ErrorCode.VIEW_ERROR:
        message = loc.viewUploadError;
        break;
      default:
        break;
    }

    if (message != null) {
      final showSubtitle = result.errorMessage != null &&
          result.errorMessage!.isNotEmpty &&
          result.errorMessage != message;

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showSubtitle)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    result.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ── Data types ────────────────────────────────────────────────────────────────

enum RailRowType { topLevel, sectionHeader, subItem }

class RailVisualItem {
  final NavEntry entry;
  final RailRowType type;
  final bool expanded;

  RailVisualItem({
    required this.entry,
    required this.type,
    this.expanded = false,
  });
}

// ── Rail widgets ──────────────────────────────────────────────────────────────

class RailItemWidget extends StatelessWidget {
  final RailVisualItem item;
  final bool isSelected;

  const RailItemWidget({super.key, required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (item.type == RailRowType.sectionHeader) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.entry.icon, size: 24),
          const SizedBox(width: 8),
          Icon(
            item.expanded ? Icons.expand_more : Icons.chevron_right,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      );
    }
    if (item.type == RailRowType.subItem) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(width: 20), Icon(item.entry.icon, size: 20)],
      );
    }
    return Icon(item.entry.icon, size: 24);
  }
}

class RailStatus extends StatelessWidget {
  const RailStatus({super.key});

  static const List<({String label, IconData icon, Color color})> _metaByIndex =
      [
        (label: 'Offline', icon: Icons.error_outline, color: Colors.redAccent),
        (label: 'Connecting…', icon: Icons.schedule, color: Colors.amber),
        (label: 'Connected', icon: Icons.check_circle, color: Colors.green),
        (label: 'Reconnecting…', icon: Icons.sync, color: Colors.deepOrange),
        (
          label: 'Connected (login needed)',
          icon: Icons.lock_outline,
          color: Colors.deepOrange,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final ws = GetIt.I<WebSocketService>();
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<DeviceConnection?>(
        stream: ws.activeDevice$,
        initialData: ws.activeDevice,
        builder: (context, activeSnap) {
          final hasDevice = activeSnap.data != null;
          return StreamBuilder<WsStatus>(
            stream: ws.status$,
            initialData: ws.statusValue,
            builder: (context, snap) {
              final meta = hasDevice
                  ? _metaByIndex[(snap.data ?? WsStatus.disconnected).index]
                  : (
                      label: loc.addDevice,
                      icon: Icons.add_link,
                      color: Theme.of(context).colorScheme.primary,
                    );
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: kIsWeb ? null : () {
                  showDialog(
                    context: context,
                    builder: (context) => const DeviceConnectionDialog(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: meta.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(meta.icon, size: 20, color: meta.color),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activeSnap.data?.name ?? loc.deviceConnection,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            Text(
                              meta.label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: meta.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = GetIt.I<UserService>();
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<User?>(
        stream: userService.onUserChanged,
        initialData: userService.currentUser,
        builder: (context, snap) {
          final name = snap.data?.username ?? loc.unknown; // or 'Not Logged In'
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.currentUser,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => showLoginDialog(context),
                  icon: const Icon(Icons.manage_accounts, size: 18),
                  label: Text(loc.changeUser),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
                  ),
                  icon: const Icon(Icons.password, size: 18),
                  label: Text(loc.changePassword),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


