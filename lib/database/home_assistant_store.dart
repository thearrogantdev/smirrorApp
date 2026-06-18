import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart';
import 'package:smirror_app/database/database.dart';
import 'package:smirror_app/database/home_dashboard.dart';

@singleton
class HomeAssistantStore {
  AppDatabase get _db => GetIt.I<AppDatabase>();
  final List<Dashboard> _dashboards = [];

  final _dashboardsController = StreamController<List<Dashboard>>.broadcast();
  final _itemsControllers = <int, List<StreamController<List<DashboardItem>>>>{};

  void _notifyDashboards() {
    final sorted = List<Dashboard>.from(_dashboards)..sort((a, b) => a.order.compareTo(b.order));
    _dashboardsController.add(sorted);
  }

  void _notifyItems(int dashboardId) {
    final list = _itemsControllers[dashboardId];
    if (list != null && list.isNotEmpty) {
      final items = getItemsForDashboard(dashboardId);
      for (final controller in list) {
        controller.add(items);
      }
    }
  }

  @postConstruct
  Future<void> init() async {
    // We do not load dashboards here anymore because no active device is selected yet.
  }

  Future<void> switchToDevice() async {
    await loadDeviceData();
  }

  Future<void> switchToGlobal() async {
    _dashboards.clear();
    _notifyDashboards();
  }

  Future<void> loadDeviceData() async {
    _dashboards.clear();

    // 1. Load dashboards
    final dbDashboards = await _db.select(_db.dashboards).get();
    for (final d in dbDashboards) {
      final dEntity = Dashboard(
        id: d.id,
        backendId: d.backendId,
        name: d.name,
        order: d.order,
        timestamp: d.timestamp,
        backgroundImagePath: d.backgroundImagePath,
        backgroundImageId: d.backgroundImageId,
        width: d.width,
        height: d.height,
      );

      // Load items for this dashboard
      final dbItems = await (_db.select(_db.dashboardItems)..where((t) => t.dashboardId.equals(d.id))).get();
      for (final item in dbItems) {
        final itemEntity = DashboardItem(
          id: item.id,
          entityId: item.entityId,
          displayName: item.displayName,
          dbType: item.dbType,
          standardIconCodePoint: item.standardIconCodePoint,
          standardColorValue: item.standardColorValue,
          x: item.x,
          y: item.y,
          width: item.width,
          height: item.height,
          unitOverride: item.unitOverride,
        );
        itemEntity.dashboard.target = dEntity;
        itemEntity.dashboard.targetId = dEntity.id;
        dEntity.items.add(itemEntity);

        // Load thresholds for this item
        final dbThresholds = await (_db.select(_db.thresholdConfigs)..where((t) => t.itemId.equals(item.id))).get();
        for (final th in dbThresholds) {
          final thEntity = ThresholdConfig(
            id: th.id,
            triggerValue: th.triggerValue,
            iconCodePoint: th.iconCodePoint,
            colorValue: th.colorValue,
          );
          thEntity.item.target = itemEntity;
          thEntity.item.targetId = itemEntity.id;
          itemEntity.thresholds.add(thEntity);
        }
      }
      _dashboards.add(dEntity);
    }
    _notifyDashboards();
  }

  // --- Dashboards ---

  List<Dashboard> getAllDashboards() => List<Dashboard>.from(_dashboards);

  void clearDashboardItems(int localDashboardId) {
    final dashboard = _dashboards.where((d) => d.id == localDashboardId).firstOrNull;
    if (dashboard == null) return;

    dashboard.items.clear();

    _db.transaction(() async {
      await (_db.delete(_db.dashboardItems)..where((t) => t.dashboardId.equals(localDashboardId))).go();
    });

    _notifyItems(localDashboardId);
  }

