import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/session_context_service.dart';

typedef Rights = int;

class SessionContextCubit extends Cubit<int> {
  late final StreamSubscription<void> _sub;
  final _session = GetIt.I<SessionContextService>();

  SessionContextCubit() : super(0) {
    _sub = _session.onChange.listen((_) => emit(state + 1));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
