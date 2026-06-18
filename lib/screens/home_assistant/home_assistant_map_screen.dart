import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_bloc.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_event.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_models.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_state.dart';
import 'package:smirror_app/bloc/setup_cubit.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart'
    as dash;
import 'package:smirror_app/items/common_canvas.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:smirror_app/database/home_dashboard.dart';
import 'package:smirror_app/screens/home_assistant/dashboard_widget.dart';
import 'package:smirror_app/screens/home_assistant/entity_picker.dart';
import 'package:smirror_app/screens/home_assistant/item_config_dialog.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';
import 'package:smirror_app/services/token_provider.dart';

@RoutePage()
class HomeAssistantMapScreen extends StatefulWidget {
  const HomeAssistantMapScreen({super.key});

  @override
  State<HomeAssistantMapScreen> createState() => _HomeAssistantMapScreenState();
}

class _HomeAssistantMapScreenState extends State<HomeAssistantMapScreen> {
  Map<String, HAEntityState> _entityMap = {};
  Future<HAValidationResult>? _connectionCheckFuture;
  late Dashboard currentDashboard;
  final apiService = GetIt.I<HomeAssistantApiService>();
  bool _didInitialSync = false;

  @override
  void initState() {
    super.initState();
    apiService.status.addListener(_onTokenStatusChanged);
  }

  void _onTokenStatusChanged() {
    if (!mounted) return;
    final setupState = context.read<SetupCubit>().state;
    if (setupState.emulateHomeAssistant) return; // Ignore real status in emulation mode

    // If the token provider's state was reset under us, force a re-check
    // so the UI knows it needs a new token/url config.
    if (apiService.status.value == TokenStatus.unknown) {
      setState(() {
        _connectionCheckFuture = _performConnectionCheck();
      });
    }
  }

  @override
  void dispose() {
    apiService.status.removeListener(_onTokenStatusChanged);
    super.dispose();
  }

  Future<HAValidationResult> _performConnectionCheck() async {
    if (!mounted) {
      return HAValidationResult(HAValidationStatus.unreachable, message: "Widget unmounted");
    }

    final setupState = context.read<SetupCubit>().state;
    if (setupState.emulateHomeAssistant) {
      _fetchLiveStates();
      return HAValidationResult(
        HAValidationStatus.ok,
        message: "Emulated Mode",
      );
    }

    // Capture Blocs before async gap to avoid using context if we get demounted
    final appBloc = context.read<AppWebSocketBloc>();
    final backStream = context.read<BackAppWebSocketBloc>().stream;

    final result = await apiService.checkConnection(
      appBloc: appBloc,
      backStream: backStream,
    );

    if (result.ok && mounted) {
      _fetchLiveStates();
    }

    return result;
  }

  Future<void> _fetchLiveStates() async {
    if (!mounted) return;
    final setupState = context.read<SetupCubit>().state;
    if (setupState.emulateHomeAssistant) {
      setState(() {
        _entityMap = {
          'light.living_room': HAEntityState(
            entityId: 'light.living_room',
            state: 'on',
            attributes: {'friendly_name': 'Living Room Light'},
          ),
          'switch.coffee_maker': HAEntityState(
            entityId: 'switch.coffee_maker',
            state: 'off',
            attributes: {'friendly_name': 'Coffee Maker'},
          ),
          'sensor.temperature': HAEntityState(
            entityId: 'sensor.temperature',
            state: '22.5',
            attributes: {
              'friendly_name': 'Temperature',
              'unit_of_measurement': '°C'
            },
          ),
          'binary_sensor.front_door': HAEntityState(
            entityId: 'binary_sensor.front_door',
            state: 'off',
            attributes: {
              'friendly_name': 'Front Door',
              'device_class': 'door'
            },
          ),
        };
      });
      return;
    }

    try {
      final entities = await GetIt.I<HomeAssistantApiService>().getEntities();
      if (mounted) {
        setState(() {
          _entityMap = {for (var e in entities) e.entityId: e};
        });
      }
    } catch (e) {
      debugPrint("Live Poll Error: $e");
    }
  }

