import 'dart:async';
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
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HASingleDashboard extends WidgetTypeDefinition {
  HASingleDashboard()
    : super(
        typeId: WidgetIds.singleHADashboard,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameHASingleDashboard,
        defaultSize: const Size(100, 40),
      );

  @override
  String? get requiredTokenId => 'HomeAssistant';

  @override
  bool get isResizable => false;

  @override
  Size getSize(ViewConfigItem item) {
    final dashboardID =
        item.properties[PropertyIdsSingleHADashboard.dashboardID].intValue ?? 0;
    final dashboardName =
        item.properties[PropertyIdsSingleHADashboard.dashboardName].stringValue;

    final dashboard = GetIt.I<HomeAssistantStore>().getOrCreatePlaceholder(dashboardID, dashboardName);
    return Size(dashboard.width, dashboard.height);
  }

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsSingleHADashboard.dashboardID,
      type: ViewConfigPropertyType.int,
      intValue: 0,
    ),
    ViewConfigProperty(
      key: PropertyIdsSingleHADashboard.dashboardName,
      type: ViewConfigPropertyType.string,
      stringValue: "",
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final dashboardID =
        item.properties[PropertyIdsSingleHADashboard.dashboardID].intValue ?? 0;
    final dashboardName =
        item.properties[PropertyIdsSingleHADashboard.dashboardName].stringValue;

    final dashboard = GetIt.I<HomeAssistantStore>().getOrCreatePlaceholder(dashboardID, dashboardName);

    return Container(
      alignment: Alignment.center,
      color: Colors.black26,
      child: Text(
        dashboard.name,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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
      (p) => p.key == PropertyIdsSingleHADashboard.dashboardID,
      orElse: () => createDefaultProperties().first,
    );
    final int initialBackendId = existingProp?.intValue ?? 0;

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
                        initialValue: {'dashboardId': initialBackendId != 0 ? initialBackendId : (infos.isNotEmpty ? infos.first.backendId.toInt() : null)},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (infos.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  loc.haNoDashboardsFound,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              FormBuilderDropdown<int>(
                                name: 'dashboardId',
                                decoration: InputDecoration(labelText: loc.widgetNameHASingleDashboard),
                                items: [
                                  for (final info in infos)
                                    DropdownMenuItem(
                                      value: info.backendId.toInt(),
                                      child: Text(info.name ?? 'ID: ${info.backendId}'),
                                    ),
                                ],
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
                        final selectedId = formKey.currentState!.value['dashboardId'] as int?;

                        if (selectedId != null) {
                          final state = context.read<BackAppWebSocketBloc>().state;
                          if (state is BackAppWebSocketGotDashboardInfo) {
                            final info = state.dashboardInfo.firstWhere((i) => i.backendId == selectedId);
                            GetIt.I<HomeAssistantStore>().getOrCreatePlaceholder(selectedId, info.name);

                            Navigator.pop(ctx, [
                              ViewConfigProperty(
                                key: PropertyIdsSingleHADashboard.dashboardID,
                                type: ViewConfigPropertyType.int,
                                intValue: selectedId,
                              ),
                              ViewConfigProperty(
                                key: PropertyIdsSingleHADashboard.dashboardName,
                                type: ViewConfigPropertyType.string,
                                stringValue: info.name ?? "HA Dashboard: #$selectedId",
                              ),
                            ]);
                          } else {
                            // Fallback if state is lost
                            Navigator.pop(ctx, [
                              ViewConfigProperty(
                                key: PropertyIdsSingleHADashboard.dashboardID,
                                type: ViewConfigPropertyType.int,
                                intValue: selectedId,
                              ),
                              ViewConfigProperty(
                                key: PropertyIdsSingleHADashboard.dashboardName,
                                type: ViewConfigPropertyType.string,
                                stringValue: "HA Dashboard: #$selectedId",
                              ),
                            ]);
                          }
                        } else {
                          Navigator.pop(ctx);
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
}