  void saveDashboardWithItems(Dashboard dashboard, List<DashboardItem> items) {
    if (dashboard.id == 0 && dashboard.backendId != 0) {
      final existing = getDashboardByBackendId(dashboard.backendId);
      if (existing != null) {
        dashboard.id = existing.id;
      }
    }

    if (dashboard.id == 0) {
      int nextId = 1;
      if (_dashboards.isNotEmpty) {
        nextId = _dashboards.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      dashboard.id = nextId;
      _dashboards.add(dashboard);
    } else {
      final idx = _dashboards.indexWhere((d) => d.id == dashboard.id);
      if (idx != -1) {
        _dashboards[idx] = dashboard;
      } else {
        _dashboards.add(dashboard);
      }
    }

    // Sync in-memory items
    dashboard.items.clear();
    dashboard.items.addAll(items);

    _db.transaction(() async {
      // 1. Save dashboard
      await _db.into(_db.dashboards).insertOnConflictUpdate(DashboardsCompanion(
            id: Value(dashboard.id),
            backendId: Value(dashboard.backendId),
            name: Value(dashboard.name),
            order: Value(dashboard.order),
            timestamp: Value(dashboard.timestamp),
            backgroundImagePath: Value(dashboard.backgroundImagePath),
            backgroundImageId: Value(dashboard.backgroundImageId),
            width: Value(dashboard.width),
            height: Value(dashboard.height),
          ));

      // 2. Clear items
      await (_db.delete(_db.dashboardItems)..where((t) => t.dashboardId.equals(dashboard.id))).go();

      // 3. Insert items and thresholds
      for (final item in items) {
        item.dashboard.target = dashboard;
        item.dashboard.targetId = dashboard.id;

        final itemCompanion = DashboardItemsCompanion.insert(
          entityId: item.entityId,
          displayName: item.displayName,
          dbType: item.dbType,
          x: Value(item.x),
          y: Value(item.y),
          width: Value(item.width),
          height: Value(item.height),
          standardIconCodePoint: item.standardIconCodePoint,
          standardColorValue: item.standardColorValue,
          unitOverride: Value(item.unitOverride),
          dashboardId: dashboard.id,
        );
        final itemId = await _db.into(_db.dashboardItems).insert(itemCompanion);
        item.id = itemId;

        for (final threshold in item.thresholds) {
          threshold.item.target = item;
          threshold.item.targetId = itemId;

          final thresholdCompanion = ThresholdConfigsCompanion.insert(
            triggerValue: threshold.triggerValue,
            iconCodePoint: threshold.iconCodePoint,
            colorValue: threshold.colorValue,
            itemId: itemId,
          );
          final thId = await _db.into(_db.thresholdConfigs).insert(thresholdCompanion);
          threshold.id = thId;
        }
      }
    });

    _notifyDashboards();
    _notifyItems(dashboard.id);
  }

  Dashboard? getDashboardByLocalId(int id) {
    return _dashboards.where((d) => d.id == id).firstOrNull;
  }

  Dashboard? getDashboardByBackendId(int backendId) {
    if (backendId == 0) return null;
    return _dashboards.where((d) => d.backendId == backendId).firstOrNull;
  }

  Dashboard getOrCreatePlaceholder(int backendId, [String? name]) {
    if (backendId == 0) {
      return Dashboard(name: name ?? "Invalid Dashboard", backendId: 0);
    }
    final existing = getDashboardByBackendId(backendId);
    if (existing != null) return existing;

    int nextId = 1;
    if (_dashboards.isNotEmpty) {
      nextId = _dashboards.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
    }

    final placeholder = Dashboard(
      id: nextId,
      name: name ?? "HA Dashboard: #$backendId",
      backendId: backendId,
      timestamp: 0,
    );
    _dashboards.add(placeholder);

    _db.into(_db.dashboards).insertOnConflictUpdate(DashboardsCompanion(
          id: Value(placeholder.id),
          backendId: Value(placeholder.backendId),
          name: Value(placeholder.name),
          order: Value(placeholder.order),
          timestamp: Value(placeholder.timestamp),
          backgroundImagePath: Value(placeholder.backgroundImagePath),
          backgroundImageId: Value(placeholder.backgroundImageId),
          width: Value(placeholder.width),
          height: Value(placeholder.height),
        ));

    _notifyDashboards();
    return placeholder;
  }

  Stream<List<Dashboard>> watchDashboards() {
    final controller = StreamController<List<Dashboard>>();

    // Emit initial sorted list
    final sorted = List<Dashboard>.from(_dashboards)..sort((a, b) => a.order.compareTo(b.order));
    controller.add(sorted);

    final sub = _dashboardsController.stream.listen((val) {
      controller.add(val);
    });

    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  int saveDashboard(Dashboard dashboard) {
    if (dashboard.id == 0) {
      int nextId = 1;
      if (_dashboards.isNotEmpty) {
        nextId = _dashboards.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      dashboard.id = nextId;
      _dashboards.add(dashboard);
    } else {
      final idx = _dashboards.indexWhere((d) => d.id == dashboard.id);
      if (idx != -1) {
        _dashboards[idx] = dashboard;
      } else {
        _dashboards.add(dashboard);
      }
    }

    _db.into(_db.dashboards).insertOnConflictUpdate(DashboardsCompanion(
          id: Value(dashboard.id),
          backendId: Value(dashboard.backendId),
          name: Value(dashboard.name),
          order: Value(dashboard.order),
          timestamp: Value(dashboard.timestamp),
          backgroundImagePath: Value(dashboard.backgroundImagePath),
          backgroundImageId: Value(dashboard.backgroundImageId),
          width: Value(dashboard.width),
          height: Value(dashboard.height),
        ));

    _notifyDashboards();
    return dashboard.id;
  }

  void deleteDashboard(int dashboardId) {
    _dashboards.removeWhere((d) => d.id == dashboardId);

    _db.transaction(() async {
      await (_db.delete(_db.dashboards)..where((t) => t.id.equals(dashboardId))).go();
    });

    _notifyDashboards();
    _notifyItems(dashboardId);
  }

  void updateDashboardTimestamp(int dashboardId, int timestamp) {
    final dashboard = _dashboards.where((d) => d.id == dashboardId).firstOrNull;
    if (dashboard == null) return;
    dashboard.timestamp = timestamp;

    _db.into(_db.dashboards).insertOnConflictUpdate(DashboardsCompanion(
          id: Value(dashboard.id),
          backendId: Value(dashboard.backendId),
          name: Value(dashboard.name),
          order: Value(dashboard.order),
          timestamp: Value(dashboard.timestamp),
          backgroundImagePath: Value(dashboard.backgroundImagePath),
          backgroundImageId: Value(dashboard.backgroundImageId),
          width: Value(dashboard.width),
          height: Value(dashboard.height),
        ));
  }

  int getDashboardTimestampByBackendId(int backendId) {
    if (backendId == 0) return 0;
    return getDashboardByBackendId(backendId)?.timestamp ?? 0;
  }

  // --- Dashboard Items ---

  int saveItem(DashboardItem item) {
    final dashboardId = item.dashboard.targetId;
    final dashboard = _dashboards.where((d) => d.id == dashboardId).firstOrNull;

    if (dashboard != null) {
      if (item.id == 0) {
        item.id = DateTime.now().microsecondsSinceEpoch;
        dashboard.items.add(item);
      } else {
        final idx = dashboard.items.indexWhere((i) => i.id == item.id);
        if (idx != -1) {
          dashboard.items[idx] = item;
        } else {
          dashboard.items.add(item);
        }
      }
    }

    _db.transaction(() async {
      if (item.id != 0) {
        await (_db.delete(_db.thresholdConfigs)..where((t) => t.itemId.equals(item.id))).go();
      }

      final itemCompanion = DashboardItemsCompanion.insert(
        id: Value(item.id),
        entityId: item.entityId,
        displayName: item.displayName,
        dbType: item.dbType,
        x: Value(item.x),
        y: Value(item.y),
        width: Value(item.width),
        height: Value(item.height),
        standardIconCodePoint: item.standardIconCodePoint,
        standardColorValue: item.standardColorValue,
        unitOverride: Value(item.unitOverride),
        dashboardId: dashboardId,
      );

      final itemId = await _db.into(_db.dashboardItems).insert(itemCompanion, mode: InsertMode.insertOrReplace);
      item.id = itemId;

      for (final threshold in item.thresholds) {
        threshold.item.target = item;
        threshold.item.targetId = itemId;

        final thresholdCompanion = ThresholdConfigsCompanion.insert(
          triggerValue: threshold.triggerValue,
          iconCodePoint: threshold.iconCodePoint,
          colorValue: threshold.colorValue,
          itemId: itemId,
        );
        final thId = await _db.into(_db.thresholdConfigs).insert(thresholdCompanion);
        threshold.id = thId;
      }
    });

    _notifyItems(dashboardId);
    return item.id;
  }

  void deleteItem(int id) {
    int? dashboardId;
    for (final d in _dashboards) {
      final item = d.items.where((i) => i.id == id).firstOrNull;
      if (item != null) {
        dashboardId = d.id;
        d.items.removeWhere((i) => i.id == id);
        break;
      }
    }

    _db.transaction(() async {
      await (_db.delete(_db.dashboardItems)..where((t) => t.id.equals(id))).go();
    });

    if (dashboardId != null) {
      _notifyItems(dashboardId);
    }
  }

  List<DashboardItem> getItemsForDashboard(int dashboardId) {
    final dashboard = _dashboards.where((d) => d.id == dashboardId).firstOrNull;
    if (dashboard == null) return [];
    return List<DashboardItem>.from(dashboard.items);
  }

  Stream<List<DashboardItem>> watchItemsForDashboard(int dashboardId) {
    final controller = StreamController<List<DashboardItem>>();

    // Emit initial
    controller.add(getItemsForDashboard(dashboardId));

    if (!_itemsControllers.containsKey(dashboardId)) {
      _itemsControllers[dashboardId] = [];
    }

    final subController = StreamController<List<DashboardItem>>.broadcast();
    _itemsControllers[dashboardId]!.add(subController);

    final sub = subController.stream.listen((val) {
      controller.add(val);
    });

    controller.onCancel = () {
      sub.cancel();
      _itemsControllers[dashboardId]?.remove(subController);
      subController.close();
      controller.close();
    };

    return controller.stream;
  }

  void dispose() {
    _dashboardsController.close();
    for (final list in _itemsControllers.values) {
      for (final controller in list) {
        controller.close();
      }
    }
  }
}