  void _pickBackground(BuildContext context, Dashboard currentDashboard) {
    final loc = AppLocalizations.of(context)!;

    showConfigDialog<bool>(
      context: context,
      title: loc.haRenameDashboardTitle,
      initialValues: {
        'bg': [
          currentDashboard.backgroundImagePath != null &&
                  currentDashboard.backgroundImagePath!.isNotEmpty
              ? XFile(currentDashboard.backgroundImagePath!)
              : null,
        ],
      },
      buildForm: (ctx, formKey) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderImagePicker(
              name: 'bg',
              decoration: InputDecoration(
                labelText: loc.haSelectBackgroundImage,
              ),
              maxImages: 1,
              previewAutoSizeWidth: true,
            ),
          ],
        );
      },
      onSubmit: (values) async {
        final List<dynamic>? images = values['bg'] as List<dynamic>?;

        if (images != null && images.isNotEmpty) {
          // FormBuilderImagePicker returns XFile objects
          final XFile? first = images.first is XFile
              ? images.first as XFile
              : null;

          if (first != null) {
            // Update the local Dashboard object
            currentDashboard.backgroundImagePath = first.path;
            // Reset ID so that the AppWebSocketBloc knows it needs to be uploaded to the backend
            currentDashboard.backgroundImageId = 0;

            try {
              final bytes = await File(first.path).readAsBytes();
              final decodedImage = await decodeImageFromList(bytes);
              currentDashboard.width = decodedImage.width.toDouble();
              currentDashboard.height = decodedImage.height.toDouble();
            } catch (e) {
              debugPrint("Failed to decode background image dimensions: $e");
            }

            // Dispatch to Bloc to save in ObjectBox and update UI
            if (context.mounted) {
              context.read<HABloc>().add(
                UpdateDashboardEvent(currentDashboard),
              );
            }
          }
        }
        return true;
      },
    );
  }

  /// Handles adding a NEW item
  void _handleAddNew(BuildContext context, Offset localPosition) async {
    // Ensure the new item cannot be added partially outside the bounds (assuming 80x80 items)
    final clampedX = localPosition.dx.clamp(0.0, currentDashboard.width - 80.0);
    final clampedY = localPosition.dy.clamp(0.0, currentDashboard.height - 80.0);
    final safePos = Offset(clampedX, clampedY);

    final HAEntityState? entity = await showDialog<HAEntityState>(
      context: context,
      builder: (context) => const EntityPickerDialog(),
    );

    if (!context.mounted || entity == null) return;
    final DashboardItem? configuredItem = await showDialog<DashboardItem>(
      context: context,
      builder: (context) =>
          ItemConfigDialog(entity: entity, position: safePos),
    );

    if (context.mounted && configuredItem != null) {
      configuredItem.dashboard.targetId = currentDashboard.id;
      context.read<HABloc>().add(SaveDashboardItem(configuredItem));
    }
  }

  bool _isDashboardOutdated(dash.DashboardInfo info) {
    final store = GetIt.I<HomeAssistantStore>();
    return store.getDashboardTimestampByBackendId(info.backendId) < info.timestamp;
  }

  /// Handles editing an EXISTING item
  void _handleEdit(
    BuildContext context,
    DashboardItem item,
    HAEntityState entity,
  ) async {
    // The result can be DashboardItem, the String 'delete', or null (cancel)
    final dynamic result = await showDialog(
      context: context,
      builder: (context) => ItemConfigDialog(
        entity: entity,
        position: Offset(item.x.toDouble(), item.y.toDouble()),
        existingItem: item,
      ),
    );

    if (!context.mounted || result == null) return;

    if (result == 'delete') {
      context.read<HABloc>().add(DeleteDashboardItem(item.id));
    } else if (result is DashboardItem) {
      context.read<HABloc>().add(SaveDashboardItem(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bool isRouteActive =
        context.router.isRouteActive(context.routeData.name);

    if (isRouteActive && !_didInitialSync) {
      _didInitialSync = true;
      Future.microtask(() {
        if (context.mounted) {
          setState(() {
            _connectionCheckFuture = _performConnectionCheck();
          });
          context.read<AppWebSocketBloc>().add(
                AppWebSocketSendSimpleCommandRequested(
                  commandType:
                      appmsg.AppSimpleCommandType.GET_ALL_DASHBOARD_INFO,
                ),
              );
        }
      });
    }

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listenWhen: (_, current) =>
          current is BackAppWebSocketGotDashboardInfo && isRouteActive,
      listener: (context, state) {
        if (!mounted) return;
        final infos =
            (state as BackAppWebSocketGotDashboardInfo).dashboardInfo;
        _showDashboardSyncDialog(context, infos);
      },
      child: BlocBuilder<HABloc, HAState>(
        builder: (context, state) {
          if (state is! HASuccess) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Check Connection to Home Assistant FIRST
          return FutureBuilder<HAValidationResult>(
            future: _connectionCheckFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatusOverlay(
                  Icons.sync,
                  "Checking connection...",
                  Colors.blue,
                );
              }

              final result = snapshot.data;

              // Handle Errors (Token or URL) BEFORE dashboard checking
              if (result == null || !result.ok) {
                return _buildErrorUI(result);
              }

              // Connection is OK - Now check if we have dashboards
              if (state.dashboards.isEmpty) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dashboard_outlined,
                          color: Colors.white38,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.haNoDashboards,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FloatingActionButton.extended(
                          onPressed: () => _showDashboardForm(context),
                          icon: const Icon(Icons.add),
                          label: Text(loc.haAddDashboard),
                        ),
                      ],
                    ),
                  ),
                );
              }

              currentDashboard = state.dashboards.firstWhere(
                (d) => d.id == state.currentDashboardId,
                orElse: () => state.dashboards.first,
              );

              return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: _DashboardDropdown(state: state),
                  actions: [
                    // Background Picker Button
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      tooltip: "Change Background",
                      onPressed: () => _pickBackground(context, currentDashboard),
                    ),
                    // Snapping Toggle
                    IconButton(
                      icon: Icon(state.snapToGrid ? Icons.grid_on : Icons.grid_off),
                      tooltip: state.snapToGrid
                          ? loc.haDisableSnapping
                          : loc.haEnableSnapping,
                      onPressed: () =>
                          context.read<HABloc>().add(ToggleSnapEvent()),
                    ),
                    // Edit Dashboard Name
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: loc.haRenameDashboard,
                      onPressed: () =>
                          _showDashboardForm(context, existing: currentDashboard),
                    ),
                    // Add New Dashboard
                    IconButton(
                      icon: const Icon(Icons.add_to_photos),
                      tooltip: loc.haAddDashboard,
                      onPressed: () => _showDashboardForm(context),
                    ),
                    // Delete Dashboard
                    if (state.dashboards.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: loc.haDeleteDashboard,
                        onPressed: () => _confirmDelete(context, currentDashboard),
                      ),
                    IconButton(
                      icon: const Icon(Icons.upload),
                      tooltip: loc.upload,
                      onPressed: () => context.read<AppWebSocketBloc>().add(
                        AppWebSocketSendDashboardRequest(state.currentDashboardId!),
                      ),
                    ),
                  ],
                ),
                body: LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 0.1,
                            maxScale: 3.0,
                            constrained: false,
                            boundaryMargin: const EdgeInsets.all(500),
                            child: SizedBox(
                              width: currentDashboard.width,
                              height: currentDashboard.height,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white24, width: 2),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    // BACKGROUND IMAGE LAYER
                                    if (currentDashboard.backgroundImagePath !=
                                        null &&
                                        currentDashboard.backgroundImagePath!
                                            .isNotEmpty)
                                      Positioned.fill(
                                        child: Image.file(
                                          File(currentDashboard
                                              .backgroundImagePath!),
                                          fit: BoxFit.fill,
                                          // Handle cases where the file might have been deleted from storage
                                          errorBuilder: (ctx, err, stack) =>
                                          const SizedBox.shrink(),
                                        ),
                                      ),

                                    // INTERACTIVE CANVAS LAYER
                                    CommonCanvas<DashboardItem>(
                                      items: state.dashboardItems,
                                      gridSize: 80.0,
                                      snapEnabled: state.snapToGrid,
                                      canResize: false,
                                      getX: (item) => item.x.toDouble(),
                                      getY: (item) => item.y.toDouble(),
                                      getWidth: (_) => 80.0,
                                      getHeight: (_) => 80.0,
                                      builder: (item) {
                                        final liveValue =
                                            _entityMap[item.entityId]?.state ??
                                                '...';
                                        return DashboardWidget(
                                          item: item,
                                          liveValue: liveValue,
                                        );
                                      },
                                      onUpdateItem: (item, pos, size) {
                                        item.x = pos.dx;
                                        item.y = pos.dy;
                                        context.read<HABloc>().add(
                                            SaveDashboardItem(item));
                                      },
                                      onLongPressCanvas: (pos) =>
                                          _handleAddNew(context, pos),
                                      onLongPressItem: (item) {
                                        final entity = _entityMap[item
                                            .entityId];
                                        if (entity != null) {
                                          _handleEdit(context, item, entity);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Dashboard dashboard) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.haDeleteConfirmTitle),
        content: Text(loc.haDeleteConfirmContent(dashboard.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              if (dashboard.backendId != 0) {
                context.read<AppWebSocketBloc>().add(
                      AppWebSocketDeleteDashboardRequest(
                        dashboardBackendId: dashboard.backendId,
                      ),
                    );
              }
              context.read<HABloc>().add(DeleteDashboardEvent(dashboard.id));
              Navigator.pop(ctx);
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDashboardSyncDialog(
    BuildContext context,
    List<dash.DashboardInfo> infos,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DashboardSyncDialog(
        infos: infos,
        isOutdated: _isDashboardOutdated,
      ),
    );
  }

  void _showDashboardForm(BuildContext context, {Dashboard? existing}) {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: existing?.name ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? loc.haNewDashboard : loc.haRenameDashboardTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: loc.haDashboardNameField),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              if (existing == null) {
                context.read<HABloc>().add(
                      AddDashboardEvent(
                        name: controller.text,
                      ),
                    );
              } else {
                existing.name = controller.text;
                context.read<HABloc>().add(UpdateDashboardEvent(existing));
              }
              Navigator.pop(ctx);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(HAValidationResult? result) {
    final loc = AppLocalizations.of(context)!;
    IconData icon = Icons.error_outline;
    String title = loc.haConnectionFailed;
    String message = result?.message ?? "";

    if (result?.status == HAValidationStatus.invalidToken) {
      title = loc.haTokenError;
      message = loc.haTokenErrorMessage;
    } else if (result?.status == HAValidationStatus.unreachable) {
      title = loc.haUnreachable;
      message = loc.haUnreachableMessage;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Text(
            "Please configure the Home Assistant connection in the Admin panel.",
            style: TextStyle(color: Colors.amber[300], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _connectionCheckFuture = _performConnectionCheck();
              });
            },
            child: Text(loc.haRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay(IconData icon, String label, Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _DashboardDropdown extends StatelessWidget {
  final HASuccess state;
  const _DashboardDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    // Safety Check: Verify if the current ID actually exists in the current dashboard list
    // this should never happen
    final bool valueExists = state.dashboards.any(
      (d) => d.id == state.currentDashboardId,
    );

    return DropdownButton<int>(
      // Use the current ID only if it exists in the items list;
      // otherwise, use null to avoid the crash.
      value: valueExists ? state.currentDashboardId : null,
      dropdownColor: Colors.grey[900],
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      items: state.dashboards.map((d) {
        return DropdownMenuItem<int>(
          value: d.id, // Ensure ObjectBox IDs are unique
          child: Text(d.name),
        );
      }).toList(),
      onChanged: (id) {
        if (id != null) {
          context.read<HABloc>().add(SwitchDashboard(id));
        }
      },
    );
  }
}

class _DashboardSyncDialog extends StatefulWidget {
  final List<dash.DashboardInfo> infos;
  final bool Function(dash.DashboardInfo) isOutdated;

  const _DashboardSyncDialog({
    required this.infos,
    required this.isOutdated,
  });

  @override
  State<_DashboardSyncDialog> createState() => _DashboardSyncDialogState();
}

class _DashboardSyncDialogState extends State<_DashboardSyncDialog> {
  final Set<int> _syncingIds = {};
  final Set<int> _syncedIds = {};
  late List<dash.DashboardInfo> _initialOutdated;

  @override
  void initState() {
    super.initState();
    _initialOutdated = widget.infos.where(widget.isOutdated).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listenWhen: (_, current) => current is BackAppWebSocketDashboardSynced,
      listener: (context, state) {
        if (!mounted) return;
        final synced = state as BackAppWebSocketDashboardSynced;
        setState(() {
          _syncingIds.remove(synced.backendId);
          _syncedIds.add(synced.backendId);
        });
      },
      child: AlertDialog(
        title: Text(loc.syncAvailableTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.syncAvailableMessage),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _initialOutdated.length,
                  itemBuilder: (context, index) {
                    final info = _initialOutdated[index];
                    final bid = info.backendId.toInt();
                    final isSyncing = _syncingIds.contains(bid);
                    final isSynced = _syncedIds.contains(bid);

                    Widget trailing;
                    if (isSyncing) {
                      trailing = const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    } else if (isSynced) {
                      trailing = const Icon(Icons.check_circle, color: Colors.green);
                    } else {
                      trailing = TextButton(
                        onPressed: () {
                          setState(() => _syncingIds.add(bid));
                          context.read<AppWebSocketBloc>().add(
                                AppWebSocketRequestDashboardUpdate(
                                  dashboardBackendId: bid,
                                ),
                              );
                        },
                        child: Text(loc.update),
                      );
                    }

                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.dashboard_outlined),
                      title: Text(info.name ?? ''),
                      trailing: trailing,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final stillOutdated = _initialOutdated.where(
                (info) => !_syncedIds.contains(info.backendId.toInt()),
              );
              for (var info in stillOutdated) {
                final bid = info.backendId.toInt();
                if (!_syncingIds.contains(bid)) {
                  setState(() => _syncingIds.add(bid));
                  context.read<AppWebSocketBloc>().add(
                        AppWebSocketRequestDashboardUpdate(
                          dashboardBackendId: bid,
                        ),
                      );
                }
              }
            },
            child: Text(loc.updateAll),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }
}
