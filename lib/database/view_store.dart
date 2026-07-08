import 'dart:io';
import 'dart:ui' show Offset, Size;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/widget_type_registry.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/database/database.dart';
import 'package:smirror_app/database/device.dart';
import 'package:smirror_app/database/view_config.dart';
import 'package:smirror_app/database/view_config_property_mapper.dart';

@singleton
class ViewStore {
  AppDatabase get _db => GetIt.I<AppDatabase>();
  AppDatabase get _globalDb => GetIt.I<AppDatabase>(instanceName: 'global');
  final List<DeviceEntity> _devices = [];
  final List<UserEntity> _users = [];
  final List<ViewEntity> _views = [];

  int? _currentDeviceId;
  int? get currentDeviceId => _currentDeviceId;

  /// Sets the active device context for this store.
  void setCurrentDevice(int deviceId) {
    _currentDeviceId = deviceId;
  }

  /// Initializes the Drift store cache. Call once at app startup.
  @postConstruct
  Future<void> init() async {
    // 1. Load all devices from global database
    final dbDevices = await _globalDb.select(_globalDb.devices).get();
    _devices.clear();
    for (final d in dbDevices) {
      _devices.add(DeviceEntity(
        id: d.id,
        connectionId: d.connectionId,
        name: d.name,
        ip: d.ip,
        port: d.port,
      ));
    }
  }

  /// Switches database to device connection database
  Future<void> switchToDevice(DeviceEntity device) async {
    final currentDb = GetIt.I<AppDatabase>();
    final globalDb = GetIt.I<AppDatabase>(instanceName: 'global');

    // Unregister current database so we can register the new singleton
    if (GetIt.I.isRegistered<AppDatabase>()) {
      await GetIt.I.unregister<AppDatabase>();
    }

    // Close previous device connection if it's open and distinct from global
    if (currentDb != globalDb) {
      await currentDb.close();
    }

    // Initialize new device database
    final newDb = AppDatabase('smirror_${device.connectionId}');
    GetIt.I.registerSingleton<AppDatabase>(newDb);

    _currentDeviceId = device.id;

    // Ensure the device entity is replicated in this device database for foreign keys
    await newDb.into(newDb.devices).insertOnConflictUpdate(DevicesCompanion(
          id: Value(device.id),
          connectionId: Value(device.connectionId),
          name: Value(device.name),
          ip: Value(device.ip),
          port: Value(device.port),
        ));

    await loadDeviceData();
  }

  /// Switches database back to global database
  Future<void> switchToGlobal() async {
    final currentDb = GetIt.I<AppDatabase>();
    final globalDb = GetIt.I<AppDatabase>(instanceName: 'global');

    if (currentDb != globalDb) {
      await currentDb.close();
      GetIt.I.unregister<AppDatabase>();
      GetIt.I.registerSingleton<AppDatabase>(globalDb);
    }

    _currentDeviceId = null;
    _users.clear();
    _views.clear();
  }

