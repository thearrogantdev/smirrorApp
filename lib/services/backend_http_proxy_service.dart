import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart' as appmsg;
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;

@lazySingleton
class BackendHttpProxyService {
  final WebSocketService _webSocketService;

  BackendHttpProxyService(this._webSocketService);

  int _nextRequestId = 1;
  final Map<int, Completer<backmsg.ProxyHttpResponseT>> _pendingRequests = {};

  Future<http.Response> request({
    required String url,
    required String method,
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final requestId = _nextRequestId++;
    final completer = Completer<backmsg.ProxyHttpResponseT>();
    _pendingRequests[requestId] = completer;

    try {
      final requestBuilder = appmsg.ProxyHttpRequestT(
        requestId: requestId,
        url: url,
        method: method,
        headers: headers?.entries
                .map((e) => appmsg.HttpHeaderT(key: e.key, value: e.value))
                .toList() ??
            [],
        body: body,
      );

      final builder = fb.Builder(initialSize: 512);
      final message = appmsg.AppBackMessageT(
        payloadType: appmsg.AppBackPayloadTypeId.ProxyHttpRequest,
        payload: requestBuilder,
      );
      builder.finish(message.pack(builder));

      _webSocketService.send(builder.buffer);

      final response = await completer.future.timeout(timeout);

      final responseHeaders = <String, String>{};
      for (final h in response.headers ?? []) {
        if (h.key != null && h.value != null) {
          responseHeaders[h.key!.toLowerCase()] = h.value!;
        }
      }

      return http.Response.bytes(
        utf8.encode(response.body ?? ''),
        response.statusCode,
        headers: responseHeaders,
      );
    } on TimeoutException {
      throw TimeoutException('HTTP Proxy request to $url timed out after ${timeout.inSeconds} seconds.');
    } finally {
      _pendingRequests.remove(requestId);
    }
  }

  void handleResponse(backmsg.ProxyHttpResponseT response) {
    final completer = _pendingRequests.remove(response.requestId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
  }
}
