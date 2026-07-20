import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_models.dart';
import 'package:smirror_app/bloc/setup_cubit.dart';
import 'package:smirror_wire/generated/dashboard_dashboard_structure_generated.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';

enum EntityTypeFilter { all, boolean, numeric, string }

class EntityPickerDialog extends StatefulWidget {
  const EntityPickerDialog({super.key});

  @override
  State<EntityPickerDialog> createState() => _EntityPickerDialogState();
}

class _EntityPickerDialogState extends State<EntityPickerDialog> {
  String _searchQuery = "";
  EntityTypeFilter _typeFilter = EntityTypeFilter.all;
  bool _onlyAvailable = false;
  late Future<List<HAEntityState>> _entitiesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch once on init to prevent re-fetching on local filter changes
    final setupState = context.read<SetupCubit>().state;
    if (setupState.emulateHomeAssistant) {
      _entitiesFuture = Future.value([
        HAEntityState(
          entityId: 'light.living_room',
          state: 'on',
          attributes: {'friendly_name': 'Living Room Light'},
        ),
        HAEntityState(
          entityId: 'switch.coffee_maker',
          state: 'off',
          attributes: {'friendly_name': 'Coffee Maker'},
        ),
        HAEntityState(
          entityId: 'sensor.temperature',
          state: '22.5',
          attributes: {
            'friendly_name': 'Temperature',
            'unit_of_measurement': '°C'
          },
        ),
        HAEntityState(
          entityId: 'binary_sensor.front_door',
          state: 'off',
          attributes: {'friendly_name': 'Front Door', 'device_class': 'door'},
        ),
      ]);
    } else {
      _entitiesFuture = GetIt.I<HomeAssistantApiService>().getEntities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.haSelectDashboard,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: FutureBuilder<List<HAEntityState>>(
              future: _entitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(loc.haEntityPickerError(snapshot.error.toString())),
                  );
                }

                // Client-side filtering logic
                final filtered = snapshot.data!.where((e) {
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch =
                      e.entityId.toLowerCase().contains(query) ||
                      (e.attributes['friendly_name']?.toString().toLowerCase() ??
                              "")
                          .contains(query);

                  final detectedType = detectEntityType(e);

                  final matchesType =
                      _typeFilter == EntityTypeFilter.all ||
                      (_typeFilter == EntityTypeFilter.boolean &&
                          detectedType == DashboardItemType.Boolean) ||
                      (_typeFilter == EntityTypeFilter.numeric &&
                          detectedType == DashboardItemType.Numeric) ||
                      (_typeFilter == EntityTypeFilter.string &&
                          detectedType == DashboardItemType.String);

                  final matchesAvailability =
                      !_onlyAvailable || (e.state != 'unavailable');

                  return matchesSearch && matchesType && matchesAvailability;
                }).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: loc.haSearchEntities,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                    const SizedBox(height: 12),

                    // 2. Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(EntityTypeFilter.all, loc.haFilterAll),
                          const SizedBox(width: 4),
                          _buildChip(EntityTypeFilter.boolean, loc.haFilterBool),
                          const SizedBox(width: 4),
                          _buildChip(EntityTypeFilter.numeric, loc.haFilterNumeric),
                          const SizedBox(width: 4),
                          _buildChip(EntityTypeFilter.string, loc.haFilterString),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(loc.haFilterOnlyAvailable),
                            selected: _onlyAvailable,
                            onSelected: (v) => setState(() => _onlyAvailable = v),
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // 3. Entity List
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final entity = filtered[i];
                          final name =
                              entity.attributes['friendly_name'] ?? entity.entityId;
                          final isOff =
                              entity.state == 'unavailable' ||
                              entity.state == 'unknown';
                          final type = detectEntityType(entity);

                          return ListTile(
                            leading: Icon(
                              type == DashboardItemType.Boolean
                                  ? Icons.toggle_on
                                  : type == DashboardItemType.Numeric
                                  ? Icons.numbers
                                  : Icons.text_snippet,
                              size: 18,
                              color: theme.hintColor,
                            ),
                            title: Text(name.toString()),
                            subtitle: Text(
                              entity.entityId,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isOff ? loc.haStateUnavailable : entity.state,
                                  style: TextStyle(
                                    color: isOff
                                        ? Colors.grey
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (entity.attributes['unit_of_measurement'] !=
                                    null)
                                  Text(
                                    entity.attributes['unit_of_measurement']
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () => Navigator.pop(context, entity),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(EntityTypeFilter filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _typeFilter == filter,
      onSelected: (v) => setState(() => _typeFilter = filter),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}
