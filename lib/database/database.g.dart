// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
    'ip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, connectionId, name, ip, port];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final int id;
  final String connectionId;
  final String name;
  final String ip;
  final int port;
  const DeviceRow({
    required this.id,
    required this.connectionId,
    required this.name,
    required this.ip,
    required this.port,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['name'] = Variable<String>(name);
    map['ip'] = Variable<String>(ip);
    map['port'] = Variable<int>(port);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      name: Value(name),
      ip: Value(ip),
      port: Value(port),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<int>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      name: serializer.fromJson<String>(json['name']),
      ip: serializer.fromJson<String>(json['ip']),
      port: serializer.fromJson<int>(json['port']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'name': serializer.toJson<String>(name),
      'ip': serializer.toJson<String>(ip),
      'port': serializer.toJson<int>(port),
    };
  }

  DeviceRow copyWith({
    int? id,
    String? connectionId,
    String? name,
    String? ip,
    int? port,
  }) => DeviceRow(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    name: name ?? this.name,
    ip: ip ?? this.ip,
    port: port ?? this.port,
  );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      name: data.name.present ? data.name.value : this.name,
      ip: data.ip.present ? data.ip.value : this.ip,
      port: data.port.present ? data.port.value : this.port,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('ip: $ip, ')
          ..write('port: $port')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, connectionId, name, ip, port);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.name == this.name &&
          other.ip == this.ip &&
          other.port == this.port);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<int> id;
  final Value<String> connectionId;
  final Value<String> name;
  final Value<String> ip;
  final Value<int> port;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.ip = const Value.absent(),
    this.port = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String connectionId,
    required String name,
    required String ip,
    required int port,
  }) : connectionId = Value(connectionId),
       name = Value(name),
       ip = Value(ip),
       port = Value(port);
  static Insertable<DeviceRow> custom({
    Expression<int>? id,
    Expression<String>? connectionId,
    Expression<String>? name,
    Expression<String>? ip,
    Expression<int>? port,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (name != null) 'name': name,
      if (ip != null) 'ip': ip,
      if (port != null) 'port': port,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? connectionId,
    Value<String>? name,
    Value<String>? ip,
    Value<int>? port,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('ip: $ip, ')
          ..write('port: $port')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, deviceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {username, deviceId},
  ];
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String username;
  final int deviceId;
  const UserRow({
    required this.id,
    required this.username,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['device_id'] = Variable<int>(deviceId);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      deviceId: Value(deviceId),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'deviceId': serializer.toJson<int>(deviceId),
    };
  }

  UserRow copyWith({int? id, String? username, int? deviceId}) => UserRow(
    id: id ?? this.id,
    username: username ?? this.username,
    deviceId: deviceId ?? this.deviceId,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.deviceId == this.deviceId);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> username;
  final Value<int> deviceId;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.deviceId = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required int deviceId,
  }) : username = Value(username),
       deviceId = Value(deviceId);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<int>? deviceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<int>? deviceId,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }
}

class $ViewsTable extends Views with TableInfo<$ViewsTable, ViewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<int> theme = GeneratedColumn<int>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    backendId,
    userId,
    timestamp,
    language,
    theme,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'views';
  @override
  VerificationContext validateIntegrity(
    Insertable<ViewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ViewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ViewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theme'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $ViewsTable createAlias(String alias) {
    return $ViewsTable(attachedDatabase, alias);
  }
}

