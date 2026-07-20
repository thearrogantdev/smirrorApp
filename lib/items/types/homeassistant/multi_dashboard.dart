import 'package:flutter/material.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart' as appmsg;
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart' as dash;
import 'package:smirror_wire/generated/widget_internals_widget_internals_generated.dart' as internals;
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_app/database/home_assistant_store.dart';
import 'dart:typed_data';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

class HAMultiDashboard extends WidgetTypeDefinition {
  HAMultiDashboard()
    : super(
        typeId: WidgetIds.multiHADashboard,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameHAMultiDashboard,
        defaultSize: const Size(200, 150),
      );

  @override
  String? get requiredTokenId => 'HomeAssistant';

  @override
  bool get isResizable => false;

  @override
  Size getSize(ViewConfigItem item) {
    final bytes =
        item.properties[PropertyIdsMultiHADashboard.dashboardIds].rawBytes;
    final ids = _unpackIds(bytes);

    final namesString =
        item.properties[PropertyIdsMultiHADashboard.dashboardNames].stringValue ?? "";
    final namesList = namesString.isEmpty ? <String>[] : namesString.split("|||");

    final store = GetIt.I<HomeAssistantStore>();
    if (ids.isEmpty) {
      return defaultSize;
    }

    double maxArea = -1;
    Size biggestSize = defaultSize;

    for (int i = 0; i < ids.length; i++) {
      final name = (namesList.length > i) ? namesList[i] : null;
      final dashboard = store.getOrCreatePlaceholder(ids[i], name);
      final area = dashboard.width * dashboard.height;
      if (area > maxArea) {
        maxArea = area;
        biggestSize = Size(dashboard.width, dashboard.height);
      }
    }

    return biggestSize;
  }

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsMultiHADashboard.dashboardIds,
      type: ViewConfigPropertyType.rawBytes,
      rawBytes: Uint8List(0), // Initial empty blob
    ),
    ViewConfigProperty(
      key: PropertyIdsMultiHADashboard.dashboardNames,
      type: ViewConfigPropertyType.string,
      stringValue: "",
    ),
  ];

  // Logic to unpack IDs from the "Binary Tunnel"
  List<int> _unpackIds(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return [];
    try {
      final list = internals.DashboardList(bytes);
      return list.ids ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget buildChild(ViewConfigItem item) {
    final bytes =
        item.properties[PropertyIdsMultiHADashboard.dashboardIds].rawBytes;
    final ids = _unpackIds(bytes);

    final namesString =
        item.properties[PropertyIdsMultiHADashboard.dashboardNames].stringValue ?? "";
    final namesList = namesString.isEmpty ? <String>[] : namesString.split("|||");

    final store = GetIt.I<HomeAssistantStore>();
    final names = <String>[];
    for (int i = 0; i < ids.length; i++) {
      final name = (namesList.length > i) ? namesList[i] : null;
      names.add(store.getOrCreatePlaceholder(ids[i], name).name);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.layers, color: Colors.white54),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              names.isEmpty ? "No dashboards" : names.join(", "),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormBuilderState>();

    // Trigger fetch from backend
    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.GET_ALL_DASHBOARD_INFO,
      ),
    );

    final existingProp = initial?.firstWhere(
      (p) => p.key == PropertyIdsMultiHADashboard.dashboardIds,
      orElse: () => createDefaultProperties().first,
    );

    final List<int> initialBackendIds = _unpackIds(existingProp?.rawBytes);

    return showDialog<List<ViewConfigProperty>>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AppDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.haSelectDashboards,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: BlocBuilder<BackAppWebSocketBloc, BackAppWebSocketState>(
                    buildWhen: (prev, curr) => curr is BackAppWebSocketGotDashboardInfo,
                    builder: (context, state) {
                      List<dash.DashboardInfo> infos = [];
                      if (state is BackAppWebSocketGotDashboardInfo) {
                        infos = state.dashboardInfo;
                      }

                      if (infos.isEmpty && state is! BackAppWebSocketGotDashboardInfo) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return FormBuilder(
                        key: formKey,
                        initialValue: {'ids': initialBackendIds},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FormBuilderField<List<int>>(
                              name: 'ids',
                              builder: (FormFieldState<List<int>?> field) {
                                final List<int> currentIds = field.value ?? [];

                                return Column(
                                  children: [
                                    if (currentIds.isEmpty && infos.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          loc.haNoDashboardsFound,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),

                                    // REORDERABLE LIST
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxHeight: 350),
                                      child: ReorderableListView(
                                        shrinkWrap: true,
                                        onReorderItem: (oldIdx, newIdx) {
                                          final newList = List<int>.from(currentIds);
                                          final item = newList.removeAt(oldIdx);
                                          newList.insert(newIdx, item);
                                          field.didChange(newList);
                                        },
                                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: Card(elevation: 4, child: child),
                                          );
                                        },
                                        children: [
                                          for (int i = 0; i < currentIds.length; i++)
                                            ReorderableDragStartListener(
                                              key: ValueKey(currentIds[i]),
                                              index: i,
                                              child: ListTile(
                                                leading: const Icon(Icons.drag_handle),
                                                title: Text(
                                                  infos.any((d) => d.backendId == currentIds[i])
                                                      ? (infos.firstWhere((d) => d.backendId == currentIds[i]).name ?? 'ID: ${currentIds[i]}')
                                                      : 'ID: ${currentIds[i]} (Missing)',
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.red),
                                                  onPressed: () {
                                                    final newList = List<int>.from(currentIds)..removeAt(i);
                                                    field.didChange(newList);
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                    TextButton.icon(
                                      onPressed: infos.isEmpty ? null : () => _showAddMenu(
                                        ctx,
                                        infos,
                                        currentIds,
                                        (newId) {
                                          final newList = List<int>.from(currentIds)..add(newId);
                                          field.didChange(newList);
                                        },
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: Text(loc.haAddDashboard),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(loc.delete),
                    ),
                  if (onDelete != null) const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(loc.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        final selectedIds = List<int>.from(formKey.currentState!.value['ids']);
                        final state = context.read<BackAppWebSocketBloc>().state;
                        if (state is BackAppWebSocketGotDashboardInfo) {
                          final List<String> selectedNames = [];
                          for (final id in selectedIds) {
                            final info = state.dashboardInfo.firstWhere((i) => i.backendId == id, orElse: () => throw StateError("Selected ID not found in info list"));
                            final name = info.name ?? "HA Dashboard: #$id";
                            GetIt.I<HomeAssistantStore>().getOrCreatePlaceholder(id, name);
                            selectedNames.add(name);
                          }

                          // --- BINARY PACKING FOR BACKEND ---
                          final builder = fb.Builder(initialSize: 128);
                          final idsOffset = builder.writeListUint64(selectedIds);

                          final listBuilder = internals.DashboardListBuilder(builder);
                          listBuilder.begin();
                          listBuilder.addIdsOffset(idsOffset);
                          final offset = listBuilder.finish();
                          builder.finish(offset);

                          Navigator.pop(ctx, [
                            ViewConfigProperty(
                              key: PropertyIdsMultiHADashboard.dashboardIds,
                              type: ViewConfigPropertyType.rawBytes,
                              rawBytes: builder.buffer,
                            ),
                            ViewConfigProperty(
                              key: PropertyIdsMultiHADashboard.dashboardNames,
                              type: ViewConfigPropertyType.string,
                              stringValue: selectedNames.join("|||"),
                            ),
                          ]);
                        }
                      }
                    },
                    child: Text(loc.save),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMenu(
    BuildContext context,
    List<dash.DashboardInfo> all,
    List<int> current,
    Function(int) onAdded,
  ) {
    final available = all.where((d) => !current.contains(d.backendId)).toList();
    if (available.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: available
            .map(
              (d) => ListTile(
                title: Text(d.name ?? 'ID: ${d.backendId}'),
                onTap: () {
                  onAdded(d.backendId.toInt());
                  Navigator.pop(ctx);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
