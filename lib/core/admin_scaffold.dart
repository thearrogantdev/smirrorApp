import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/session_context_service.dart';
import 'main_scaffold_navigation.dart';
import 'responsive.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'main_scaffold.dart';
import 'package:smirror_app/services/websocket_service.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final Set<String> _expandedGroups = {'config'};
  final _session = GetIt.I<SessionContextService>();
  late AppLocalizations _loc;
  late List<NavEntry> _fullTree;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context)!;
    _fullTree = NavigationConfig.getAdminItems(_loc);
  }

  void _toggleGroup(String id) {
    setState(() {
      if (_expandedGroups.contains(id)) {
        _expandedGroups.remove(id);
      } else {
        _expandedGroups.add(id);
      }
    });
  }

  List<NavEntry> _visibleTree() {
    return _fullTree.expand((entry) {
      if (entry is NavItem) {
        return (entry.visibleWhen?.call(_session) ?? true)
            ? [entry]
            : <NavEntry>[];
      }
      if (entry is NavSection) {
        final kids = entry.children
            .whereType<NavItem>()
            .where((c) => c.visibleWhen?.call(_session) ?? true)
            .toList();
        return kids.isEmpty
            ? <NavEntry>[]
            : [
                NavSection(
                  id: entry.id,
                  icon: entry.icon,
                  label: entry.label,
                  children: kids,
                ),
              ];
      }
      return [entry];
    }).toList();
  }

  List<RailVisualItem> _buildRailVisuals(List<NavEntry> tree) {
    final list = <RailVisualItem>[];
    for (final entry in tree) {
      if (entry is NavSection) {
        list.add(
          RailVisualItem(
            entry: entry,
            type: RailRowType.sectionHeader,
            expanded: _expandedGroups.contains(entry.id),
          ),
        );
        if (_expandedGroups.contains(entry.id)) {
          for (final child in entry.children) {
            list.add(RailVisualItem(entry: child, type: RailRowType.subItem));
          }
        }
      } else if (entry is NavItem) {
        list.add(RailVisualItem(entry: entry, type: RailRowType.topLevel));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final navTree = _visibleTree();
    final filteredRoutes = NavigationConfig.getFlatRoutes(navTree);

    return AutoTabsRouter(
      routes: filteredRoutes,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final compact = isMobile(context);
        final railItems = _buildRailVisuals(navTree);

        int selectedRailIndex = 0;
        final activeRoute =
            tabsRouter.activeIndex < filteredRoutes.length
                ? filteredRoutes[tabsRouter.activeIndex]
                : null;

        for (int i = 0; i < railItems.length; i++) {
          final ri = railItems[i];
          if (ri.entry is NavItem &&
              (ri.entry as NavItem).route == activeRoute) {
            selectedRailIndex = i;
            break;
          }
        }

        return Scaffold(
          appBar: compact ? _buildMobileAppBar(context) : null,
          drawer: compact
              ? _buildDrawer(context, navTree, tabsRouter, filteredRoutes)
              : null,
          body: Row(
            children: [
              if (!compact)
                _buildDesktopRail(
                  context,
                  railItems,
                  selectedRailIndex,
                  tabsRouter,
                  filteredRoutes,
                ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopRail(
    BuildContext context,
    List<RailVisualItem> railItems,
    int selectedIndex,
    TabsRouter tabsRouter,
    List<PageRouteInfo> currentRoutes,
  ) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UserProfileHeader(),
            const Divider(height: 1),
            Expanded(
              child: NavigationRail(
                minExtendedWidth: 260,
                backgroundColor: Colors.transparent,
                extended: true,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  final selectedItem = railItems[index];
                  if (selectedItem.type == RailRowType.sectionHeader) {
                    _toggleGroup((selectedItem.entry as NavSection).id);
                  } else if (selectedItem.entry is NavItem) {
                    final route = (selectedItem.entry as NavItem).route;
                    final routerIndex = currentRoutes.indexOf(route);
                    if (routerIndex != -1) {
                      tabsRouter.setActiveIndex(routerIndex);
                    }
                  }
                },
                labelType: NavigationRailLabelType.none,
                destinations: railItems.asMap().entries.map((e) {
                  return NavigationRailDestination(
                    icon: RailItemWidget(
                      item: e.value,
                      isSelected: e.key == selectedIndex,
                    ),
                    label: Text(
                      e.value.entry.label(_loc),
                      style: e.value.type == RailRowType.subItem
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.titleSmall,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  GetIt.I<WebSocketService>().logout();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Text(
                        _loc.logout,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            const RailStatus(),
          ],
        ),
      ),
    );
  }

  AppBar _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: Text(_loc.appTitle),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Drawer _buildDrawer(
    BuildContext context,
    List<NavEntry> tree,
    TabsRouter tabsRouter,
    List<PageRouteInfo> currentRoutes,
  ) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SafeArea(bottom: false, child: UserProfileHeader()),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tree.map((e) {
                if (e is NavSection) {
                  return ExpansionTile(
                    leading: Icon(e.icon),
                    title: Text(e.label(_loc)),
                    initiallyExpanded: _expandedGroups.contains(e.id),
                    onExpansionChanged: (_) => _toggleGroup(e.id),
                    children: e.children.map<Widget>((child) {
                      if (child is NavItem) {
                        final idx = currentRoutes.indexOf(child.route);
                        return ListTile(
                          leading: Icon(child.icon),
                          title: Text(child.label(_loc)),
                          selected: tabsRouter.activeIndex == idx,
                          onTap: () {
                            if (idx != -1) {
                              tabsRouter.setActiveIndex(idx);
                            }
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.only(
                            left: 32,
                            right: 16,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  );
                } else if (e is NavItem) {
                  final idx = currentRoutes.indexOf(e.route);
                  return ListTile(
                    leading: Icon(e.icon),
                    title: Text(e.label(_loc)),
                    selected: tabsRouter.activeIndex == idx,
                    onTap: () {
                      if (idx != -1) {
                        tabsRouter.setActiveIndex(idx);
                      }
                      Navigator.pop(context);
                    },
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                GetIt.I<WebSocketService>().logout();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Text(
                      _loc.logout,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          const SafeArea(top: false, child: RailStatus()),
        ],
      ),
    );
  }
}
