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
import 'package:smirror_app/dialogs/login_dialog.dart';
import 'package:smirror_app/screens/landing_screen.dart';
import 'backend_response_listener.dart';

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
  StreamSubscription<void>? _conflictSub;
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

    _conflictSub = ws.conflictDetected$.listen((_) {
      if (mounted) _showConflictDialog();
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
    _conflictSub?.cancel();
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

  void _showConflictDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.conflictDialogTitle),
        content: Text(loc.conflictDialogMessage),
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
    return BlocBuilder<SessionContextCubit, int>(
      builder: (context, _) {
        return BackendResponseListener(
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


