import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_bloc.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_event.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_state.dart';
import 'package:smirror_app/items/common_canvas.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/items/widget_type_registry.dart'
    show WidgetTypeRegistry;
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/services/google_token_service.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';
import 'package:smirror_app/services/open_weather_validation_service.dart';
import 'package:smirror_wire/constants/widget_ids.dart';

@RoutePage()
class ViewConfigScreen extends StatefulWidget {
  const ViewConfigScreen({super.key});

  @override
  State<ViewConfigScreen> createState() => _ViewConfigScreenState();
}

class _ViewConfigScreenState extends State<ViewConfigScreen> {
  @override
  void initState() {
    super.initState();
    // Eagerly fetch all token statuses so the Add Widget dialog is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appBloc = context.read<AppWebSocketBloc>();
      final backStream = context.read<BackAppWebSocketBloc>().stream;
      GetIt.I<GoogleTokenRepository>().ensureTokenPresent(
        appBloc: appBloc,
        backStream: backStream,
      );
      GetIt.I<OpenWeatherTokenRepository>().ensureTokenPresent(
        appBloc: appBloc,
        backStream: backStream,
      );
      GetIt.I<HomeAssistantApiService>().ensureTokenPresent(
        appBloc: appBloc,
        backStream: backStream,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocSelector<ViewConfigBloc, ViewConfigState, (int, int, bool)>(
          selector: (state) =>
              (state.currentPageIndex, state.pages.length, state.snapToGrid),
          builder: (context, data) {
            final (pageIndex, totalPages, snapEnabled) = data;
            return _ViewConfigAppBar(
              loc: loc,
              pageIndex: pageIndex,
              totalPages: totalPages,
              snapEnabled: snapEnabled,
              onAddPage: () =>
                  context.read<ViewConfigBloc>().add(AddPageEvent()),
              onDeletePage: () => _showDeletePageDialog(context, loc),
            );
          },
        ),
      ),
      bottomNavigationBar:
          BlocSelector<
            ViewConfigBloc,
            ViewConfigState,
            (List<ViewConfigPage>, int)
          >(
            selector: (state) => (state.pages, state.currentPageIndex),
            builder: (context, data) {
              final (pages, currentIndex) = data;
              return pages.length > 1
                  ? _PageNavigationBar(
                      loc: loc,
                      pages: pages,
                      currentIndex: currentIndex,
                      onSwitchPage: (idx) => context.read<ViewConfigBloc>().add(
                        SwitchPageEvent(idx),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
      body:
          BlocSelector<
            ViewConfigBloc,
            ViewConfigState,
            (List<ViewConfigItem>, bool)
          >(
            selector: (state) => (state.currentPage.items, state.snapToGrid),
            builder: (context, data) {
              final (items, snapEnabled) = data;
              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.1,
                maxScale: 3.0,
                child: Container(
                  width: 1920,
                  height: 1080,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: CustomPaint(
                      painter: GridPainter(context),
                      child: CommonCanvas<ViewConfigItem>(
                        items: items,
                        gridSize: 10.0,
                        snapEnabled: snapEnabled,
                        canResize: true,

                        getX: (item) => item.position.dx,
                        getY: (item) => item.position.dy,
                        getWidth: (item) => item.size.width,
                        getHeight: (item) => item.size.height,

                        builder: (item) => WidgetTypeRegistry.get(item.widgetType)!
                            .buildChild(item),

                        onUpdateItem: (item, pos, size) {
                          context.read<ViewConfigBloc>().add(
                            UpdateItemEvent(
                                item.copyWith(position: pos, size: size)),
                          );
                        },

                        onLongPressCanvas: (localPos) =>
                            _handleViewConfigAdd(context, localPos),
                        onLongPressItem: (item) =>
                            _handleViewConfigEdit(context, item),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _handleViewConfigAdd(BuildContext context, Offset localPos) async {
    final selectedType = await showDialog<int>(
      context: context,
      builder: (_) => const WidgetTypeSelectionDialog(),
    );

    if (!context.mounted || selectedType == null) return;

    final typeDef = WidgetTypeRegistry.get(selectedType);
    if (typeDef == null) return;
    final properties = await typeDef.promptForProperties(context);

    if (!context.mounted || properties == null) return;

    context.read<ViewConfigBloc>().add(
      AddItemEvent(localPos, typeDef.defaultSize, selectedType, properties),
    );
  }

  void _handleViewConfigEdit(BuildContext context, ViewConfigItem item) async {
    final bloc = context.read<ViewConfigBloc>();
    final typeDef = WidgetTypeRegistry.get(item.widgetType);
    if (typeDef == null) return;

    final updatedProps = await typeDef.promptForProperties(
      context,
      initial: item.properties,
      onDelete: () {
        bloc.add(RemoveItemEvent(item));
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    if (!context.mounted || updatedProps == null) return;

    bloc.add(UpdateItemEvent(item.copyWith(properties: updatedProps)));
  }

  void _showDeletePageDialog(BuildContext context, AppLocalizations loc) {
    final bloc = context.read<ViewConfigBloc>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.deletePageTitle),
          content: Text(loc.deletePageContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                bloc.add(RemovePageEvent());
                Navigator.of(ctx).pop();
              },
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }
}

class _ViewConfigAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations loc;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onAddPage;
  final VoidCallback onDeletePage;
  final bool snapEnabled;

  const _ViewConfigAppBar({
    required this.loc,
    required this.pageIndex,
    required this.totalPages,
    required this.onAddPage,
    required this.onDeletePage,
    required this.snapEnabled,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static const List<IconData> _themeIcons = [
    Icons.light_mode,
    Icons.dark_mode,
    Icons.water,
    Icons.bolt,
  ];

  String _getThemeLabel(AppLocalizations loc, int index) {
    switch (index) {
      case 0:
        return loc.setupThemeLight;
      case 1:
        return loc.setupThemeDark;
      case 2:
        return loc.themeBlue;
      case 3:
        return loc.themeNeon;
      default:
        return loc.unknown;
    }
  }

  static const List<String> _languageCodes = ['en', 'de'];

  String _getLanguageName(AppLocalizations loc, String code) {
    switch (code) {
      case 'en':
        return loc.languageEnglish;
      case 'de':
        return loc.languageGerman;
      default:
        return loc.unknown;
    }
  }

  Future<void> _showMetaDataPicker(
    BuildContext context,
    int currentTheme,
    String currentLanguage,
  ) async {
    final bloc = context.read<ViewConfigBloc>();
    int selectedTheme = currentTheme;
    String selectedLanguage = currentLanguage;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(loc.viewSettingsTitle),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selection
                  Text(
                    loc.viewLanguageLabel,
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        icon: const Icon(Icons.expand_more, size: 20),
                        isDense: true,
                        borderRadius: BorderRadius.circular(16),
                        onChanged: (lang) {
                          if (lang != null) {
                            setDialogState(() => selectedLanguage = lang);
                          }
                        },
                        items: _languageCodes.map((code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(_getLanguageName(loc, code)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme Selection
                  Text(
                    loc.viewThemeLabel,
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_themeIcons.length, (i) {
                      final label = _getThemeLabel(loc, i);
                      final icon = _themeIcons[i];
                      final isSelected = selectedTheme == i;
                      return ChoiceChip(
                        avatar: Icon(icon, size: 18),
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) =>
                            setDialogState(() => selectedTheme = i),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(loc.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    bloc.add(SetThemeEvent(selectedTheme));
                    bloc.add(SetLanguageEvent(selectedLanguage));
                    Navigator.of(ctx).pop();
                  },
                  child: Text(loc.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewConfigState = context.watch<ViewConfigBloc>().state;
    final viewConfigPages = viewConfigState.pages;
    final selectedTheme = viewConfigState.selectedTheme;
    final selectedLanguage = viewConfigState.selectedLanguage;

    return AppBar(
      title: Text(loc.pageLabel(pageIndex + 1, totalPages)),
      actions: [
        IconButton(
          icon: Icon(Icons.upload),
          tooltip: loc.upload,
          onPressed: () => context.read<AppWebSocketBloc>().add(
            AppWebSocketSendViewRequest(viewConfigPages),
          ),
        ),

        // Metadata Button (Theme + Language)
        IconButton(
          icon: const Icon(Icons.display_settings),
          tooltip: loc.viewMetadataTooltip,
          onPressed: () =>
              _showMetaDataPicker(context, selectedTheme, selectedLanguage),
        ),

        IconButton(
          icon: Icon(snapEnabled ? Icons.grid_on : Icons.grid_off),
          tooltip: snapEnabled ? 'Disable Snapping' : 'Enable Snapping',
          onPressed: () =>
              context.read<ViewConfigBloc>().add(ToggleSnapEvent()),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: loc.addPageTooltip,
          onPressed: onAddPage,
        ),
        if (totalPages > 1)
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: loc.deletePageTooltip,
            onPressed: onDeletePage,
          ),
      ],
    );
  }
}

class _PageNavigationBar extends StatelessWidget {
  final AppLocalizations loc;
  final List<ViewConfigPage> pages;
  final int currentIndex;
  final ValueChanged<int> onSwitchPage;

  const _PageNavigationBar({
    required this.loc,
    required this.pages,
    required this.currentIndex,
    required this.onSwitchPage,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onSwitchPage,
      items: List.generate(
        pages.length,
        (i) => BottomNavigationBarItem(
          icon: const Icon(Icons.pages),
          label: loc.pageTabLabel(i + 1),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final BuildContext context;
  GridPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 24) {
      for (double j = 0; j < size.height; j += 24) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Widget Category definitions ───────────────────────────────────────────

enum _WidgetCategory {
  all,
  general,
  weather,
  calendar,
  transit,
  smartHome,
  entertainment,
}

/// Maps each registered typeId to a category.
const Map<int, _WidgetCategory> _widgetCategories = {
  // General
  0: _WidgetCategory.general, // Text Label
  1: _WidgetCategory.general, // Image
  18: _WidgetCategory.general, // System Usage
  WidgetIds.digitalClock: _WidgetCategory.general, // Digital Clock
  // Weather
  2: _WidgetCategory.weather, // Current Weather
  3: _WidgetCategory.weather, // Forecast
  // Calendar
  4: _WidgetCategory.calendar, // Calendar Upcoming
  17: _WidgetCategory.calendar, // Calendar 2 Days
  // Smart Home
  5: _WidgetCategory.smartHome, // HA Single
  6: _WidgetCategory.smartHome, // HA Multi
  // Entertainment
  7: _WidgetCategory.entertainment, // Cat Image
  8: _WidgetCategory.entertainment, // Cat GIF
  WidgetIds.randomDog: _WidgetCategory.entertainment, // Random Dog
  9: _WidgetCategory.entertainment, // Pokémon of the Day
  10: _WidgetCategory.entertainment, // Random Pokémon
  WidgetIds.randomCompliment: _WidgetCategory.entertainment, // Random Compliment
  WidgetIds.randomInsult: _WidgetCategory.entertainment, // Random Insult
  15: _WidgetCategory.entertainment, // Random Useless Fact
  // Transit
  16: _WidgetCategory.transit, // Bus Stop
};

// ─── New Dialog-based widget picker ─────────────────────────────────────────

class WidgetTypeSelectionDialog extends StatefulWidget {
  const WidgetTypeSelectionDialog({super.key});

  @override
  State<WidgetTypeSelectionDialog> createState() =>
      _WidgetTypeSelectionDialogState();
}

class _WidgetTypeSelectionDialogState extends State<WidgetTypeSelectionDialog> {
  final _searchController = TextEditingController();
  _WidgetCategory _selectedCategory = _WidgetCategory.all;
  String _query = '';
  bool _showDeactivated = false;

  // Merged listenable: rebuilds the list whenever any token status changes.
  late final Listenable _tokenStatuses;

  bool _isTokenPresent(String? tokenId) {
    if (tokenId == null) return true;
    switch (tokenId) {
      case 'google':
        return GetIt.I<GoogleTokenRepository>().hasToken;
      case 'openweather':
        return GetIt.I<OpenWeatherTokenRepository>().hasToken;
      case 'HomeAssistant':
        return GetIt.I<HomeAssistantApiService>().hasToken;
      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tokenStatuses = Listenable.merge([
      GetIt.I<GoogleTokenRepository>().status,
      GetIt.I<OpenWeatherTokenRepository>().status,
      GetIt.I<HomeAssistantApiService>().status,
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations loc, _WidgetCategory cat) {
    switch (cat) {
      case _WidgetCategory.all:
        return loc.categoryAll;
      case _WidgetCategory.general:
        return loc.categoryGeneral;
      case _WidgetCategory.weather:
        return loc.categoryWeather;
      case _WidgetCategory.calendar:
        return loc.categoryCalendar;
      case _WidgetCategory.transit:
        return loc.categoryTransit;
      case _WidgetCategory.smartHome:
        return loc.categorySmartHome;
      case _WidgetCategory.entertainment:
        return loc.categoryEntertainment;
    }
  }

  IconData _categoryIcon(_WidgetCategory cat) {
    switch (cat) {
      case _WidgetCategory.all:
        return Icons.widgets;
      case _WidgetCategory.general:
        return Icons.text_fields;
      case _WidgetCategory.weather:
        return Icons.wb_sunny;
      case _WidgetCategory.calendar:
        return Icons.calendar_month;
      case _WidgetCategory.transit:
        return Icons.directions_bus;
      case _WidgetCategory.smartHome:
        return Icons.home_outlined;
      case _WidgetCategory.entertainment:
        return Icons.celebration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title ──
              Text(
                loc.addWidget,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search bar ──
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: '${loc.categoryAll}…',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: "Toggle deactivated widgets",
                    child: IconButton(
                      icon: Icon(
                        _showDeactivated ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _showDeactivated = !_showDeactivated),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Category chips ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _WidgetCategory.values.map((cat) {
                    final selected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        avatar: Icon(
                          _categoryIcon(cat),
                          size: 16,
                          color: selected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        label: Text(_categoryLabel(loc, cat)),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // ── Widget list ──
              Flexible(
                child: ListenableBuilder(
                  listenable: _tokenStatuses,
                  builder: (context, _) {
                    final all = WidgetTypeRegistry.getAvailableTypes(context);
                    final filtered = all.entries.where((e) {
                      final typeId = e.key;
                      final typeDef = WidgetTypeRegistry.get(typeId);
                      final hasToken = _isTokenPresent(typeDef?.requiredTokenId);
                      if (!_showDeactivated && !hasToken) return false;
                      final cat = _widgetCategories[typeId] ?? _WidgetCategory.general;
                      final matchesCategory =
                          _selectedCategory == _WidgetCategory.all || cat == _selectedCategory;
                      final matchesSearch =
                          _query.isEmpty ||
                          e.value.toLowerCase().contains(_query.toLowerCase());
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No widgets found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final typeId = filtered[index].key;
                        final name = filtered[index].value;
                        final cat =
                            _widgetCategories[typeId] ??
                            _WidgetCategory.general;
                        final typeDef = WidgetTypeRegistry.get(typeId);
                        final hasToken = _isTokenPresent(typeDef?.requiredTokenId);

                        final listTile = ListTile(
                          enabled: hasToken,
                          leading: CircleAvatar(
                            backgroundColor: hasToken
                                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                            child: Icon(
                              _categoryIcon(cat),
                              size: 20,
                              color: hasToken
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: hasToken ? null : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          subtitle: Text(
                            _categoryLabel(loc, cat),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Icon(
                            Icons.add_circle_outline,
                            color: hasToken
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          onTap: hasToken ? () => Navigator.of(context).pop(typeId) : null,
                        );

                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: hasToken
                              ? listTile
                              : Tooltip(
                                  message:
                                      "Please add the ${typeDef?.requiredTokenId} token as an admin to use this widget.",
                                  child: listTile,
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // ── Cancel button ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
