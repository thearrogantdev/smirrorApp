import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart'
    as backmsg;

@lazySingleton
class BinaryTransferRepository {
  final ValueNotifier<int?> maxMessageSize = ValueNotifier<int?>(null);
  void setMaxMessageSize(int value) => maxMessageSize.value = value;

  final _pendingTransfers = <int, Completer<backmsg.ResultT>>{};
  Future<backmsg.ResultT> registerTransfer(
    int transferId, {
    Duration? timeout,
  }) {
    final c = Completer<backmsg.ResultT>();
    _pendingTransfers[transferId] = c;
    if (timeout != null) {
      Future.delayed(timeout, () {
        if (!c.isCompleted) {
          c.completeError(TimeoutException('Transfer $transferId timed out'));
          _pendingTransfers.remove(transferId);
        }
      });
    }
    return c.future;
  }

  void completeTransfer(int transferId, backmsg.ResultT result) {
    final c = _pendingTransfers.remove(transferId);
    if (c != null && !c.isCompleted) c.complete(result);
  }

  // stream for chunks status
  final _chunkAck = StreamController<int>.broadcast();
  Stream<int> get chunkAcks => _chunkAck.stream;
  void notifyChunkAck(int transferId) => _chunkAck.add(transferId);

  // stream for begin
  final _acceptedCtrl = StreamController<int>.broadcast();
  Stream<int> get acceptedSignals => _acceptedCtrl.stream;
  void notifyAccepted(int transferId) => _acceptedCtrl.add(transferId);

  final Map<int, String> _paths = {};
  // single-flight waiter per id
  final Map<int, Completer<String>> _pathWaiters = {};

  /// Returns cached path if present, otherwise a Future that completes when
  /// `ingestPaths` provides it. The caller is responsible for *triggering*
  /// a request for missing ids (see usage below).
  Future<String> waitPath(int id, {Duration? timeout}) {
    final cached = _paths[id];
    if (cached != null) return Future.value(cached);

    final existing = _pathWaiters[id];
    if (existing != null) return existing.future;

    final c = Completer<String>();
    _pathWaiters[id] = c;

    if (timeout != null) {
      Future.delayed(timeout, () {
        final w = _pathWaiters.remove(id);
        if (w != null && !w.isCompleted) {
          w.completeError(TimeoutException('Path timeout for id=$id'));
        }
      });
    }

    return c.future;
  }

  /// Bulk helper to await multiple ids (assumes the caller will trigger a batch request)
  Future<Map<int, String>> waitPaths(
    Iterable<int> ids, {
    Duration? timeout,
  }) async {
    final futures = <int, Future<String>>{};
    for (final id in ids) {
      futures[id] = waitPath(id, timeout: timeout);
    }
    final result = <int, String>{};
    for (final e in futures.entries) {
      result[e.key] = await e.value;
    }
    return result;
  }

  /// Receiver bloc calls this when `BinaryPathes` arrives from backend.
  /// Completes any pending waiters and fills cache.
  void ingestPaths(Map<int, String> paths) {
    for (final entry in paths.entries) {
      _paths[entry.key] = entry.value;
      final w = _pathWaiters.remove(entry.key);
      if (w != null && !w.isCompleted) w.complete(entry.value);
    }
  }

  /// Convenience: get already-known path or null (non-async).
  String? peekPath(int id) => _paths[id];
}
