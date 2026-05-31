import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart';
import 'package:smirror_wire/generated/permission_generated.dart';
import 'package:smirror_app/services/user_service.dart';

@lazySingleton
class SessionContextService {
  List<FeatureCodes> _features = [];
  int _rights = 0;
  String? _deviceName;
  late final StreamSubscription<User?> _userSub;

  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;

  SessionContextService() {
    _userSub = GetIt.I<UserService>().onUserChanged.listen((_) => reset());
  }

  void dispose() {
    _userSub.cancel();
    _changeController.close();
  }

  // ── Features ──────────────────────────────────────────────────────────────

  void updateFeatures(List<FeatureCodes> featureList) {
    _features = featureList;
    _changeController.add(null);
  }

  bool isFeatureAvailable(FeatureCodes code) => _features.contains(code);

  bool get hasFace => isFeatureAvailable(FeatureCodes.FACERECOGNITION);
  bool get hasLeds => isFeatureAvailable(FeatureCodes.LEDS);
  bool get hasFingerPrint => isFeatureAvailable(FeatureCodes.FINGERPRINT);
  bool get hasCamera => isFeatureAvailable(FeatureCodes.CAMERA);
  bool get hasLogs => isFeatureAvailable(FeatureCodes.LOGS);

  // ── Rights ────────────────────────────────────────────────────────────────

  void updateRights(int rights) {
    _rights = rights;
    _changeController.add(null);
  }

  bool hasPermission(Permission p) => (_rights & p.value) == p.value;

  int get rights => _rights;

  bool get canReadLogs => hasPermission(Permission.ReadLogs);
  bool get isAdmin => hasPermission(Permission.Admin);

  // ── Device Name ────────────────────────────────────────────────────────────

  void updateDeviceName(String? name) {
    _deviceName = name;
    _changeController.add(null);
  }

  String get deviceName => _deviceName ?? '';

  // ── Reset (on logout / user switch) ───────────────────────────────────────

  void reset() {
    _features = [];
    _rights = 0;
    _deviceName = null;
    _changeController.add(null);
  }
}