  /// Loads users and views data from the current device-specific database.
  Future<void> loadDeviceData() async {
    _users.clear();
    _views.clear();

    // 2. Load all users from device-specific database
    final dbUsers = await _db.select(_db.users).get();
    for (final u in dbUsers) {
      final uEntity = UserEntity(id: u.id, username: u.username);
      final dev = _devices.where((d) => d.id == u.deviceId).firstOrNull;
      if (dev != null) {
        uEntity.device.target = dev;
        uEntity.device.targetId = dev.id;
      }
      _users.add(uEntity);
    }

    // 3. Load all views from device-specific database
    final dbViews = await _db.select(_db.views).get();
    for (final v in dbViews) {
      final vEntity = ViewEntity(
        id: v.id,
        userId: v.userId,
        timestamp: v.timestamp,
        language: v.language,
        theme: v.theme,
        backendId: v.backendId,
        dirty: v.dirty,
      );

      // Load pages for this view
      final dbPages = await (_db.select(_db.pages)..where((t) => t.viewId.equals(v.id))).get();
      for (final p in dbPages) {
        final pEntity = PageEntity(id: p.id, number: p.number);
        pEntity.view.target = vEntity;
        pEntity.view.targetId = vEntity.id;
        vEntity.pages.add(pEntity);

        // Load widgets for this page
        final dbWidgets = await (_db.select(_db.widgets)..where((t) => t.pageId.equals(p.id))).get();
        for (final w in dbWidgets) {
          final wEntity = WidgetEntity(
            id: w.id,
            widgetId: w.widgetId,
            xPos: w.xPos,
            yPos: w.yPos,
            width: w.width,
            height: w.height,
          );
          wEntity.page.target = pEntity;
          wEntity.page.targetId = pEntity.id;
          pEntity.widgets.add(wEntity);

          // Load properties for this widget
          final dbProps = await (_db.select(_db.widgetProperties)..where((t) => t.widgetId.equals(w.id))).get();
          for (final prop in dbProps) {
            final propEntity = WidgetPropertyEntity(
              id: prop.id,
              keyId: prop.keyId,
              type: prop.type,
            );
            propEntity.widget.target = wEntity;
            propEntity.widget.targetId = wEntity.id;
            wEntity.properties.add(propEntity);

            // Load string values
            final dbStrings = await (_db.select(_db.widgetPropertyStrings)..where((t) => t.propertyId.equals(prop.id))).get();
            for (final s in dbStrings) {
              final sEntity = WidgetPropertyStringEntity(id: s.id, value: s.value);
              sEntity.property.target = propEntity;
              sEntity.property.targetId = propEntity.id;
              propEntity.stringValues.add(sEntity);
            }

            // Load int values
            final dbInts = await (_db.select(_db.widgetPropertyInts)..where((t) => t.propertyId.equals(prop.id))).get();
            for (final i in dbInts) {
              final iEntity = WidgetPropertyIntEntity(id: i.id, value: i.value);
              iEntity.property.target = propEntity;
              iEntity.property.targetId = propEntity.id;
              propEntity.intValues.add(iEntity);
            }

            // Load float values
            final dbFloats = await (_db.select(_db.widgetPropertyFloats)..where((t) => t.propertyId.equals(prop.id))).get();
            for (final f in dbFloats) {
              final fEntity = WidgetPropertyFloatEntity(id: f.id, value: f.value);
              fEntity.property.target = propEntity;
              fEntity.property.targetId = propEntity.id;
              propEntity.floatValues.add(fEntity);
            }

            // Load bool values
            final dbBools = await (_db.select(_db.widgetPropertyBools)..where((t) => t.propertyId.equals(prop.id))).get();
            for (final b in dbBools) {
              final bEntity = WidgetPropertyBoolEntity(id: b.id, value: b.value);
              bEntity.property.target = propEntity;
              bEntity.property.targetId = propEntity.id;
              propEntity.boolValues.add(bEntity);
            }

            // Load raw bytes
            final dbBytes = await (_db.select(_db.widgetPropertyRawBytesList)..where((t) => t.propertyId.equals(prop.id))).get();
            for (final r in dbBytes) {
              final rEntity = WidgetPropertyRawBytesEntity(id: r.id, value: r.value);
              rEntity.property.target = propEntity;
              rEntity.property.targetId = propEntity.id;
              propEntity.rawBytes.add(rEntity);
            }
          }
        }
      }
      _views.add(vEntity);
    }
  }

  Future<void> _deleteDeviceDatabaseFile(String connectionId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final prefixes = [
        'smirror_$connectionId.sqlite',
        'smirror_$connectionId.sqlite-journal',
        'smirror_$connectionId.sqlite-shm',
        'smirror_$connectionId.sqlite-wal'
      ];
      for (final prefix in prefixes) {
        final dbFile = File(p.join(dir.path, prefix));
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  /// Returns the [ViewEntity] for [userId], or null if none exists yet.
  ViewEntity? getViewForUser(int userId) {
    return getViewsForUser(userId).firstOrNull;
  }

  /// Stamps the view with [timestamp] after a successful send to the backend.
  void updateViewTimestamp(int viewId, int timestamp) {
    final view = _views.where((v) => v.id == viewId).firstOrNull;
    if (view == null) return;
    view.timestamp = timestamp;
    view.dirty = false;

    _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
          id: Value(view.id),
          userId: Value(view.userId),
          timestamp: Value(view.timestamp),
          language: Value(view.language),
          theme: Value(view.theme),
          backendId: Value(view.backendId),
          dirty: Value(view.dirty),
        ));
  }

