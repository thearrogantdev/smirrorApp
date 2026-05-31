import 'dart:async';
import 'package:injectable/injectable.dart';

@singleton
class UserService {
  final _ctrl = StreamController<User?>.broadcast();
  User? _current;

  Stream<User?> get onUserChanged => _ctrl.stream;
  User? get currentUser => _current;

  void changeUser(User? user) {
    if (_current?.localUserId == user?.localUserId &&
        _current?.username == user?.username) {
      return;
    }
    _current = user;
    _ctrl.add(_current);
  }

  void dispose() => _ctrl.close();
}

/// Simple app-level user model
class User {
  final int localUserId; // local DB id
  final String username;

  User({required this.localUserId, required this.username});
}
