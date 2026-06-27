import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/session_context_service.dart';
import '../router/app_router.gr.dart';

// --- Abstractions ---

/// Base class for all navigation entries
abstract class NavEntry {
  final IconData icon;
  final String Function(AppLocalizations) label;

  NavEntry({required this.icon, required this.label});
}

/// A generic group (like "Config") that expands/collapses
class NavSection extends NavEntry {
  final String id; // Unique ID for expansion state tracking
  final List<NavEntry> children;

  NavSection({
    required this.id,
    required super.icon,
    required super.label,
    required this.children,
  }); // Initialize id in initializer list
}

/// A specific screen (Leaf)
class NavItem extends NavEntry {
  final PageRouteInfo route;
  final bool Function(SessionContextService)? visibleWhen;

  NavItem({
    required super.icon,
    required super.label,
    required this.route,
    this.visibleWhen,
  });
}

// --- Configuration ---

class NavigationConfig {
  /// Define your structure here. It's easy to insert new items or groups.
  static List<NavEntry> getItems(AppLocalizations loc) => getUserItems(loc);

  static List<NavEntry> getUserItems(AppLocalizations loc) {
    return [
      NavItem(icon: Icons.home, label: (l) => l.home, route: const HomeRoute()),
      NavItem(
        icon: Icons.tune,
        label: (l) => l.navViewLayout,
        route: const ViewConfigRoute(),
      ),
      NavItem(
        icon: Icons.screenshot,
        label: (l) => l.screenshot,
        route: const FrameRoute(),
        visibleWhen: (s) => s.hasCamera && s.canViewLivecam,
      ),
      NavItem(
        icon: Icons.article,
        label: (l) => l.logs,
        route: const LogRoute(),
        visibleWhen: (s) => s.canReadLogs && s.hasLogs,
      ),
      NavItem(
        icon: Icons.fingerprint,
        label: (l) => l.biometrics,
        route: const BiometricsRoute(),
      ),
      NavItem(
        icon: Icons.settings,
        label: (l) => l.setup,
        route: const SetupRoute(),
      ),
    ];
  }

  static List<NavEntry> getAdminItems(AppLocalizations loc) {
    return [
      NavItem(
        icon: Icons.admin_panel_settings,
        label: (l) => l.admin,
        route: const AdminRoute(),
      ),
      NavItem(
        icon: Icons.tune,
        label: (l) => l.navViewLayout,
        route: const ViewConfigRoute(),
      ),
      NavItem(
        icon: Icons.dashboard,
        label: (l) => l.navHaDashboard,
        route: const HomeAssistantMapRoute(),
      ),
      NavItem(
        icon: Icons.article,
        label: (l) => l.logs,
        route: const LogRoute(),
        visibleWhen: (s) => s.canReadLogs && s.hasLogs,
      ),
      NavItem(
        icon: Icons.settings,
        label: (l) => l.setup,
        route: const SetupRoute(),
      ),
      NavItem(
        icon: Icons.screenshot,
        label: (l) => l.screenshot,
        route: const FrameRoute(),
        visibleWhen: (s) => s.hasCamera,
      ),
    ];
  }

  /// Helper to get a flat list of routes for AutoTabsRouter
  static List<PageRouteInfo> getFlatRoutes(List<NavEntry> entries) {
    final List<PageRouteInfo> routes = [];
    for (final entry in entries) {
      if (entry is NavItem) {
        routes.add(entry.route);
      } else if (entry is NavSection) {
        routes.addAll(getFlatRoutes(entry.children));
      }
    }
    return routes;
  }
}