  /// Returns the stored theme index for [viewId], or 0 if none.
  int getThemeForView(int viewId) {
    return _views.where((v) => v.id == viewId).firstOrNull?.theme ?? 0;
  }

  /// Persists [theme] for [viewId].
  void saveThemeForView(int viewId, int theme, {bool setDirty = true}) {
    final view = _views.where((v) => v.id == viewId).firstOrNull;
    if (view == null) return;
    view.theme = theme;
    if (setDirty) {
      view.dirty = true;
    }

    _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
          id: Value(view.id),
          userId: Value(view.userId),
          timestamp: Value(view.timestamp),
          language: Value(view.language),
          theme: Value(view.theme),
          backendId: Value(view.backendId),
          dirty: Value(view.dirty),
        ));
  }

  /// Returns the stored language code for [viewId], or 'en' if none.
  String getLanguageForView(int viewId) {
    return _views.where((v) => v.id == viewId).firstOrNull?.language ?? 'en';
  }

  /// Persists [language] for [viewId].
  void saveLanguageForView(int viewId, String language, {bool setDirty = true}) {
    final view = _views.where((v) => v.id == viewId).firstOrNull;
    if (view == null) return;
    view.language = language;
    if (setDirty) {
      view.dirty = true;
    }

    _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
          id: Value(view.id),
          userId: Value(view.userId),
          timestamp: Value(view.timestamp),
          language: Value(view.language),
          theme: Value(view.theme),
          backendId: Value(view.backendId),
          dirty: Value(view.dirty),
        ));
  }

  bool checkTimestamp(int userId, int timestamp) {
    if (userId == 0) {
      return false; // the user is not set this should never happen
    }
    final existingViews = getViewsForUser(userId);
    if (existingViews.isEmpty) return true;
    return existingViews.first.timestamp < timestamp;
  }

  Future<List<int>> syncViewFromBackend(
    String username,
    List<ViewConfigPage> pages, {
    required int timestamp,
    required String language,
    int theme = 0,
    required int deviceId,
  }) async {
    final userId = getOrCreateUserByName(username, deviceId);
    final existingViews = getViewsForUser(userId);
    final ViewEntity view;

    if (existingViews.isNotEmpty) {
      view = existingViews.first;
      if (timestamp <= view.timestamp) return [];
      view.timestamp = timestamp;
      view.language = language;
      view.theme = theme;
      view.dirty = false;
    } else {
      int nextId = 1;
      if (_views.isNotEmpty) {
        nextId = _views.map((v) => v.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      view = ViewEntity(
        id: nextId,
        userId: userId,
        timestamp: timestamp,
        language: language,
        theme: theme,
        dirty: false,
      );
      _views.add(view);
    }

    await _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
          id: Value(view.id),
          userId: Value(view.userId),
          timestamp: Value(view.timestamp),
          language: Value(view.language),
          theme: Value(view.theme),
          backendId: Value(view.backendId),
          dirty: Value(view.dirty),
        ));

    await savePagesForView(view.id, pages, setDirty: false);

    // Collect all binary IDs referenced in the incoming pages
    final binaryIds = <int>[];
    for (final page in pages) {
      for (final item in page.items) {
        if (item.widgetType != WidgetIds.image) continue;
        final prop = item.properties.where((p) => p.key == GeneralIds.binary).firstOrNull;
        final id = prop?.intValue;
        if (id != null && id != 0) binaryIds.add(id);
      }
    }
    return binaryIds;
  }

  int getUserIdByName(String username, int deviceId) {
    final found = _users.where((u) => u.username == username && u.device.targetId == deviceId).firstOrNull;
    return found?.id ?? 0;
  }

  /// Updates the local binary path for all widgets that reference [binaryId]
  /// via [GeneralIds.binary]. Called after a binary is received from the backend.
  Future<void> updateBinaryPath(int binaryId, String localPath) async {
    // 1. Find all int properties with keyId == GeneralIds.binary and value == binaryId
    final matchedProperties = <WidgetPropertyEntity>[];
    for (final view in _views) {
      for (final page in view.pages) {
        for (final widget in page.widgets) {
          for (final prop in widget.properties) {
            if (prop.keyId == GeneralIds.binary) {
              final intVal = prop.intValues.firstOrNull;
              if (intVal != null && intVal.value == binaryId) {
                matchedProperties.add(prop);
              }
            }
          }
        }
      }
    }

    // 2. For each matched widget, find or create GeneralIds.binaryPath
    for (final prop in matchedProperties) {
      final widgetEntity = prop.widget.target;
      if (widgetEntity == null) continue;

      final existingPathProp = widgetEntity.properties.where((p) => p.keyId == GeneralIds.binaryPath).firstOrNull;

      if (existingPathProp != null) {
        final stringVal = existingPathProp.stringValues.firstOrNull;
        if (stringVal != null) {
          stringVal.value = localPath;
          await (_db.update(_db.widgetPropertyStrings)..where((t) => t.id.equals(stringVal.id)))
              .write(WidgetPropertyStringsCompanion(value: Value(localPath)));
        } else {
          final v = WidgetPropertyStringEntity(value: localPath);
          v.property.target = existingPathProp;
          v.property.targetId = existingPathProp.id;
          existingPathProp.stringValues.add(v);
          final sId = await _db.into(_db.widgetPropertyStrings).insert(
                WidgetPropertyStringsCompanion.insert(propertyId: existingPathProp.id, value: localPath),
              );
          v.id = sId;
        }
      } else {
        // Create the property
        final pathProp = WidgetPropertyEntity(
          keyId: GeneralIds.binaryPath,
          type: ViewConfigPropertyType.string.index,
        )
          ..widget.target = widgetEntity
          ..widget.targetId = widgetEntity.id;

        final propId = await _db.into(_db.widgetProperties).insert(
              WidgetPropertiesCompanion.insert(
                keyId: GeneralIds.binaryPath,
                type: ViewConfigPropertyType.string.index,
                widgetId: widgetEntity.id,
              ),
            );
        pathProp.id = propId;
        widgetEntity.properties.add(pathProp);

        final v = WidgetPropertyStringEntity(value: localPath);
        v.property.target = pathProp;
        v.property.targetId = propId;
        pathProp.stringValues.add(v);

        final sId = await _db.into(_db.widgetPropertyStrings).insert(
              WidgetPropertyStringsCompanion.insert(propertyId: propId, value: localPath),
            );
        v.id = sId;
      }
    }
  }

  /// Find a UserEntity by username and device or create one. Returns local userId.
  int getOrCreateUserByName(String username, int deviceId) {
    final found = _users.where((u) => u.username == username && u.device.targetId == deviceId).firstOrNull;
    if (found != null) return found.id;

    int nextId = 1;
    if (_users.isNotEmpty) {
      nextId = _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
    }

    final newUser = UserEntity(id: nextId, username: username);
    newUser.device.targetId = deviceId;
    final dev = _devices.where((d) => d.id == deviceId).firstOrNull;
    if (dev != null) {
      newUser.device.target = dev;
    }
    _users.add(newUser);

    _db.into(_db.users).insertOnConflictUpdate(UsersCompanion(
          id: Value(newUser.id),
          username: Value(newUser.username),
          deviceId: Value(newUser.device.targetId),
        ));

    return newUser.id;
  }

  // --- Device Management ---

  List<DeviceEntity> getAllDevices() => List<DeviceEntity>.from(_devices);

  int putDevice(DeviceEntity device) {
    if (device.id == 0) {
      int nextId = 1;
      if (_devices.isNotEmpty) {
        nextId = _devices.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      device.id = nextId;
      _devices.add(device);
    } else {
      final idx = _devices.indexWhere((d) => d.id == device.id);
      if (idx != -1) {
        _devices[idx] = device;
      } else {
        _devices.add(device);
      }
    }

    _globalDb.into(_globalDb.devices).insertOnConflictUpdate(DevicesCompanion(
          id: Value(device.id),
          connectionId: Value(device.connectionId),
          name: Value(device.name),
          ip: Value(device.ip),
          port: Value(device.port),
        ));

    if (device.id == _currentDeviceId) {
      _db.into(_db.devices).insertOnConflictUpdate(DevicesCompanion(
            id: Value(device.id),
            connectionId: Value(device.connectionId),
            name: Value(device.name),
            ip: Value(device.ip),
            port: Value(device.port),
          ));
    }

    return device.id;
  }

  void removeDevice(int id) {
    final device = _devices.where((d) => d.id == id).firstOrNull;
    _devices.removeWhere((d) => d.id == id);
    _users.removeWhere((u) => u.device.targetId == id);
    _views.removeWhere((v) => !_users.any((u) => u.id == v.userId));

    _globalDb.transaction(() async {
      await (_globalDb.delete(_globalDb.devices)..where((t) => t.id.equals(id))).go();
    });

    if (device != null) {
      _deleteDeviceDatabaseFile(device.connectionId);
    }
  }

  DeviceEntity? getDeviceByConnectionId(String connectionId) {
    return _devices.where((d) => d.connectionId == connectionId).firstOrNull;
  }

  /// Convenience: return all views for a given local user id
  List<ViewEntity> getViewsForUser(int userId) {
    return _views.where((v) => v.userId == userId).toList();
  }

  /// Convenience: create a view for this local user and return viewId
  int createViewForUser(int userId) {
    int nextId = 1;
    if (_views.isNotEmpty) {
      nextId = _views.map((v) => v.id).reduce((a, b) => a > b ? a : b) + 1;
    }

    final view = ViewEntity(id: nextId, userId: userId, dirty: false);
    _views.add(view);

    _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
          id: Value(view.id),
          userId: Value(view.userId),
          timestamp: Value(view.timestamp),
          language: Value(view.language),
          theme: Value(view.theme),
          backendId: Value(view.backendId),
          dirty: Value(view.dirty),
        ));

    return view.id;
  }

  /// Delete a view and all its pages + widgets
  Future<void> deleteView(int viewId) async {
    _views.removeWhere((v) => v.id == viewId);

    await _db.transaction(() async {
      await (_db.delete(_db.views)..where((t) => t.id.equals(viewId))).go();
    });
  }

  /// Loads pages for the given viewId. Ensures at least one page exists.
  List<ViewConfigPage> loadPagesForView(int viewId) {
    final view = _views.where((v) => v.id == viewId).firstOrNull;
    if (view == null) return [];

    final pages = <ViewConfigPage>[];

    for (var page in view.pages) {
      final items = page.widgets.map((w) {
        final properties = ViewConfigPropertyMapper.fromEntities(w.properties);
        final item = ViewConfigItem(
          id: w.id,
          position: Offset(w.xPos, w.yPos),
          size: Size(w.width, w.height),
          widgetType: w.widgetId,
          properties: properties,
        );
        final actualSize = WidgetTypeRegistry.get(w.widgetId)?.getSize(item);
        if (actualSize != null && (actualSize.width != item.size.width || actualSize.height != item.size.height)) {
          return item.copyWith(size: actualSize);
        }
        return item;
      }).toList();

      pages.add(
        ViewConfigPage(id: page.id, pageNumber: page.number, items: items),
      );
    }

    if (pages.isEmpty) {
      // Create a default empty page if none exist
      final defaultPage = ViewConfigPage(
        id: DateTime.now().microsecondsSinceEpoch,
        pageNumber: 0,
        items: [],
      );
      pages.add(defaultPage);
      // Persist it
      savePagesForView(viewId, pages, setDirty: false);
    }

    return pages;
  }

  /// Persists a list of domain pages back to the store under the given view ID.
  Future<void> savePagesForView(int viewId, List<ViewConfigPage> pages, {bool setDirty = true}) async {
    final view = _views.where((v) => v.id == viewId).firstOrNull;
    if (view == null) return;

    // Clear in-memory pages
    view.pages.clear();
    if (setDirty) {
      view.dirty = true;
    }

    await _db.transaction(() async {
      // 1. Delete all existing pages referencing this view (cascades to widgets/properties)
      await (_db.delete(_db.pages)..where((t) => t.viewId.equals(viewId))).go();

      await _db.into(_db.views).insertOnConflictUpdate(ViewsCompanion(
            id: Value(view.id),
            userId: Value(view.userId),
            timestamp: Value(view.timestamp),
            language: Value(view.language),
            theme: Value(view.theme),
            backendId: Value(view.backendId),
            dirty: Value(view.dirty),
          ));

      // 2. Insert new pages, widgets, properties
      for (final page in pages) {
        final pageCompanion = PagesCompanion.insert(
          number: page.pageNumber,
          viewId: viewId,
        );
        final pageId = await _db.into(_db.pages).insert(pageCompanion);

        final pageEntity = PageEntity(id: pageId, number: page.pageNumber);
        pageEntity.view.target = view;
        pageEntity.view.targetId = viewId;
        view.pages.add(pageEntity);

        for (final item in page.items) {
          final widgetCompanion = WidgetsCompanion.insert(
            widgetId: item.widgetType,
            xPos: Value(item.position.dx),
            yPos: Value(item.position.dy),
            width: Value(item.size.width),
            height: Value(item.size.height),
            pageId: pageId,
          );
          final widgetId = await _db.into(_db.widgets).insert(widgetCompanion);

          final widgetEntity = WidgetEntity(
            id: widgetId,
            widgetId: item.widgetType,
            xPos: item.position.dx,
            yPos: item.position.dy,
            width: item.size.width,
            height: item.size.height,
          );
          widgetEntity.page.target = pageEntity;
          widgetEntity.page.targetId = pageId;
          pageEntity.widgets.add(widgetEntity);

          for (final viewProp in item.properties) {
            final propEntity = ViewConfigPropertyMapper.toEntity(viewProp, widgetId);

            final propCompanion = WidgetPropertiesCompanion.insert(
              keyId: propEntity.keyId,
              type: propEntity.type,
              widgetId: widgetId,
            );
            final propId = await _db.into(_db.widgetProperties).insert(propCompanion);
            propEntity.id = propId;
            widgetEntity.properties.add(propEntity);

            // Insert typed values
            for (final s in propEntity.stringValues) {
              s.property.targetId = propId;
              final sId = await _db.into(_db.widgetPropertyStrings).insert(
                    WidgetPropertyStringsCompanion.insert(propertyId: propId, value: s.value),
                  );
              s.id = sId;
            }
            for (final i in propEntity.intValues) {
              i.property.targetId = propId;
              final iId = await _db.into(_db.widgetPropertyInts).insert(
                    WidgetPropertyIntsCompanion.insert(propertyId: propId, value: i.value),
                  );
              i.id = iId;
            }
            for (final f in propEntity.floatValues) {
              f.property.targetId = propId;
              final fId = await _db.into(_db.widgetPropertyFloats).insert(
                    WidgetPropertyFloatsCompanion.insert(propertyId: propId, value: f.value),
                  );
              f.id = fId;
            }
            for (final b in propEntity.boolValues) {
              b.property.targetId = propId;
              final bId = await _db.into(_db.widgetPropertyBools).insert(
                    WidgetPropertyBoolsCompanion.insert(propertyId: propId, value: b.value),
                  );
              b.id = bId;
            }
            for (final r in propEntity.rawBytes) {
              r.property.targetId = propId;
              final rId = await _db.into(_db.widgetPropertyRawBytesList).insert(
                    WidgetPropertyRawBytesListCompanion.insert(propertyId: propId, value: r.value),
                  );
              r.id = rId;
            }
          }
        }
      }
    });
  }

  void dispose() {
    // AppDatabase manages its own lifecycle.
  }
}