class ViewRow extends DataClass implements Insertable<ViewRow> {
  final int id;
  final int backendId;
  final int userId;
  final int timestamp;
  final String language;
  final int theme;
  final bool dirty;
  const ViewRow({
    required this.id,
    required this.backendId,
    required this.userId,
    required this.timestamp,
    required this.language,
    required this.theme,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['backend_id'] = Variable<int>(backendId);
    map['user_id'] = Variable<int>(userId);
    map['timestamp'] = Variable<int>(timestamp);
    map['language'] = Variable<String>(language);
    map['theme'] = Variable<int>(theme);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  ViewsCompanion toCompanion(bool nullToAbsent) {
    return ViewsCompanion(
      id: Value(id),
      backendId: Value(backendId),
      userId: Value(userId),
      timestamp: Value(timestamp),
      language: Value(language),
      theme: Value(theme),
      dirty: Value(dirty),
    );
  }

  factory ViewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ViewRow(
      id: serializer.fromJson<int>(json['id']),
      backendId: serializer.fromJson<int>(json['backendId']),
      userId: serializer.fromJson<int>(json['userId']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      language: serializer.fromJson<String>(json['language']),
      theme: serializer.fromJson<int>(json['theme']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'backendId': serializer.toJson<int>(backendId),
      'userId': serializer.toJson<int>(userId),
      'timestamp': serializer.toJson<int>(timestamp),
      'language': serializer.toJson<String>(language),
      'theme': serializer.toJson<int>(theme),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  ViewRow copyWith({
    int? id,
    int? backendId,
    int? userId,
    int? timestamp,
    String? language,
    int? theme,
    bool? dirty,
  }) => ViewRow(
    id: id ?? this.id,
    backendId: backendId ?? this.backendId,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
    language: language ?? this.language,
    theme: theme ?? this.theme,
    dirty: dirty ?? this.dirty,
  );
  ViewRow copyWithCompanion(ViewsCompanion data) {
    return ViewRow(
      id: data.id.present ? data.id.value : this.id,
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      language: data.language.present ? data.language.value : this.language,
      theme: data.theme.present ? data.theme.value : this.theme,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ViewRow(')
          ..write('id: $id, ')
          ..write('backendId: $backendId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('language: $language, ')
          ..write('theme: $theme, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, backendId, userId, timestamp, language, theme, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewRow &&
          other.id == this.id &&
          other.backendId == this.backendId &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.language == this.language &&
          other.theme == this.theme &&
          other.dirty == this.dirty);
}

class ViewsCompanion extends UpdateCompanion<ViewRow> {
  final Value<int> id;
  final Value<int> backendId;
  final Value<int> userId;
  final Value<int> timestamp;
  final Value<String> language;
  final Value<int> theme;
  final Value<bool> dirty;
  const ViewsCompanion({
    this.id = const Value.absent(),
    this.backendId = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.language = const Value.absent(),
    this.theme = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  ViewsCompanion.insert({
    this.id = const Value.absent(),
    this.backendId = const Value.absent(),
    required int userId,
    this.timestamp = const Value.absent(),
    this.language = const Value.absent(),
    this.theme = const Value.absent(),
    this.dirty = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<ViewRow> custom({
    Expression<int>? id,
    Expression<int>? backendId,
    Expression<int>? userId,
    Expression<int>? timestamp,
    Expression<String>? language,
    Expression<int>? theme,
    Expression<bool>? dirty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backendId != null) 'backend_id': backendId,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (language != null) 'language': language,
      if (theme != null) 'theme': theme,
      if (dirty != null) 'dirty': dirty,
    });
  }

  ViewsCompanion copyWith({
    Value<int>? id,
    Value<int>? backendId,
    Value<int>? userId,
    Value<int>? timestamp,
    Value<String>? language,
    Value<int>? theme,
    Value<bool>? dirty,
  }) {
    return ViewsCompanion(
      id: id ?? this.id,
      backendId: backendId ?? this.backendId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (theme.present) {
      map['theme'] = Variable<int>(theme.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViewsCompanion(')
          ..write('id: $id, ')
          ..write('backendId: $backendId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('language: $language, ')
          ..write('theme: $theme, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, PageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewIdMeta = const VerificationMeta('viewId');
  @override
  late final GeneratedColumn<int> viewId = GeneratedColumn<int>(
    'view_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, number, viewId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('view_id')) {
      context.handle(
        _viewIdMeta,
        viewId.isAcceptableOrUnknown(data['view_id']!, _viewIdMeta),
      );
    } else if (isInserting) {
      context.missing(_viewIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      viewId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_id'],
      )!,
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }
}

class PageRow extends DataClass implements Insertable<PageRow> {
  final int id;
  final int number;
  final int viewId;
  const PageRow({required this.id, required this.number, required this.viewId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    map['view_id'] = Variable<int>(viewId);
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      id: Value(id),
      number: Value(number),
      viewId: Value(viewId),
    );
  }

  factory PageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageRow(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      viewId: serializer.fromJson<int>(json['viewId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'viewId': serializer.toJson<int>(viewId),
    };
  }

  PageRow copyWith({int? id, int? number, int? viewId}) => PageRow(
    id: id ?? this.id,
    number: number ?? this.number,
    viewId: viewId ?? this.viewId,
  );
  PageRow copyWithCompanion(PagesCompanion data) {
    return PageRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      viewId: data.viewId.present ? data.viewId.value : this.viewId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('viewId: $viewId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, number, viewId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.viewId == this.viewId);
}

class PagesCompanion extends UpdateCompanion<PageRow> {
  final Value<int> id;
  final Value<int> number;
  final Value<int> viewId;
  const PagesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.viewId = const Value.absent(),
  });
  PagesCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required int viewId,
  }) : number = Value(number),
       viewId = Value(viewId);
  static Insertable<PageRow> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<int>? viewId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (viewId != null) 'view_id': viewId,
    });
  }

  PagesCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<int>? viewId,
  }) {
    return PagesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      viewId: viewId ?? this.viewId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (viewId.present) {
      map['view_id'] = Variable<int>(viewId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('viewId: $viewId')
          ..write(')'))
        .toString();
  }
}

class $WidgetsTable extends Widgets with TableInfo<$WidgetsTable, WidgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _widgetIdMeta = const VerificationMeta(
    'widgetId',
  );
  @override
  late final GeneratedColumn<int> widgetId = GeneratedColumn<int>(
    'widget_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xPosMeta = const VerificationMeta('xPos');
  @override
  late final GeneratedColumn<double> xPos = GeneratedColumn<double>(
    'x_pos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _yPosMeta = const VerificationMeta('yPos');
  @override
  late final GeneratedColumn<double> yPos = GeneratedColumn<double>(
    'y_pos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    widgetId,
    xPos,
    yPos,
    width,
    height,
    pageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('widget_id')) {
      context.handle(
        _widgetIdMeta,
        widgetId.isAcceptableOrUnknown(data['widget_id']!, _widgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_widgetIdMeta);
    }
    if (data.containsKey('x_pos')) {
      context.handle(
        _xPosMeta,
        xPos.isAcceptableOrUnknown(data['x_pos']!, _xPosMeta),
      );
    }
    if (data.containsKey('y_pos')) {
      context.handle(
        _yPosMeta,
        yPos.isAcceptableOrUnknown(data['y_pos']!, _yPosMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      widgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}widget_id'],
      )!,
      xPos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x_pos'],
      )!,
      yPos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y_pos'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
    );
  }

  @override
  $WidgetsTable createAlias(String alias) {
    return $WidgetsTable(attachedDatabase, alias);
  }
}

class WidgetRow extends DataClass implements Insertable<WidgetRow> {
  final int id;
  final int widgetId;
  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final int pageId;
  const WidgetRow({
    required this.id,
    required this.widgetId,
    required this.xPos,
    required this.yPos,
    required this.width,
    required this.height,
    required this.pageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['widget_id'] = Variable<int>(widgetId);
    map['x_pos'] = Variable<double>(xPos);
    map['y_pos'] = Variable<double>(yPos);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['page_id'] = Variable<int>(pageId);
    return map;
  }

  WidgetsCompanion toCompanion(bool nullToAbsent) {
    return WidgetsCompanion(
      id: Value(id),
      widgetId: Value(widgetId),
      xPos: Value(xPos),
      yPos: Value(yPos),
      width: Value(width),
      height: Value(height),
      pageId: Value(pageId),
    );
  }

  factory WidgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetRow(
      id: serializer.fromJson<int>(json['id']),
      widgetId: serializer.fromJson<int>(json['widgetId']),
      xPos: serializer.fromJson<double>(json['xPos']),
      yPos: serializer.fromJson<double>(json['yPos']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      pageId: serializer.fromJson<int>(json['pageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'widgetId': serializer.toJson<int>(widgetId),
      'xPos': serializer.toJson<double>(xPos),
      'yPos': serializer.toJson<double>(yPos),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'pageId': serializer.toJson<int>(pageId),
    };
  }

  WidgetRow copyWith({
    int? id,
    int? widgetId,
    double? xPos,
    double? yPos,
    double? width,
    double? height,
    int? pageId,
  }) => WidgetRow(
    id: id ?? this.id,
    widgetId: widgetId ?? this.widgetId,
    xPos: xPos ?? this.xPos,
    yPos: yPos ?? this.yPos,
    width: width ?? this.width,
    height: height ?? this.height,
    pageId: pageId ?? this.pageId,
  );
  WidgetRow copyWithCompanion(WidgetsCompanion data) {
    return WidgetRow(
      id: data.id.present ? data.id.value : this.id,
      widgetId: data.widgetId.present ? data.widgetId.value : this.widgetId,
      xPos: data.xPos.present ? data.xPos.value : this.xPos,
      yPos: data.yPos.present ? data.yPos.value : this.yPos,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetRow(')
          ..write('id: $id, ')
          ..write('widgetId: $widgetId, ')
          ..write('xPos: $xPos, ')
          ..write('yPos: $yPos, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pageId: $pageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, widgetId, xPos, yPos, width, height, pageId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetRow &&
          other.id == this.id &&
          other.widgetId == this.widgetId &&
          other.xPos == this.xPos &&
          other.yPos == this.yPos &&
          other.width == this.width &&
          other.height == this.height &&
          other.pageId == this.pageId);
}

class WidgetsCompanion extends UpdateCompanion<WidgetRow> {
  final Value<int> id;
  final Value<int> widgetId;
  final Value<double> xPos;
  final Value<double> yPos;
  final Value<double> width;
  final Value<double> height;
  final Value<int> pageId;
  const WidgetsCompanion({
    this.id = const Value.absent(),
    this.widgetId = const Value.absent(),
    this.xPos = const Value.absent(),
    this.yPos = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.pageId = const Value.absent(),
  });
  WidgetsCompanion.insert({
    this.id = const Value.absent(),
    required int widgetId,
    this.xPos = const Value.absent(),
    this.yPos = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int pageId,
  }) : widgetId = Value(widgetId),
       pageId = Value(pageId);
  static Insertable<WidgetRow> custom({
    Expression<int>? id,
    Expression<int>? widgetId,
    Expression<double>? xPos,
    Expression<double>? yPos,
    Expression<double>? width,
    Expression<double>? height,
    Expression<int>? pageId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (widgetId != null) 'widget_id': widgetId,
      if (xPos != null) 'x_pos': xPos,
      if (yPos != null) 'y_pos': yPos,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageId != null) 'page_id': pageId,
    });
  }

  WidgetsCompanion copyWith({
    Value<int>? id,
    Value<int>? widgetId,
    Value<double>? xPos,
    Value<double>? yPos,
    Value<double>? width,
    Value<double>? height,
    Value<int>? pageId,
  }) {
    return WidgetsCompanion(
      id: id ?? this.id,
      widgetId: widgetId ?? this.widgetId,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      width: width ?? this.width,
      height: height ?? this.height,
      pageId: pageId ?? this.pageId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (widgetId.present) {
      map['widget_id'] = Variable<int>(widgetId.value);
    }
    if (xPos.present) {
      map['x_pos'] = Variable<double>(xPos.value);
    }
    if (yPos.present) {
      map['y_pos'] = Variable<double>(yPos.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetsCompanion(')
          ..write('id: $id, ')
          ..write('widgetId: $widgetId, ')
          ..write('xPos: $xPos, ')
          ..write('yPos: $yPos, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pageId: $pageId')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertiesTable extends WidgetProperties
    with TableInfo<$WidgetPropertiesTable, WidgetPropertyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<int> keyId = GeneratedColumn<int>(
    'key_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widgetIdMeta = const VerificationMeta(
    'widgetId',
  );
  @override
  late final GeneratedColumn<int> widgetId = GeneratedColumn<int>(
    'widget_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, keyId, type, widgetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key_id')) {
      context.handle(
        _keyIdMeta,
        keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_keyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('widget_id')) {
      context.handle(
        _widgetIdMeta,
        widgetId.isAcceptableOrUnknown(data['widget_id']!, _widgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_widgetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      widgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}widget_id'],
      )!,
    );
  }

  @override
  $WidgetPropertiesTable createAlias(String alias) {
    return $WidgetPropertiesTable(attachedDatabase, alias);
  }
}

class WidgetPropertyRow extends DataClass
    implements Insertable<WidgetPropertyRow> {
  final int id;
  final int keyId;
  final int type;
  final int widgetId;
  const WidgetPropertyRow({
    required this.id,
    required this.keyId,
    required this.type,
    required this.widgetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key_id'] = Variable<int>(keyId);
    map['type'] = Variable<int>(type);
    map['widget_id'] = Variable<int>(widgetId);
    return map;
  }

  WidgetPropertiesCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertiesCompanion(
      id: Value(id),
      keyId: Value(keyId),
      type: Value(type),
      widgetId: Value(widgetId),
    );
  }

  factory WidgetPropertyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyRow(
      id: serializer.fromJson<int>(json['id']),
      keyId: serializer.fromJson<int>(json['keyId']),
      type: serializer.fromJson<int>(json['type']),
      widgetId: serializer.fromJson<int>(json['widgetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'keyId': serializer.toJson<int>(keyId),
      'type': serializer.toJson<int>(type),
      'widgetId': serializer.toJson<int>(widgetId),
    };
  }

  WidgetPropertyRow copyWith({int? id, int? keyId, int? type, int? widgetId}) =>
      WidgetPropertyRow(
        id: id ?? this.id,
        keyId: keyId ?? this.keyId,
        type: type ?? this.type,
        widgetId: widgetId ?? this.widgetId,
      );
  WidgetPropertyRow copyWithCompanion(WidgetPropertiesCompanion data) {
    return WidgetPropertyRow(
      id: data.id.present ? data.id.value : this.id,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      type: data.type.present ? data.type.value : this.type,
      widgetId: data.widgetId.present ? data.widgetId.value : this.widgetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyRow(')
          ..write('id: $id, ')
          ..write('keyId: $keyId, ')
          ..write('type: $type, ')
          ..write('widgetId: $widgetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, keyId, type, widgetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyRow &&
          other.id == this.id &&
          other.keyId == this.keyId &&
          other.type == this.type &&
          other.widgetId == this.widgetId);
}

class WidgetPropertiesCompanion extends UpdateCompanion<WidgetPropertyRow> {
  final Value<int> id;
  final Value<int> keyId;
  final Value<int> type;
  final Value<int> widgetId;
  const WidgetPropertiesCompanion({
    this.id = const Value.absent(),
    this.keyId = const Value.absent(),
    this.type = const Value.absent(),
    this.widgetId = const Value.absent(),
  });
  WidgetPropertiesCompanion.insert({
    this.id = const Value.absent(),
    required int keyId,
    required int type,
    required int widgetId,
  }) : keyId = Value(keyId),
       type = Value(type),
       widgetId = Value(widgetId);
  static Insertable<WidgetPropertyRow> custom({
    Expression<int>? id,
    Expression<int>? keyId,
    Expression<int>? type,
    Expression<int>? widgetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyId != null) 'key_id': keyId,
      if (type != null) 'type': type,
      if (widgetId != null) 'widget_id': widgetId,
    });
  }

  WidgetPropertiesCompanion copyWith({
    Value<int>? id,
    Value<int>? keyId,
    Value<int>? type,
    Value<int>? widgetId,
  }) {
    return WidgetPropertiesCompanion(
      id: id ?? this.id,
      keyId: keyId ?? this.keyId,
      type: type ?? this.type,
      widgetId: widgetId ?? this.widgetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (keyId.present) {
      map['key_id'] = Variable<int>(keyId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (widgetId.present) {
      map['widget_id'] = Variable<int>(widgetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertiesCompanion(')
          ..write('id: $id, ')
          ..write('keyId: $keyId, ')
          ..write('type: $type, ')
          ..write('widgetId: $widgetId')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertyStringsTable extends WidgetPropertyStrings
    with TableInfo<$WidgetPropertyStringsTable, WidgetPropertyStringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertyStringsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, propertyId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_property_strings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyStringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyStringRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyStringRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $WidgetPropertyStringsTable createAlias(String alias) {
    return $WidgetPropertyStringsTable(attachedDatabase, alias);
  }
}

class WidgetPropertyStringRow extends DataClass
    implements Insertable<WidgetPropertyStringRow> {
  final int id;
  final int propertyId;
  final String value;
  const WidgetPropertyStringRow({
    required this.id,
    required this.propertyId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['property_id'] = Variable<int>(propertyId);
    map['value'] = Variable<String>(value);
    return map;
  }

  WidgetPropertyStringsCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertyStringsCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      value: Value(value),
    );
  }

  factory WidgetPropertyStringRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyStringRow(
      id: serializer.fromJson<int>(json['id']),
      propertyId: serializer.fromJson<int>(json['propertyId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'propertyId': serializer.toJson<int>(propertyId),
      'value': serializer.toJson<String>(value),
    };
  }

  WidgetPropertyStringRow copyWith({int? id, int? propertyId, String? value}) =>
      WidgetPropertyStringRow(
        id: id ?? this.id,
        propertyId: propertyId ?? this.propertyId,
        value: value ?? this.value,
      );
  WidgetPropertyStringRow copyWithCompanion(
    WidgetPropertyStringsCompanion data,
  ) {
    return WidgetPropertyStringRow(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyStringRow(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, propertyId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyStringRow &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          other.value == this.value);
}

class WidgetPropertyStringsCompanion
    extends UpdateCompanion<WidgetPropertyStringRow> {
  final Value<int> id;
  final Value<int> propertyId;
  final Value<String> value;
  const WidgetPropertyStringsCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.value = const Value.absent(),
  });
  WidgetPropertyStringsCompanion.insert({
    this.id = const Value.absent(),
    required int propertyId,
    required String value,
  }) : propertyId = Value(propertyId),
       value = Value(value);
  static Insertable<WidgetPropertyStringRow> custom({
    Expression<int>? id,
    Expression<int>? propertyId,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (value != null) 'value': value,
    });
  }

  WidgetPropertyStringsCompanion copyWith({
    Value<int>? id,
    Value<int>? propertyId,
    Value<String>? value,
  }) {
    return WidgetPropertyStringsCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyStringsCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertyIntsTable extends WidgetPropertyInts
    with TableInfo<$WidgetPropertyIntsTable, WidgetPropertyIntRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertyIntsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, propertyId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_property_ints';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyIntRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyIntRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyIntRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $WidgetPropertyIntsTable createAlias(String alias) {
    return $WidgetPropertyIntsTable(attachedDatabase, alias);
  }
}

class WidgetPropertyIntRow extends DataClass
    implements Insertable<WidgetPropertyIntRow> {
  final int id;
  final int propertyId;
  final int value;
  const WidgetPropertyIntRow({
    required this.id,
    required this.propertyId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['property_id'] = Variable<int>(propertyId);
    map['value'] = Variable<int>(value);
    return map;
  }

  WidgetPropertyIntsCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertyIntsCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      value: Value(value),
    );
  }

  factory WidgetPropertyIntRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyIntRow(
      id: serializer.fromJson<int>(json['id']),
      propertyId: serializer.fromJson<int>(json['propertyId']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'propertyId': serializer.toJson<int>(propertyId),
      'value': serializer.toJson<int>(value),
    };
  }

  WidgetPropertyIntRow copyWith({int? id, int? propertyId, int? value}) =>
      WidgetPropertyIntRow(
        id: id ?? this.id,
        propertyId: propertyId ?? this.propertyId,
        value: value ?? this.value,
      );
  WidgetPropertyIntRow copyWithCompanion(WidgetPropertyIntsCompanion data) {
    return WidgetPropertyIntRow(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyIntRow(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, propertyId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyIntRow &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          other.value == this.value);
}

class WidgetPropertyIntsCompanion
    extends UpdateCompanion<WidgetPropertyIntRow> {
  final Value<int> id;
  final Value<int> propertyId;
  final Value<int> value;
  const WidgetPropertyIntsCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.value = const Value.absent(),
  });
  WidgetPropertyIntsCompanion.insert({
    this.id = const Value.absent(),
    required int propertyId,
    required int value,
  }) : propertyId = Value(propertyId),
       value = Value(value);
  static Insertable<WidgetPropertyIntRow> custom({
    Expression<int>? id,
    Expression<int>? propertyId,
    Expression<int>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (value != null) 'value': value,
    });
  }

  WidgetPropertyIntsCompanion copyWith({
    Value<int>? id,
    Value<int>? propertyId,
    Value<int>? value,
  }) {
    return WidgetPropertyIntsCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyIntsCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertyFloatsTable extends WidgetPropertyFloats
    with TableInfo<$WidgetPropertyFloatsTable, WidgetPropertyFloatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertyFloatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, propertyId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_property_floats';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyFloatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyFloatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyFloatRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $WidgetPropertyFloatsTable createAlias(String alias) {
    return $WidgetPropertyFloatsTable(attachedDatabase, alias);
  }
}

class WidgetPropertyFloatRow extends DataClass
    implements Insertable<WidgetPropertyFloatRow> {
  final int id;
  final int propertyId;
  final double value;
  const WidgetPropertyFloatRow({
    required this.id,
    required this.propertyId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['property_id'] = Variable<int>(propertyId);
    map['value'] = Variable<double>(value);
    return map;
  }

  WidgetPropertyFloatsCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertyFloatsCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      value: Value(value),
    );
  }

  factory WidgetPropertyFloatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyFloatRow(
      id: serializer.fromJson<int>(json['id']),
      propertyId: serializer.fromJson<int>(json['propertyId']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'propertyId': serializer.toJson<int>(propertyId),
      'value': serializer.toJson<double>(value),
    };
  }

  WidgetPropertyFloatRow copyWith({int? id, int? propertyId, double? value}) =>
      WidgetPropertyFloatRow(
        id: id ?? this.id,
        propertyId: propertyId ?? this.propertyId,
        value: value ?? this.value,
      );
  WidgetPropertyFloatRow copyWithCompanion(WidgetPropertyFloatsCompanion data) {
    return WidgetPropertyFloatRow(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyFloatRow(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, propertyId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyFloatRow &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          other.value == this.value);
}

class WidgetPropertyFloatsCompanion
    extends UpdateCompanion<WidgetPropertyFloatRow> {
  final Value<int> id;
  final Value<int> propertyId;
  final Value<double> value;
  const WidgetPropertyFloatsCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.value = const Value.absent(),
  });
  WidgetPropertyFloatsCompanion.insert({
    this.id = const Value.absent(),
    required int propertyId,
    required double value,
  }) : propertyId = Value(propertyId),
       value = Value(value);
  static Insertable<WidgetPropertyFloatRow> custom({
    Expression<int>? id,
    Expression<int>? propertyId,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (value != null) 'value': value,
    });
  }

  WidgetPropertyFloatsCompanion copyWith({
    Value<int>? id,
    Value<int>? propertyId,
    Value<double>? value,
  }) {
    return WidgetPropertyFloatsCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyFloatsCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertyBoolsTable extends WidgetPropertyBools
    with TableInfo<$WidgetPropertyBoolsTable, WidgetPropertyBoolRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertyBoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<bool> value = GeneratedColumn<bool>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("value" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, propertyId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_property_bools';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyBoolRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyBoolRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyBoolRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $WidgetPropertyBoolsTable createAlias(String alias) {
    return $WidgetPropertyBoolsTable(attachedDatabase, alias);
  }
}

class WidgetPropertyBoolRow extends DataClass
    implements Insertable<WidgetPropertyBoolRow> {
  final int id;
  final int propertyId;
  final bool value;
  const WidgetPropertyBoolRow({
    required this.id,
    required this.propertyId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['property_id'] = Variable<int>(propertyId);
    map['value'] = Variable<bool>(value);
    return map;
  }

  WidgetPropertyBoolsCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertyBoolsCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      value: Value(value),
    );
  }

  factory WidgetPropertyBoolRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyBoolRow(
      id: serializer.fromJson<int>(json['id']),
      propertyId: serializer.fromJson<int>(json['propertyId']),
      value: serializer.fromJson<bool>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'propertyId': serializer.toJson<int>(propertyId),
      'value': serializer.toJson<bool>(value),
    };
  }

  WidgetPropertyBoolRow copyWith({int? id, int? propertyId, bool? value}) =>
      WidgetPropertyBoolRow(
        id: id ?? this.id,
        propertyId: propertyId ?? this.propertyId,
        value: value ?? this.value,
      );
  WidgetPropertyBoolRow copyWithCompanion(WidgetPropertyBoolsCompanion data) {
    return WidgetPropertyBoolRow(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyBoolRow(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, propertyId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyBoolRow &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          other.value == this.value);
}

class WidgetPropertyBoolsCompanion
    extends UpdateCompanion<WidgetPropertyBoolRow> {
  final Value<int> id;
  final Value<int> propertyId;
  final Value<bool> value;
  const WidgetPropertyBoolsCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.value = const Value.absent(),
  });
  WidgetPropertyBoolsCompanion.insert({
    this.id = const Value.absent(),
    required int propertyId,
    required bool value,
  }) : propertyId = Value(propertyId),
       value = Value(value);
  static Insertable<WidgetPropertyBoolRow> custom({
    Expression<int>? id,
    Expression<int>? propertyId,
    Expression<bool>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (value != null) 'value': value,
    });
  }

  WidgetPropertyBoolsCompanion copyWith({
    Value<int>? id,
    Value<int>? propertyId,
    Value<bool>? value,
  }) {
    return WidgetPropertyBoolsCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (value.present) {
      map['value'] = Variable<bool>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyBoolsCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $WidgetPropertyRawBytesListTable extends WidgetPropertyRawBytesList
    with
        TableInfo<$WidgetPropertyRawBytesListTable, WidgetPropertyRawBytesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetPropertyRawBytesListTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<Uint8List> value = GeneratedColumn<Uint8List>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, propertyId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_property_raw_bytes_list';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetPropertyRawBytesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetPropertyRawBytesRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetPropertyRawBytesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $WidgetPropertyRawBytesListTable createAlias(String alias) {
    return $WidgetPropertyRawBytesListTable(attachedDatabase, alias);
  }
}

class WidgetPropertyRawBytesRow extends DataClass
    implements Insertable<WidgetPropertyRawBytesRow> {
  final int id;
  final int propertyId;
  final Uint8List value;
  const WidgetPropertyRawBytesRow({
    required this.id,
    required this.propertyId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['property_id'] = Variable<int>(propertyId);
    map['value'] = Variable<Uint8List>(value);
    return map;
  }

  WidgetPropertyRawBytesListCompanion toCompanion(bool nullToAbsent) {
    return WidgetPropertyRawBytesListCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      value: Value(value),
    );
  }

  factory WidgetPropertyRawBytesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetPropertyRawBytesRow(
      id: serializer.fromJson<int>(json['id']),
      propertyId: serializer.fromJson<int>(json['propertyId']),
      value: serializer.fromJson<Uint8List>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'propertyId': serializer.toJson<int>(propertyId),
      'value': serializer.toJson<Uint8List>(value),
    };
  }

  WidgetPropertyRawBytesRow copyWith({
    int? id,
    int? propertyId,
    Uint8List? value,
  }) => WidgetPropertyRawBytesRow(
    id: id ?? this.id,
    propertyId: propertyId ?? this.propertyId,
    value: value ?? this.value,
  );
  WidgetPropertyRawBytesRow copyWithCompanion(
    WidgetPropertyRawBytesListCompanion data,
  ) {
    return WidgetPropertyRawBytesRow(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyRawBytesRow(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, propertyId, $driftBlobEquality.hash(value));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetPropertyRawBytesRow &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          $driftBlobEquality.equals(other.value, this.value));
}

class WidgetPropertyRawBytesListCompanion
    extends UpdateCompanion<WidgetPropertyRawBytesRow> {
  final Value<int> id;
  final Value<int> propertyId;
  final Value<Uint8List> value;
  const WidgetPropertyRawBytesListCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.value = const Value.absent(),
  });
  WidgetPropertyRawBytesListCompanion.insert({
    this.id = const Value.absent(),
    required int propertyId,
    required Uint8List value,
  }) : propertyId = Value(propertyId),
       value = Value(value);
  static Insertable<WidgetPropertyRawBytesRow> custom({
    Expression<int>? id,
    Expression<int>? propertyId,
    Expression<Uint8List>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (value != null) 'value': value,
    });
  }

  WidgetPropertyRawBytesListCompanion copyWith({
    Value<int>? id,
    Value<int>? propertyId,
    Value<Uint8List>? value,
  }) {
    return WidgetPropertyRawBytesListCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (value.present) {
      map['value'] = Variable<Uint8List>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetPropertyRawBytesListCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $DashboardsTable extends Dashboards
    with TableInfo<$DashboardsTable, DashboardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backgroundImagePathMeta =
      const VerificationMeta('backgroundImagePath');
  @override
  late final GeneratedColumn<String> backgroundImagePath =
      GeneratedColumn<String>(
        'background_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _backgroundImageIdMeta = const VerificationMeta(
    'backgroundImageId',
  );
  @override
  late final GeneratedColumn<int> backgroundImageId = GeneratedColumn<int>(
    'background_image_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1920.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1080.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    backendId,
    name,
    order,
    timestamp,
    backgroundImagePath,
    backgroundImageId,
    width,
    height,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboards';
  @override
  VerificationContext validateIntegrity(
    Insertable<DashboardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('background_image_path')) {
      context.handle(
        _backgroundImagePathMeta,
        backgroundImagePath.isAcceptableOrUnknown(
          data['background_image_path']!,
          _backgroundImagePathMeta,
        ),
      );
    }
    if (data.containsKey('background_image_id')) {
      context.handle(
        _backgroundImageIdMeta,
        backgroundImageId.isAcceptableOrUnknown(
          data['background_image_id']!,
          _backgroundImageIdMeta,
        ),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DashboardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      backgroundImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background_image_path'],
      ),
      backgroundImageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}background_image_id'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
    );
  }

  @override
  $DashboardsTable createAlias(String alias) {
    return $DashboardsTable(attachedDatabase, alias);
  }
}

class DashboardRow extends DataClass implements Insertable<DashboardRow> {
  final int id;
  final int backendId;
  final String name;
  final int order;
  final int timestamp;
  final String? backgroundImagePath;
  final int backgroundImageId;
  final double width;
  final double height;
  const DashboardRow({
    required this.id,
    required this.backendId,
    required this.name,
    required this.order,
    required this.timestamp,
    this.backgroundImagePath,
    required this.backgroundImageId,
    required this.width,
    required this.height,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['backend_id'] = Variable<int>(backendId);
    map['name'] = Variable<String>(name);
    map['order'] = Variable<int>(order);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || backgroundImagePath != null) {
      map['background_image_path'] = Variable<String>(backgroundImagePath);
    }
    map['background_image_id'] = Variable<int>(backgroundImageId);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    return map;
  }

  DashboardsCompanion toCompanion(bool nullToAbsent) {
    return DashboardsCompanion(
      id: Value(id),
      backendId: Value(backendId),
      name: Value(name),
      order: Value(order),
      timestamp: Value(timestamp),
      backgroundImagePath: backgroundImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundImagePath),
      backgroundImageId: Value(backgroundImageId),
      width: Value(width),
      height: Value(height),
    );
  }

  factory DashboardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardRow(
      id: serializer.fromJson<int>(json['id']),
      backendId: serializer.fromJson<int>(json['backendId']),
      name: serializer.fromJson<String>(json['name']),
      order: serializer.fromJson<int>(json['order']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      backgroundImagePath: serializer.fromJson<String?>(
        json['backgroundImagePath'],
      ),
      backgroundImageId: serializer.fromJson<int>(json['backgroundImageId']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'backendId': serializer.toJson<int>(backendId),
      'name': serializer.toJson<String>(name),
      'order': serializer.toJson<int>(order),
      'timestamp': serializer.toJson<int>(timestamp),
      'backgroundImagePath': serializer.toJson<String?>(backgroundImagePath),
      'backgroundImageId': serializer.toJson<int>(backgroundImageId),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
    };
  }

  DashboardRow copyWith({
    int? id,
    int? backendId,
    String? name,
    int? order,
    int? timestamp,
    Value<String?> backgroundImagePath = const Value.absent(),
    int? backgroundImageId,
    double? width,
    double? height,
  }) => DashboardRow(
    id: id ?? this.id,
    backendId: backendId ?? this.backendId,
    name: name ?? this.name,
    order: order ?? this.order,
    timestamp: timestamp ?? this.timestamp,
    backgroundImagePath: backgroundImagePath.present
        ? backgroundImagePath.value
        : this.backgroundImagePath,
    backgroundImageId: backgroundImageId ?? this.backgroundImageId,
    width: width ?? this.width,
    height: height ?? this.height,
  );
  DashboardRow copyWithCompanion(DashboardsCompanion data) {
    return DashboardRow(
      id: data.id.present ? data.id.value : this.id,
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      name: data.name.present ? data.name.value : this.name,
      order: data.order.present ? data.order.value : this.order,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      backgroundImagePath: data.backgroundImagePath.present
          ? data.backgroundImagePath.value
          : this.backgroundImagePath,
      backgroundImageId: data.backgroundImageId.present
          ? data.backgroundImageId.value
          : this.backgroundImageId,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardRow(')
          ..write('id: $id, ')
          ..write('backendId: $backendId, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('timestamp: $timestamp, ')
          ..write('backgroundImagePath: $backgroundImagePath, ')
          ..write('backgroundImageId: $backgroundImageId, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    backendId,
    name,
    order,
    timestamp,
    backgroundImagePath,
    backgroundImageId,
    width,
    height,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardRow &&
          other.id == this.id &&
          other.backendId == this.backendId &&
          other.name == this.name &&
          other.order == this.order &&
          other.timestamp == this.timestamp &&
          other.backgroundImagePath == this.backgroundImagePath &&
          other.backgroundImageId == this.backgroundImageId &&
          other.width == this.width &&
          other.height == this.height);
}

class DashboardsCompanion extends UpdateCompanion<DashboardRow> {
  final Value<int> id;
  final Value<int> backendId;
  final Value<String> name;
  final Value<int> order;
  final Value<int> timestamp;
  final Value<String?> backgroundImagePath;
  final Value<int> backgroundImageId;
  final Value<double> width;
  final Value<double> height;
  const DashboardsCompanion({
    this.id = const Value.absent(),
    this.backendId = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.backgroundImagePath = const Value.absent(),
    this.backgroundImageId = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
  });
  DashboardsCompanion.insert({
    this.id = const Value.absent(),
    this.backendId = const Value.absent(),
    required String name,
    this.order = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.backgroundImagePath = const Value.absent(),
    this.backgroundImageId = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DashboardRow> custom({
    Expression<int>? id,
    Expression<int>? backendId,
    Expression<String>? name,
    Expression<int>? order,
    Expression<int>? timestamp,
    Expression<String>? backgroundImagePath,
    Expression<int>? backgroundImageId,
    Expression<double>? width,
    Expression<double>? height,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backendId != null) 'backend_id': backendId,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
      if (timestamp != null) 'timestamp': timestamp,
      if (backgroundImagePath != null)
        'background_image_path': backgroundImagePath,
      if (backgroundImageId != null) 'background_image_id': backgroundImageId,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    });
  }

  DashboardsCompanion copyWith({
    Value<int>? id,
    Value<int>? backendId,
    Value<String>? name,
    Value<int>? order,
    Value<int>? timestamp,
    Value<String?>? backgroundImagePath,
    Value<int>? backgroundImageId,
    Value<double>? width,
    Value<double>? height,
  }) {
    return DashboardsCompanion(
      id: id ?? this.id,
      backendId: backendId ?? this.backendId,
      name: name ?? this.name,
      order: order ?? this.order,
      timestamp: timestamp ?? this.timestamp,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundImageId: backgroundImageId ?? this.backgroundImageId,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (backgroundImagePath.present) {
      map['background_image_path'] = Variable<String>(
        backgroundImagePath.value,
      );
    }
    if (backgroundImageId.present) {
      map['background_image_id'] = Variable<int>(backgroundImageId.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardsCompanion(')
          ..write('id: $id, ')
          ..write('backendId: $backendId, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('timestamp: $timestamp, ')
          ..write('backgroundImagePath: $backgroundImagePath, ')
          ..write('backgroundImageId: $backgroundImageId, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }
}

class $DashboardItemsTable extends DashboardItems
    with TableInfo<$DashboardItemsTable, DashboardItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dbTypeMeta = const VerificationMeta('dbType');
  @override
  late final GeneratedColumn<int> dbType = GeneratedColumn<int>(
    'db_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _standardIconCodePointMeta =
      const VerificationMeta('standardIconCodePoint');
  @override
  late final GeneratedColumn<int> standardIconCodePoint = GeneratedColumn<int>(
    'standard_icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _standardColorValueMeta =
      const VerificationMeta('standardColorValue');
  @override
  late final GeneratedColumn<int> standardColorValue = GeneratedColumn<int>(
    'standard_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitOverrideMeta = const VerificationMeta(
    'unitOverride',
  );
  @override
  late final GeneratedColumn<String> unitOverride = GeneratedColumn<String>(
    'unit_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dashboardIdMeta = const VerificationMeta(
    'dashboardId',
  );
  @override
  late final GeneratedColumn<int> dashboardId = GeneratedColumn<int>(
    'dashboard_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueFontSizeMeta = const VerificationMeta(
    'valueFontSize',
  );
  @override
  late final GeneratedColumn<double> valueFontSize = GeneratedColumn<double>(
    'value_font_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(9.0),
  );
  static const VerificationMeta _valuePositionMeta = const VerificationMeta(
    'valuePosition',
  );
  @override
  late final GeneratedColumn<int> valuePosition = GeneratedColumn<int>(
    'value_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    displayName,
    dbType,
    x,
    y,
    width,
    height,
    standardIconCodePoint,
    standardColorValue,
    unitOverride,
    dashboardId,
    valueFontSize,
    valuePosition,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DashboardItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('db_type')) {
      context.handle(
        _dbTypeMeta,
        dbType.isAcceptableOrUnknown(data['db_type']!, _dbTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dbTypeMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('standard_icon_code_point')) {
      context.handle(
        _standardIconCodePointMeta,
        standardIconCodePoint.isAcceptableOrUnknown(
          data['standard_icon_code_point']!,
          _standardIconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_standardIconCodePointMeta);
    }
    if (data.containsKey('standard_color_value')) {
      context.handle(
        _standardColorValueMeta,
        standardColorValue.isAcceptableOrUnknown(
          data['standard_color_value']!,
          _standardColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_standardColorValueMeta);
    }
    if (data.containsKey('unit_override')) {
      context.handle(
        _unitOverrideMeta,
        unitOverride.isAcceptableOrUnknown(
          data['unit_override']!,
          _unitOverrideMeta,
        ),
      );
    }
    if (data.containsKey('dashboard_id')) {
      context.handle(
        _dashboardIdMeta,
        dashboardId.isAcceptableOrUnknown(
          data['dashboard_id']!,
          _dashboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dashboardIdMeta);
    }
    if (data.containsKey('value_font_size')) {
      context.handle(
        _valueFontSizeMeta,
        valueFontSize.isAcceptableOrUnknown(
          data['value_font_size']!,
          _valueFontSizeMeta,
        ),
      );
    }
    if (data.containsKey('value_position')) {
      context.handle(
        _valuePositionMeta,
        valuePosition.isAcceptableOrUnknown(
          data['value_position']!,
          _valuePositionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DashboardItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      dbType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}db_type'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      standardIconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_icon_code_point'],
      )!,
      standardColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_color_value'],
      )!,
      unitOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_override'],
      ),
      dashboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dashboard_id'],
      )!,
      valueFontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_font_size'],
      )!,
      valuePosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_position'],
      )!,
    );
  }

  @override
  $DashboardItemsTable createAlias(String alias) {
    return $DashboardItemsTable(attachedDatabase, alias);
  }
}

class DashboardItemRow extends DataClass
    implements Insertable<DashboardItemRow> {
  final int id;
  final String entityId;
  final String displayName;
  final int dbType;
  final double x;
  final double y;
  final double width;
  final double height;
  final int standardIconCodePoint;
  final int standardColorValue;
  final String? unitOverride;
  final int dashboardId;
  final double valueFontSize;
  final int valuePosition;
  const DashboardItemRow({
    required this.id,
    required this.entityId,
    required this.displayName,
    required this.dbType,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.standardIconCodePoint,
    required this.standardColorValue,
    this.unitOverride,
    required this.dashboardId,
    required this.valueFontSize,
    required this.valuePosition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['display_name'] = Variable<String>(displayName);
    map['db_type'] = Variable<int>(dbType);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['standard_icon_code_point'] = Variable<int>(standardIconCodePoint);
    map['standard_color_value'] = Variable<int>(standardColorValue);
    if (!nullToAbsent || unitOverride != null) {
      map['unit_override'] = Variable<String>(unitOverride);
    }
    map['dashboard_id'] = Variable<int>(dashboardId);
    map['value_font_size'] = Variable<double>(valueFontSize);
    map['value_position'] = Variable<int>(valuePosition);
    return map;
  }

  DashboardItemsCompanion toCompanion(bool nullToAbsent) {
    return DashboardItemsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      displayName: Value(displayName),
      dbType: Value(dbType),
      x: Value(x),
      y: Value(y),
      width: Value(width),
      height: Value(height),
      standardIconCodePoint: Value(standardIconCodePoint),
      standardColorValue: Value(standardColorValue),
      unitOverride: unitOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(unitOverride),
      dashboardId: Value(dashboardId),
      valueFontSize: Value(valueFontSize),
      valuePosition: Value(valuePosition),
    );
  }

  factory DashboardItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardItemRow(
      id: serializer.fromJson<int>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      dbType: serializer.fromJson<int>(json['dbType']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      standardIconCodePoint: serializer.fromJson<int>(
        json['standardIconCodePoint'],
      ),
      standardColorValue: serializer.fromJson<int>(json['standardColorValue']),
      unitOverride: serializer.fromJson<String?>(json['unitOverride']),
      dashboardId: serializer.fromJson<int>(json['dashboardId']),
      valueFontSize: serializer.fromJson<double>(json['valueFontSize']),
      valuePosition: serializer.fromJson<int>(json['valuePosition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityId': serializer.toJson<String>(entityId),
      'displayName': serializer.toJson<String>(displayName),
      'dbType': serializer.toJson<int>(dbType),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'standardIconCodePoint': serializer.toJson<int>(standardIconCodePoint),
      'standardColorValue': serializer.toJson<int>(standardColorValue),
      'unitOverride': serializer.toJson<String?>(unitOverride),
      'dashboardId': serializer.toJson<int>(dashboardId),
      'valueFontSize': serializer.toJson<double>(valueFontSize),
      'valuePosition': serializer.toJson<int>(valuePosition),
    };
  }

  DashboardItemRow copyWith({
    int? id,
    String? entityId,
    String? displayName,
    int? dbType,
    double? x,
    double? y,
    double? width,
    double? height,
    int? standardIconCodePoint,
    int? standardColorValue,
    Value<String?> unitOverride = const Value.absent(),
    int? dashboardId,
    double? valueFontSize,
    int? valuePosition,
  }) => DashboardItemRow(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    displayName: displayName ?? this.displayName,
    dbType: dbType ?? this.dbType,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    standardIconCodePoint: standardIconCodePoint ?? this.standardIconCodePoint,
    standardColorValue: standardColorValue ?? this.standardColorValue,
    unitOverride: unitOverride.present ? unitOverride.value : this.unitOverride,
    dashboardId: dashboardId ?? this.dashboardId,
    valueFontSize: valueFontSize ?? this.valueFontSize,
    valuePosition: valuePosition ?? this.valuePosition,
  );
  DashboardItemRow copyWithCompanion(DashboardItemsCompanion data) {
    return DashboardItemRow(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      dbType: data.dbType.present ? data.dbType.value : this.dbType,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      standardIconCodePoint: data.standardIconCodePoint.present
          ? data.standardIconCodePoint.value
          : this.standardIconCodePoint,
      standardColorValue: data.standardColorValue.present
          ? data.standardColorValue.value
          : this.standardColorValue,
      unitOverride: data.unitOverride.present
          ? data.unitOverride.value
          : this.unitOverride,
      dashboardId: data.dashboardId.present
          ? data.dashboardId.value
          : this.dashboardId,
      valueFontSize: data.valueFontSize.present
          ? data.valueFontSize.value
          : this.valueFontSize,
      valuePosition: data.valuePosition.present
          ? data.valuePosition.value
          : this.valuePosition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardItemRow(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('displayName: $displayName, ')
          ..write('dbType: $dbType, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('standardIconCodePoint: $standardIconCodePoint, ')
          ..write('standardColorValue: $standardColorValue, ')
          ..write('unitOverride: $unitOverride, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('valueFontSize: $valueFontSize, ')
          ..write('valuePosition: $valuePosition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    displayName,
    dbType,
    x,
    y,
    width,
    height,
    standardIconCodePoint,
    standardColorValue,
    unitOverride,
    dashboardId,
    valueFontSize,
    valuePosition,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardItemRow &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.displayName == this.displayName &&
          other.dbType == this.dbType &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height &&
          other.standardIconCodePoint == this.standardIconCodePoint &&
          other.standardColorValue == this.standardColorValue &&
          other.unitOverride == this.unitOverride &&
          other.dashboardId == this.dashboardId &&
          other.valueFontSize == this.valueFontSize &&
          other.valuePosition == this.valuePosition);
}

class DashboardItemsCompanion extends UpdateCompanion<DashboardItemRow> {
  final Value<int> id;
  final Value<String> entityId;
  final Value<String> displayName;
  final Value<int> dbType;
  final Value<double> x;
  final Value<double> y;
  final Value<double> width;
  final Value<double> height;
  final Value<int> standardIconCodePoint;
  final Value<int> standardColorValue;
  final Value<String?> unitOverride;
  final Value<int> dashboardId;
  final Value<double> valueFontSize;
  final Value<int> valuePosition;
  const DashboardItemsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.dbType = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.standardIconCodePoint = const Value.absent(),
    this.standardColorValue = const Value.absent(),
    this.unitOverride = const Value.absent(),
    this.dashboardId = const Value.absent(),
    this.valueFontSize = const Value.absent(),
    this.valuePosition = const Value.absent(),
  });
  DashboardItemsCompanion.insert({
    this.id = const Value.absent(),
    required String entityId,
    required String displayName,
    required int dbType,
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int standardIconCodePoint,
    required int standardColorValue,
    this.unitOverride = const Value.absent(),
    required int dashboardId,
    this.valueFontSize = const Value.absent(),
    this.valuePosition = const Value.absent(),
  }) : entityId = Value(entityId),
       displayName = Value(displayName),
       dbType = Value(dbType),
       standardIconCodePoint = Value(standardIconCodePoint),
       standardColorValue = Value(standardColorValue),
       dashboardId = Value(dashboardId);
  static Insertable<DashboardItemRow> custom({
    Expression<int>? id,
    Expression<String>? entityId,
    Expression<String>? displayName,
    Expression<int>? dbType,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<int>? standardIconCodePoint,
    Expression<int>? standardColorValue,
    Expression<String>? unitOverride,
    Expression<int>? dashboardId,
    Expression<double>? valueFontSize,
    Expression<int>? valuePosition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (displayName != null) 'display_name': displayName,
      if (dbType != null) 'db_type': dbType,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (standardIconCodePoint != null)
        'standard_icon_code_point': standardIconCodePoint,
      if (standardColorValue != null)
        'standard_color_value': standardColorValue,
      if (unitOverride != null) 'unit_override': unitOverride,
      if (dashboardId != null) 'dashboard_id': dashboardId,
      if (valueFontSize != null) 'value_font_size': valueFontSize,
      if (valuePosition != null) 'value_position': valuePosition,
    });
  }

  DashboardItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityId,
    Value<String>? displayName,
    Value<int>? dbType,
    Value<double>? x,
    Value<double>? y,
    Value<double>? width,
    Value<double>? height,
    Value<int>? standardIconCodePoint,
    Value<int>? standardColorValue,
    Value<String?>? unitOverride,
    Value<int>? dashboardId,
    Value<double>? valueFontSize,
    Value<int>? valuePosition,
  }) {
    return DashboardItemsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      displayName: displayName ?? this.displayName,
      dbType: dbType ?? this.dbType,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      standardIconCodePoint:
          standardIconCodePoint ?? this.standardIconCodePoint,
      standardColorValue: standardColorValue ?? this.standardColorValue,
      unitOverride: unitOverride ?? this.unitOverride,
      dashboardId: dashboardId ?? this.dashboardId,
      valueFontSize: valueFontSize ?? this.valueFontSize,
      valuePosition: valuePosition ?? this.valuePosition,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (dbType.present) {
      map['db_type'] = Variable<int>(dbType.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (standardIconCodePoint.present) {
      map['standard_icon_code_point'] = Variable<int>(
        standardIconCodePoint.value,
      );
    }
    if (standardColorValue.present) {
      map['standard_color_value'] = Variable<int>(standardColorValue.value);
    }
    if (unitOverride.present) {
      map['unit_override'] = Variable<String>(unitOverride.value);
    }
    if (dashboardId.present) {
      map['dashboard_id'] = Variable<int>(dashboardId.value);
    }
    if (valueFontSize.present) {
      map['value_font_size'] = Variable<double>(valueFontSize.value);
    }
    if (valuePosition.present) {
      map['value_position'] = Variable<int>(valuePosition.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardItemsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('displayName: $displayName, ')
          ..write('dbType: $dbType, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('standardIconCodePoint: $standardIconCodePoint, ')
          ..write('standardColorValue: $standardColorValue, ')
          ..write('unitOverride: $unitOverride, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('valueFontSize: $valueFontSize, ')
          ..write('valuePosition: $valuePosition')
          ..write(')'))
        .toString();
  }
}

class $ThresholdConfigsTable extends ThresholdConfigs
    with TableInfo<$ThresholdConfigsTable, ThresholdConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThresholdConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _triggerValueMeta = const VerificationMeta(
    'triggerValue',
  );
  @override
  late final GeneratedColumn<double> triggerValue = GeneratedColumn<double>(
    'trigger_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    triggerValue,
    iconCodePoint,
    colorValue,
    itemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'threshold_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThresholdConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trigger_value')) {
      context.handle(
        _triggerValueMeta,
        triggerValue.isAcceptableOrUnknown(
          data['trigger_value']!,
          _triggerValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerValueMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThresholdConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThresholdConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      triggerValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trigger_value'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $ThresholdConfigsTable createAlias(String alias) {
    return $ThresholdConfigsTable(attachedDatabase, alias);
  }
}

class ThresholdConfigRow extends DataClass
    implements Insertable<ThresholdConfigRow> {
  final int id;
  final double triggerValue;
  final int iconCodePoint;
  final int colorValue;
  final int itemId;
  const ThresholdConfigRow({
    required this.id,
    required this.triggerValue,
    required this.iconCodePoint,
    required this.colorValue,
    required this.itemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trigger_value'] = Variable<double>(triggerValue);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['color_value'] = Variable<int>(colorValue);
    map['item_id'] = Variable<int>(itemId);
    return map;
  }

  ThresholdConfigsCompanion toCompanion(bool nullToAbsent) {
    return ThresholdConfigsCompanion(
      id: Value(id),
      triggerValue: Value(triggerValue),
      iconCodePoint: Value(iconCodePoint),
      colorValue: Value(colorValue),
      itemId: Value(itemId),
    );
  }

  factory ThresholdConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThresholdConfigRow(
      id: serializer.fromJson<int>(json['id']),
      triggerValue: serializer.fromJson<double>(json['triggerValue']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      itemId: serializer.fromJson<int>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'triggerValue': serializer.toJson<double>(triggerValue),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'colorValue': serializer.toJson<int>(colorValue),
      'itemId': serializer.toJson<int>(itemId),
    };
  }

  ThresholdConfigRow copyWith({
    int? id,
    double? triggerValue,
    int? iconCodePoint,
    int? colorValue,
    int? itemId,
  }) => ThresholdConfigRow(
    id: id ?? this.id,
    triggerValue: triggerValue ?? this.triggerValue,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    colorValue: colorValue ?? this.colorValue,
    itemId: itemId ?? this.itemId,
  );
  ThresholdConfigRow copyWithCompanion(ThresholdConfigsCompanion data) {
    return ThresholdConfigRow(
      id: data.id.present ? data.id.value : this.id,
      triggerValue: data.triggerValue.present
          ? data.triggerValue.value
          : this.triggerValue,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdConfigRow(')
          ..write('id: $id, ')
          ..write('triggerValue: $triggerValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('colorValue: $colorValue, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, triggerValue, iconCodePoint, colorValue, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThresholdConfigRow &&
          other.id == this.id &&
          other.triggerValue == this.triggerValue &&
          other.iconCodePoint == this.iconCodePoint &&
          other.colorValue == this.colorValue &&
          other.itemId == this.itemId);
}

class ThresholdConfigsCompanion extends UpdateCompanion<ThresholdConfigRow> {
  final Value<int> id;
  final Value<double> triggerValue;
  final Value<int> iconCodePoint;
  final Value<int> colorValue;
  final Value<int> itemId;
  const ThresholdConfigsCompanion({
    this.id = const Value.absent(),
    this.triggerValue = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.itemId = const Value.absent(),
  });
  ThresholdConfigsCompanion.insert({
    this.id = const Value.absent(),
    required double triggerValue,
    required int iconCodePoint,
    required int colorValue,
    required int itemId,
  }) : triggerValue = Value(triggerValue),
       iconCodePoint = Value(iconCodePoint),
       colorValue = Value(colorValue),
       itemId = Value(itemId);
  static Insertable<ThresholdConfigRow> custom({
    Expression<int>? id,
    Expression<double>? triggerValue,
    Expression<int>? iconCodePoint,
    Expression<int>? colorValue,
    Expression<int>? itemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (triggerValue != null) 'trigger_value': triggerValue,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (colorValue != null) 'color_value': colorValue,
      if (itemId != null) 'item_id': itemId,
    });
  }

  ThresholdConfigsCompanion copyWith({
    Value<int>? id,
    Value<double>? triggerValue,
    Value<int>? iconCodePoint,
    Value<int>? colorValue,
    Value<int>? itemId,
  }) {
    return ThresholdConfigsCompanion(
      id: id ?? this.id,
      triggerValue: triggerValue ?? this.triggerValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      itemId: itemId ?? this.itemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (triggerValue.present) {
      map['trigger_value'] = Variable<double>(triggerValue.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdConfigsCompanion(')
          ..write('id: $id, ')
          ..write('triggerValue: $triggerValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('colorValue: $colorValue, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ViewsTable views = $ViewsTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $WidgetsTable widgets = $WidgetsTable(this);
  late final $WidgetPropertiesTable widgetProperties = $WidgetPropertiesTable(
    this,
  );
  late final $WidgetPropertyStringsTable widgetPropertyStrings =
      $WidgetPropertyStringsTable(this);
  late final $WidgetPropertyIntsTable widgetPropertyInts =
      $WidgetPropertyIntsTable(this);
  late final $WidgetPropertyFloatsTable widgetPropertyFloats =
      $WidgetPropertyFloatsTable(this);
  late final $WidgetPropertyBoolsTable widgetPropertyBools =
      $WidgetPropertyBoolsTable(this);
  late final $WidgetPropertyRawBytesListTable widgetPropertyRawBytesList =
      $WidgetPropertyRawBytesListTable(this);
  late final $DashboardsTable dashboards = $DashboardsTable(this);
  late final $DashboardItemsTable dashboardItems = $DashboardItemsTable(this);
  late final $ThresholdConfigsTable thresholdConfigs = $ThresholdConfigsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    users,
    views,
    pages,
    widgets,
    widgetProperties,
    widgetPropertyStrings,
    widgetPropertyInts,
    widgetPropertyFloats,
    widgetPropertyBools,
    widgetPropertyRawBytesList,
    dashboards,
    dashboardItems,
    thresholdConfigs,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      required String connectionId,
      required String name,
      required String ip,
      required int port,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      Value<String> connectionId,
      Value<String> name,
      Value<String> ip,
      Value<int> port,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          DeviceRow,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (DeviceRow, BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow>),
          DeviceRow,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ip = const Value.absent(),
                Value<int> port = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                connectionId: connectionId,
                name: name,
                ip: ip,
                port: port,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String connectionId,
                required String name,
                required String ip,
                required int port,
              }) => DevicesCompanion.insert(
                id: id,
                connectionId: connectionId,
                name: name,
                ip: ip,
                port: port,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      DeviceRow,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (DeviceRow, BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow>),
      DeviceRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      required int deviceId,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<int> deviceId,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                deviceId: deviceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required int deviceId,
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                deviceId: deviceId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ViewsTableCreateCompanionBuilder =
    ViewsCompanion Function({
      Value<int> id,
      Value<int> backendId,
      required int userId,
      Value<int> timestamp,
      Value<String> language,
      Value<int> theme,
      Value<bool> dirty,
    });
typedef $$ViewsTableUpdateCompanionBuilder =
    ViewsCompanion Function({
      Value<int> id,
      Value<int> backendId,
      Value<int> userId,
      Value<int> timestamp,
      Value<String> language,
      Value<int> theme,
      Value<bool> dirty,
    });

class $$ViewsTableFilterComposer extends Composer<_$AppDatabase, $ViewsTable> {
  $$ViewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ViewsTableOrderingComposer
    extends Composer<_$AppDatabase, $ViewsTable> {
  $$ViewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ViewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ViewsTable> {
  $$ViewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$ViewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ViewsTable,
          ViewRow,
          $$ViewsTableFilterComposer,
          $$ViewsTableOrderingComposer,
          $$ViewsTableAnnotationComposer,
          $$ViewsTableCreateCompanionBuilder,
          $$ViewsTableUpdateCompanionBuilder,
          (ViewRow, BaseReferences<_$AppDatabase, $ViewsTable, ViewRow>),
          ViewRow,
          PrefetchHooks Function()
        > {
  $$ViewsTableTableManager(_$AppDatabase db, $ViewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> backendId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> theme = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
              }) => ViewsCompanion(
                id: id,
                backendId: backendId,
                userId: userId,
                timestamp: timestamp,
                language: language,
                theme: theme,
                dirty: dirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> backendId = const Value.absent(),
                required int userId,
                Value<int> timestamp = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> theme = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
              }) => ViewsCompanion.insert(
                id: id,
                backendId: backendId,
                userId: userId,
                timestamp: timestamp,
                language: language,
                theme: theme,
                dirty: dirty,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ViewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ViewsTable,
      ViewRow,
      $$ViewsTableFilterComposer,
      $$ViewsTableOrderingComposer,
      $$ViewsTableAnnotationComposer,
      $$ViewsTableCreateCompanionBuilder,
      $$ViewsTableUpdateCompanionBuilder,
      (ViewRow, BaseReferences<_$AppDatabase, $ViewsTable, ViewRow>),
      ViewRow,
      PrefetchHooks Function()
    >;
typedef $$PagesTableCreateCompanionBuilder =
    PagesCompanion Function({
      Value<int> id,
      required int number,
      required int viewId,
    });
typedef $$PagesTableUpdateCompanionBuilder =
    PagesCompanion Function({
      Value<int> id,
      Value<int> number,
      Value<int> viewId,
    });

class $$PagesTableFilterComposer extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewId => $composableBuilder(
    column: $table.viewId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewId => $composableBuilder(
    column: $table.viewId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get viewId =>
      $composableBuilder(column: $table.viewId, builder: (column) => column);
}

class $$PagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagesTable,
          PageRow,
          $$PagesTableFilterComposer,
          $$PagesTableOrderingComposer,
          $$PagesTableAnnotationComposer,
          $$PagesTableCreateCompanionBuilder,
          $$PagesTableUpdateCompanionBuilder,
          (PageRow, BaseReferences<_$AppDatabase, $PagesTable, PageRow>),
          PageRow,
          PrefetchHooks Function()
        > {
  $$PagesTableTableManager(_$AppDatabase db, $PagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<int> viewId = const Value.absent(),
              }) => PagesCompanion(id: id, number: number, viewId: viewId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required int viewId,
              }) =>
                  PagesCompanion.insert(id: id, number: number, viewId: viewId),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagesTable,
      PageRow,
      $$PagesTableFilterComposer,
      $$PagesTableOrderingComposer,
      $$PagesTableAnnotationComposer,
      $$PagesTableCreateCompanionBuilder,
      $$PagesTableUpdateCompanionBuilder,
      (PageRow, BaseReferences<_$AppDatabase, $PagesTable, PageRow>),
      PageRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetsTableCreateCompanionBuilder =
    WidgetsCompanion Function({
      Value<int> id,
      required int widgetId,
      Value<double> xPos,
      Value<double> yPos,
      Value<double> width,
      Value<double> height,
      required int pageId,
    });
typedef $$WidgetsTableUpdateCompanionBuilder =
    WidgetsCompanion Function({
      Value<int> id,
      Value<int> widgetId,
      Value<double> xPos,
      Value<double> yPos,
      Value<double> width,
      Value<double> height,
      Value<int> pageId,
    });

class $$WidgetsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetsTable> {
  $$WidgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widgetId => $composableBuilder(
    column: $table.widgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get xPos => $composableBuilder(
    column: $table.xPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yPos => $composableBuilder(
    column: $table.yPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetsTable> {
  $$WidgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widgetId => $composableBuilder(
    column: $table.widgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get xPos => $composableBuilder(
    column: $table.xPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yPos => $composableBuilder(
    column: $table.yPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetsTable> {
  $$WidgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get widgetId =>
      $composableBuilder(column: $table.widgetId, builder: (column) => column);

  GeneratedColumn<double> get xPos =>
      $composableBuilder(column: $table.xPos, builder: (column) => column);

  GeneratedColumn<double> get yPos =>
      $composableBuilder(column: $table.yPos, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);
}

class $$WidgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetsTable,
          WidgetRow,
          $$WidgetsTableFilterComposer,
          $$WidgetsTableOrderingComposer,
          $$WidgetsTableAnnotationComposer,
          $$WidgetsTableCreateCompanionBuilder,
          $$WidgetsTableUpdateCompanionBuilder,
          (WidgetRow, BaseReferences<_$AppDatabase, $WidgetsTable, WidgetRow>),
          WidgetRow,
          PrefetchHooks Function()
        > {
  $$WidgetsTableTableManager(_$AppDatabase db, $WidgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> widgetId = const Value.absent(),
                Value<double> xPos = const Value.absent(),
                Value<double> yPos = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<int> pageId = const Value.absent(),
              }) => WidgetsCompanion(
                id: id,
                widgetId: widgetId,
                xPos: xPos,
                yPos: yPos,
                width: width,
                height: height,
                pageId: pageId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int widgetId,
                Value<double> xPos = const Value.absent(),
                Value<double> yPos = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                required int pageId,
              }) => WidgetsCompanion.insert(
                id: id,
                widgetId: widgetId,
                xPos: xPos,
                yPos: yPos,
                width: width,
                height: height,
                pageId: pageId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetsTable,
      WidgetRow,
      $$WidgetsTableFilterComposer,
      $$WidgetsTableOrderingComposer,
      $$WidgetsTableAnnotationComposer,
      $$WidgetsTableCreateCompanionBuilder,
      $$WidgetsTableUpdateCompanionBuilder,
      (WidgetRow, BaseReferences<_$AppDatabase, $WidgetsTable, WidgetRow>),
      WidgetRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertiesTableCreateCompanionBuilder =
    WidgetPropertiesCompanion Function({
      Value<int> id,
      required int keyId,
      required int type,
      required int widgetId,
    });
typedef $$WidgetPropertiesTableUpdateCompanionBuilder =
    WidgetPropertiesCompanion Function({
      Value<int> id,
      Value<int> keyId,
      Value<int> type,
      Value<int> widgetId,
    });

class $$WidgetPropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertiesTable> {
  $$WidgetPropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widgetId => $composableBuilder(
    column: $table.widgetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertiesTable> {
  $$WidgetPropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widgetId => $composableBuilder(
    column: $table.widgetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertiesTable> {
  $$WidgetPropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get widgetId =>
      $composableBuilder(column: $table.widgetId, builder: (column) => column);
}

class $$WidgetPropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertiesTable,
          WidgetPropertyRow,
          $$WidgetPropertiesTableFilterComposer,
          $$WidgetPropertiesTableOrderingComposer,
          $$WidgetPropertiesTableAnnotationComposer,
          $$WidgetPropertiesTableCreateCompanionBuilder,
          $$WidgetPropertiesTableUpdateCompanionBuilder,
          (
            WidgetPropertyRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertiesTable,
              WidgetPropertyRow
            >,
          ),
          WidgetPropertyRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertiesTableTableManager(
    _$AppDatabase db,
    $WidgetPropertiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetPropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetPropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> keyId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> widgetId = const Value.absent(),
              }) => WidgetPropertiesCompanion(
                id: id,
                keyId: keyId,
                type: type,
                widgetId: widgetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int keyId,
                required int type,
                required int widgetId,
              }) => WidgetPropertiesCompanion.insert(
                id: id,
                keyId: keyId,
                type: type,
                widgetId: widgetId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertiesTable,
      WidgetPropertyRow,
      $$WidgetPropertiesTableFilterComposer,
      $$WidgetPropertiesTableOrderingComposer,
      $$WidgetPropertiesTableAnnotationComposer,
      $$WidgetPropertiesTableCreateCompanionBuilder,
      $$WidgetPropertiesTableUpdateCompanionBuilder,
      (
        WidgetPropertyRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertiesTable,
          WidgetPropertyRow
        >,
      ),
      WidgetPropertyRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertyStringsTableCreateCompanionBuilder =
    WidgetPropertyStringsCompanion Function({
      Value<int> id,
      required int propertyId,
      required String value,
    });
typedef $$WidgetPropertyStringsTableUpdateCompanionBuilder =
    WidgetPropertyStringsCompanion Function({
      Value<int> id,
      Value<int> propertyId,
      Value<String> value,
    });

class $$WidgetPropertyStringsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertyStringsTable> {
  $$WidgetPropertyStringsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertyStringsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertyStringsTable> {
  $$WidgetPropertyStringsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertyStringsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertyStringsTable> {
  $$WidgetPropertyStringsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$WidgetPropertyStringsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertyStringsTable,
          WidgetPropertyStringRow,
          $$WidgetPropertyStringsTableFilterComposer,
          $$WidgetPropertyStringsTableOrderingComposer,
          $$WidgetPropertyStringsTableAnnotationComposer,
          $$WidgetPropertyStringsTableCreateCompanionBuilder,
          $$WidgetPropertyStringsTableUpdateCompanionBuilder,
          (
            WidgetPropertyStringRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertyStringsTable,
              WidgetPropertyStringRow
            >,
          ),
          WidgetPropertyStringRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertyStringsTableTableManager(
    _$AppDatabase db,
    $WidgetPropertyStringsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertyStringsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WidgetPropertyStringsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WidgetPropertyStringsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> propertyId = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => WidgetPropertyStringsCompanion(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int propertyId,
                required String value,
              }) => WidgetPropertyStringsCompanion.insert(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertyStringsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertyStringsTable,
      WidgetPropertyStringRow,
      $$WidgetPropertyStringsTableFilterComposer,
      $$WidgetPropertyStringsTableOrderingComposer,
      $$WidgetPropertyStringsTableAnnotationComposer,
      $$WidgetPropertyStringsTableCreateCompanionBuilder,
      $$WidgetPropertyStringsTableUpdateCompanionBuilder,
      (
        WidgetPropertyStringRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertyStringsTable,
          WidgetPropertyStringRow
        >,
      ),
      WidgetPropertyStringRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertyIntsTableCreateCompanionBuilder =
    WidgetPropertyIntsCompanion Function({
      Value<int> id,
      required int propertyId,
      required int value,
    });
typedef $$WidgetPropertyIntsTableUpdateCompanionBuilder =
    WidgetPropertyIntsCompanion Function({
      Value<int> id,
      Value<int> propertyId,
      Value<int> value,
    });

class $$WidgetPropertyIntsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertyIntsTable> {
  $$WidgetPropertyIntsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertyIntsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertyIntsTable> {
  $$WidgetPropertyIntsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertyIntsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertyIntsTable> {
  $$WidgetPropertyIntsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$WidgetPropertyIntsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertyIntsTable,
          WidgetPropertyIntRow,
          $$WidgetPropertyIntsTableFilterComposer,
          $$WidgetPropertyIntsTableOrderingComposer,
          $$WidgetPropertyIntsTableAnnotationComposer,
          $$WidgetPropertyIntsTableCreateCompanionBuilder,
          $$WidgetPropertyIntsTableUpdateCompanionBuilder,
          (
            WidgetPropertyIntRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertyIntsTable,
              WidgetPropertyIntRow
            >,
          ),
          WidgetPropertyIntRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertyIntsTableTableManager(
    _$AppDatabase db,
    $WidgetPropertyIntsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertyIntsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetPropertyIntsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetPropertyIntsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> propertyId = const Value.absent(),
                Value<int> value = const Value.absent(),
              }) => WidgetPropertyIntsCompanion(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int propertyId,
                required int value,
              }) => WidgetPropertyIntsCompanion.insert(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertyIntsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertyIntsTable,
      WidgetPropertyIntRow,
      $$WidgetPropertyIntsTableFilterComposer,
      $$WidgetPropertyIntsTableOrderingComposer,
      $$WidgetPropertyIntsTableAnnotationComposer,
      $$WidgetPropertyIntsTableCreateCompanionBuilder,
      $$WidgetPropertyIntsTableUpdateCompanionBuilder,
      (
        WidgetPropertyIntRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertyIntsTable,
          WidgetPropertyIntRow
        >,
      ),
      WidgetPropertyIntRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertyFloatsTableCreateCompanionBuilder =
    WidgetPropertyFloatsCompanion Function({
      Value<int> id,
      required int propertyId,
      required double value,
    });
typedef $$WidgetPropertyFloatsTableUpdateCompanionBuilder =
    WidgetPropertyFloatsCompanion Function({
      Value<int> id,
      Value<int> propertyId,
      Value<double> value,
    });

class $$WidgetPropertyFloatsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertyFloatsTable> {
  $$WidgetPropertyFloatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertyFloatsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertyFloatsTable> {
  $$WidgetPropertyFloatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertyFloatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertyFloatsTable> {
  $$WidgetPropertyFloatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$WidgetPropertyFloatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertyFloatsTable,
          WidgetPropertyFloatRow,
          $$WidgetPropertyFloatsTableFilterComposer,
          $$WidgetPropertyFloatsTableOrderingComposer,
          $$WidgetPropertyFloatsTableAnnotationComposer,
          $$WidgetPropertyFloatsTableCreateCompanionBuilder,
          $$WidgetPropertyFloatsTableUpdateCompanionBuilder,
          (
            WidgetPropertyFloatRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertyFloatsTable,
              WidgetPropertyFloatRow
            >,
          ),
          WidgetPropertyFloatRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertyFloatsTableTableManager(
    _$AppDatabase db,
    $WidgetPropertyFloatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertyFloatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetPropertyFloatsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WidgetPropertyFloatsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> propertyId = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => WidgetPropertyFloatsCompanion(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int propertyId,
                required double value,
              }) => WidgetPropertyFloatsCompanion.insert(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertyFloatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertyFloatsTable,
      WidgetPropertyFloatRow,
      $$WidgetPropertyFloatsTableFilterComposer,
      $$WidgetPropertyFloatsTableOrderingComposer,
      $$WidgetPropertyFloatsTableAnnotationComposer,
      $$WidgetPropertyFloatsTableCreateCompanionBuilder,
      $$WidgetPropertyFloatsTableUpdateCompanionBuilder,
      (
        WidgetPropertyFloatRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertyFloatsTable,
          WidgetPropertyFloatRow
        >,
      ),
      WidgetPropertyFloatRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertyBoolsTableCreateCompanionBuilder =
    WidgetPropertyBoolsCompanion Function({
      Value<int> id,
      required int propertyId,
      required bool value,
    });
typedef $$WidgetPropertyBoolsTableUpdateCompanionBuilder =
    WidgetPropertyBoolsCompanion Function({
      Value<int> id,
      Value<int> propertyId,
      Value<bool> value,
    });

class $$WidgetPropertyBoolsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertyBoolsTable> {
  $$WidgetPropertyBoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertyBoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertyBoolsTable> {
  $$WidgetPropertyBoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertyBoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertyBoolsTable> {
  $$WidgetPropertyBoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$WidgetPropertyBoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertyBoolsTable,
          WidgetPropertyBoolRow,
          $$WidgetPropertyBoolsTableFilterComposer,
          $$WidgetPropertyBoolsTableOrderingComposer,
          $$WidgetPropertyBoolsTableAnnotationComposer,
          $$WidgetPropertyBoolsTableCreateCompanionBuilder,
          $$WidgetPropertyBoolsTableUpdateCompanionBuilder,
          (
            WidgetPropertyBoolRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertyBoolsTable,
              WidgetPropertyBoolRow
            >,
          ),
          WidgetPropertyBoolRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertyBoolsTableTableManager(
    _$AppDatabase db,
    $WidgetPropertyBoolsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertyBoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetPropertyBoolsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WidgetPropertyBoolsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> propertyId = const Value.absent(),
                Value<bool> value = const Value.absent(),
              }) => WidgetPropertyBoolsCompanion(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int propertyId,
                required bool value,
              }) => WidgetPropertyBoolsCompanion.insert(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertyBoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertyBoolsTable,
      WidgetPropertyBoolRow,
      $$WidgetPropertyBoolsTableFilterComposer,
      $$WidgetPropertyBoolsTableOrderingComposer,
      $$WidgetPropertyBoolsTableAnnotationComposer,
      $$WidgetPropertyBoolsTableCreateCompanionBuilder,
      $$WidgetPropertyBoolsTableUpdateCompanionBuilder,
      (
        WidgetPropertyBoolRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertyBoolsTable,
          WidgetPropertyBoolRow
        >,
      ),
      WidgetPropertyBoolRow,
      PrefetchHooks Function()
    >;
typedef $$WidgetPropertyRawBytesListTableCreateCompanionBuilder =
    WidgetPropertyRawBytesListCompanion Function({
      Value<int> id,
      required int propertyId,
      required Uint8List value,
    });
typedef $$WidgetPropertyRawBytesListTableUpdateCompanionBuilder =
    WidgetPropertyRawBytesListCompanion Function({
      Value<int> id,
      Value<int> propertyId,
      Value<Uint8List> value,
    });

class $$WidgetPropertyRawBytesListTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetPropertyRawBytesListTable> {
  $$WidgetPropertyRawBytesListTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetPropertyRawBytesListTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetPropertyRawBytesListTable> {
  $$WidgetPropertyRawBytesListTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetPropertyRawBytesListTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetPropertyRawBytesListTable> {
  $$WidgetPropertyRawBytesListTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get propertyId => $composableBuilder(
    column: $table.propertyId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$WidgetPropertyRawBytesListTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetPropertyRawBytesListTable,
          WidgetPropertyRawBytesRow,
          $$WidgetPropertyRawBytesListTableFilterComposer,
          $$WidgetPropertyRawBytesListTableOrderingComposer,
          $$WidgetPropertyRawBytesListTableAnnotationComposer,
          $$WidgetPropertyRawBytesListTableCreateCompanionBuilder,
          $$WidgetPropertyRawBytesListTableUpdateCompanionBuilder,
          (
            WidgetPropertyRawBytesRow,
            BaseReferences<
              _$AppDatabase,
              $WidgetPropertyRawBytesListTable,
              WidgetPropertyRawBytesRow
            >,
          ),
          WidgetPropertyRawBytesRow,
          PrefetchHooks Function()
        > {
  $$WidgetPropertyRawBytesListTableTableManager(
    _$AppDatabase db,
    $WidgetPropertyRawBytesListTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetPropertyRawBytesListTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WidgetPropertyRawBytesListTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WidgetPropertyRawBytesListTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> propertyId = const Value.absent(),
                Value<Uint8List> value = const Value.absent(),
              }) => WidgetPropertyRawBytesListCompanion(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int propertyId,
                required Uint8List value,
              }) => WidgetPropertyRawBytesListCompanion.insert(
                id: id,
                propertyId: propertyId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetPropertyRawBytesListTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetPropertyRawBytesListTable,
      WidgetPropertyRawBytesRow,
      $$WidgetPropertyRawBytesListTableFilterComposer,
      $$WidgetPropertyRawBytesListTableOrderingComposer,
      $$WidgetPropertyRawBytesListTableAnnotationComposer,
      $$WidgetPropertyRawBytesListTableCreateCompanionBuilder,
      $$WidgetPropertyRawBytesListTableUpdateCompanionBuilder,
      (
        WidgetPropertyRawBytesRow,
        BaseReferences<
          _$AppDatabase,
          $WidgetPropertyRawBytesListTable,
          WidgetPropertyRawBytesRow
        >,
      ),
      WidgetPropertyRawBytesRow,
      PrefetchHooks Function()
    >;
typedef $$DashboardsTableCreateCompanionBuilder =
    DashboardsCompanion Function({
      Value<int> id,
      Value<int> backendId,
      required String name,
      Value<int> order,
      Value<int> timestamp,
      Value<String?> backgroundImagePath,
      Value<int> backgroundImageId,
      Value<double> width,
      Value<double> height,
    });
typedef $$DashboardsTableUpdateCompanionBuilder =
    DashboardsCompanion Function({
      Value<int> id,
      Value<int> backendId,
      Value<String> name,
      Value<int> order,
      Value<int> timestamp,
      Value<String?> backgroundImagePath,
      Value<int> backgroundImageId,
      Value<double> width,
      Value<double> height,
    });

class $$DashboardsTableFilterComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backgroundImagePath => $composableBuilder(
    column: $table.backgroundImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backgroundImageId => $composableBuilder(
    column: $table.backgroundImageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DashboardsTableOrderingComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backgroundImagePath => $composableBuilder(
    column: $table.backgroundImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundImageId => $composableBuilder(
    column: $table.backgroundImageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DashboardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get backgroundImagePath => $composableBuilder(
    column: $table.backgroundImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get backgroundImageId => $composableBuilder(
    column: $table.backgroundImageId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);
}

class $$DashboardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DashboardsTable,
          DashboardRow,
          $$DashboardsTableFilterComposer,
          $$DashboardsTableOrderingComposer,
          $$DashboardsTableAnnotationComposer,
          $$DashboardsTableCreateCompanionBuilder,
          $$DashboardsTableUpdateCompanionBuilder,
          (
            DashboardRow,
            BaseReferences<_$AppDatabase, $DashboardsTable, DashboardRow>,
          ),
          DashboardRow,
          PrefetchHooks Function()
        > {
  $$DashboardsTableTableManager(_$AppDatabase db, $DashboardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> backendId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> backgroundImagePath = const Value.absent(),
                Value<int> backgroundImageId = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
              }) => DashboardsCompanion(
                id: id,
                backendId: backendId,
                name: name,
                order: order,
                timestamp: timestamp,
                backgroundImagePath: backgroundImagePath,
                backgroundImageId: backgroundImageId,
                width: width,
                height: height,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> backendId = const Value.absent(),
                required String name,
                Value<int> order = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> backgroundImagePath = const Value.absent(),
                Value<int> backgroundImageId = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
              }) => DashboardsCompanion.insert(
                id: id,
                backendId: backendId,
                name: name,
                order: order,
                timestamp: timestamp,
                backgroundImagePath: backgroundImagePath,
                backgroundImageId: backgroundImageId,
                width: width,
                height: height,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DashboardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DashboardsTable,
      DashboardRow,
      $$DashboardsTableFilterComposer,
      $$DashboardsTableOrderingComposer,
      $$DashboardsTableAnnotationComposer,
      $$DashboardsTableCreateCompanionBuilder,
      $$DashboardsTableUpdateCompanionBuilder,
      (
        DashboardRow,
        BaseReferences<_$AppDatabase, $DashboardsTable, DashboardRow>,
      ),
      DashboardRow,
      PrefetchHooks Function()
    >;
typedef $$DashboardItemsTableCreateCompanionBuilder =
    DashboardItemsCompanion Function({
      Value<int> id,
      required String entityId,
      required String displayName,
      required int dbType,
      Value<double> x,
      Value<double> y,
      Value<double> width,
      Value<double> height,
      required int standardIconCodePoint,
      required int standardColorValue,
      Value<String?> unitOverride,
      required int dashboardId,
      Value<double> valueFontSize,
      Value<int> valuePosition,
    });
typedef $$DashboardItemsTableUpdateCompanionBuilder =
    DashboardItemsCompanion Function({
      Value<int> id,
      Value<String> entityId,
      Value<String> displayName,
      Value<int> dbType,
      Value<double> x,
      Value<double> y,
      Value<double> width,
      Value<double> height,
      Value<int> standardIconCodePoint,
      Value<int> standardColorValue,
      Value<String?> unitOverride,
      Value<int> dashboardId,
      Value<double> valueFontSize,
      Value<int> valuePosition,
    });

class $$DashboardItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DashboardItemsTable> {
  $$DashboardItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dbType => $composableBuilder(
    column: $table.dbType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardIconCodePoint => $composableBuilder(
    column: $table.standardIconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardColorValue => $composableBuilder(
    column: $table.standardColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOverride => $composableBuilder(
    column: $table.unitOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dashboardId => $composableBuilder(
    column: $table.dashboardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueFontSize => $composableBuilder(
    column: $table.valueFontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valuePosition => $composableBuilder(
    column: $table.valuePosition,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DashboardItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DashboardItemsTable> {
  $$DashboardItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dbType => $composableBuilder(
    column: $table.dbType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardIconCodePoint => $composableBuilder(
    column: $table.standardIconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardColorValue => $composableBuilder(
    column: $table.standardColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOverride => $composableBuilder(
    column: $table.unitOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dashboardId => $composableBuilder(
    column: $table.dashboardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueFontSize => $composableBuilder(
    column: $table.valueFontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valuePosition => $composableBuilder(
    column: $table.valuePosition,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DashboardItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DashboardItemsTable> {
  $$DashboardItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dbType =>
      $composableBuilder(column: $table.dbType, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get standardIconCodePoint => $composableBuilder(
    column: $table.standardIconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardColorValue => $composableBuilder(
    column: $table.standardColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOverride => $composableBuilder(
    column: $table.unitOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dashboardId => $composableBuilder(
    column: $table.dashboardId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valueFontSize => $composableBuilder(
    column: $table.valueFontSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valuePosition => $composableBuilder(
    column: $table.valuePosition,
    builder: (column) => column,
  );
}

class $$DashboardItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DashboardItemsTable,
          DashboardItemRow,
          $$DashboardItemsTableFilterComposer,
          $$DashboardItemsTableOrderingComposer,
          $$DashboardItemsTableAnnotationComposer,
          $$DashboardItemsTableCreateCompanionBuilder,
          $$DashboardItemsTableUpdateCompanionBuilder,
          (
            DashboardItemRow,
            BaseReferences<
              _$AppDatabase,
              $DashboardItemsTable,
              DashboardItemRow
            >,
          ),
          DashboardItemRow,
          PrefetchHooks Function()
        > {
  $$DashboardItemsTableTableManager(
    _$AppDatabase db,
    $DashboardItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> dbType = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<int> standardIconCodePoint = const Value.absent(),
                Value<int> standardColorValue = const Value.absent(),
                Value<String?> unitOverride = const Value.absent(),
                Value<int> dashboardId = const Value.absent(),
                Value<double> valueFontSize = const Value.absent(),
                Value<int> valuePosition = const Value.absent(),
              }) => DashboardItemsCompanion(
                id: id,
                entityId: entityId,
                displayName: displayName,
                dbType: dbType,
                x: x,
                y: y,
                width: width,
                height: height,
                standardIconCodePoint: standardIconCodePoint,
                standardColorValue: standardColorValue,
                unitOverride: unitOverride,
                dashboardId: dashboardId,
                valueFontSize: valueFontSize,
                valuePosition: valuePosition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityId,
                required String displayName,
                required int dbType,
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                required int standardIconCodePoint,
                required int standardColorValue,
                Value<String?> unitOverride = const Value.absent(),
                required int dashboardId,
                Value<double> valueFontSize = const Value.absent(),
                Value<int> valuePosition = const Value.absent(),
              }) => DashboardItemsCompanion.insert(
                id: id,
                entityId: entityId,
                displayName: displayName,
                dbType: dbType,
                x: x,
                y: y,
                width: width,
                height: height,
                standardIconCodePoint: standardIconCodePoint,
                standardColorValue: standardColorValue,
                unitOverride: unitOverride,
                dashboardId: dashboardId,
                valueFontSize: valueFontSize,
                valuePosition: valuePosition,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DashboardItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DashboardItemsTable,
      DashboardItemRow,
      $$DashboardItemsTableFilterComposer,
      $$DashboardItemsTableOrderingComposer,
      $$DashboardItemsTableAnnotationComposer,
      $$DashboardItemsTableCreateCompanionBuilder,
      $$DashboardItemsTableUpdateCompanionBuilder,
      (
        DashboardItemRow,
        BaseReferences<_$AppDatabase, $DashboardItemsTable, DashboardItemRow>,
      ),
      DashboardItemRow,
      PrefetchHooks Function()
    >;
typedef $$ThresholdConfigsTableCreateCompanionBuilder =
    ThresholdConfigsCompanion Function({
      Value<int> id,
      required double triggerValue,
      required int iconCodePoint,
      required int colorValue,
      required int itemId,
    });
typedef $$ThresholdConfigsTableUpdateCompanionBuilder =
    ThresholdConfigsCompanion Function({
      Value<int> id,
      Value<double> triggerValue,
      Value<int> iconCodePoint,
      Value<int> colorValue,
      Value<int> itemId,
    });

class $$ThresholdConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $ThresholdConfigsTable> {
  $$ThresholdConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get triggerValue => $composableBuilder(
    column: $table.triggerValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThresholdConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThresholdConfigsTable> {
  $$ThresholdConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get triggerValue => $composableBuilder(
    column: $table.triggerValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThresholdConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThresholdConfigsTable> {
  $$ThresholdConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get triggerValue => $composableBuilder(
    column: $table.triggerValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$ThresholdConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThresholdConfigsTable,
          ThresholdConfigRow,
          $$ThresholdConfigsTableFilterComposer,
          $$ThresholdConfigsTableOrderingComposer,
          $$ThresholdConfigsTableAnnotationComposer,
          $$ThresholdConfigsTableCreateCompanionBuilder,
          $$ThresholdConfigsTableUpdateCompanionBuilder,
          (
            ThresholdConfigRow,
            BaseReferences<
              _$AppDatabase,
              $ThresholdConfigsTable,
              ThresholdConfigRow
            >,
          ),
          ThresholdConfigRow,
          PrefetchHooks Function()
        > {
  $$ThresholdConfigsTableTableManager(
    _$AppDatabase db,
    $ThresholdConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThresholdConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThresholdConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThresholdConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> triggerValue = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> itemId = const Value.absent(),
              }) => ThresholdConfigsCompanion(
                id: id,
                triggerValue: triggerValue,
                iconCodePoint: iconCodePoint,
                colorValue: colorValue,
                itemId: itemId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double triggerValue,
                required int iconCodePoint,
                required int colorValue,
                required int itemId,
              }) => ThresholdConfigsCompanion.insert(
                id: id,
                triggerValue: triggerValue,
                iconCodePoint: iconCodePoint,
                colorValue: colorValue,
                itemId: itemId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThresholdConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThresholdConfigsTable,
      ThresholdConfigRow,
      $$ThresholdConfigsTableFilterComposer,
      $$ThresholdConfigsTableOrderingComposer,
      $$ThresholdConfigsTableAnnotationComposer,
      $$ThresholdConfigsTableCreateCompanionBuilder,
      $$ThresholdConfigsTableUpdateCompanionBuilder,
      (
        ThresholdConfigRow,
        BaseReferences<
          _$AppDatabase,
          $ThresholdConfigsTable,
          ThresholdConfigRow
        >,
      ),
      ThresholdConfigRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ViewsTableTableManager get views =>
      $$ViewsTableTableManager(_db, _db.views);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$WidgetsTableTableManager get widgets =>
      $$WidgetsTableTableManager(_db, _db.widgets);
  $$WidgetPropertiesTableTableManager get widgetProperties =>
      $$WidgetPropertiesTableTableManager(_db, _db.widgetProperties);
  $$WidgetPropertyStringsTableTableManager get widgetPropertyStrings =>
      $$WidgetPropertyStringsTableTableManager(_db, _db.widgetPropertyStrings);
  $$WidgetPropertyIntsTableTableManager get widgetPropertyInts =>
      $$WidgetPropertyIntsTableTableManager(_db, _db.widgetPropertyInts);
  $$WidgetPropertyFloatsTableTableManager get widgetPropertyFloats =>
      $$WidgetPropertyFloatsTableTableManager(_db, _db.widgetPropertyFloats);
  $$WidgetPropertyBoolsTableTableManager get widgetPropertyBools =>
      $$WidgetPropertyBoolsTableTableManager(_db, _db.widgetPropertyBools);
  $$WidgetPropertyRawBytesListTableTableManager
  get widgetPropertyRawBytesList =>
      $$WidgetPropertyRawBytesListTableTableManager(
        _db,
        _db.widgetPropertyRawBytesList,
      );
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db, _db.dashboards);
  $$DashboardItemsTableTableManager get dashboardItems =>
      $$DashboardItemsTableTableManager(_db, _db.dashboardItems);
  $$ThresholdConfigsTableTableManager get thresholdConfigs =>
      $$ThresholdConfigsTableTableManager(_db, _db.thresholdConfigs);
}
