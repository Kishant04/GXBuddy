import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../storage/auth_token_store.dart';
import 'realtime_event.dart';

class WebSocketService {
  WebSocketService({required AuthTokenStore tokenStore})
      : _tokenStore = tokenStore;

  final AuthTokenStore _tokenStore;
  WebSocketChannel? _channel;
  StreamController<RealtimeEvent>? _controller;

  /// Opens a WebSocket connection.
  ///
  /// Auth priority:
  /// 1. ?token=<jwt> when a JWT is stored (production).
  /// 2. ?user_id=<uuid> in debug builds (backend accepts this when DEBUG=true).
  ///
  /// Returns an empty broadcast stream if neither credential is available.
  /// Connection failures are swallowed — WebSocket is non-critical.
  Stream<RealtimeEvent> connect() {
    _controller?.close();
    _controller = StreamController<RealtimeEvent>.broadcast();

    final token = _tokenStore.token;
    final devId = kDebugMode ? AppConfig.devUserId : '';

    if ((token == null || token.isEmpty) && devId.isEmpty) {
      return _controller!.stream;
    }

    final rawUrl = _tokenStore.wsUrlOverride ?? AppConfig.wsUrl;
    final Map<String, String> queryParams = {};
    if (token != null && token.isNotEmpty) {
      queryParams['token'] = token;
    } else if (devId.isNotEmpty) {
      queryParams['user_id'] = devId;
    }

    final uri = Uri.parse(rawUrl).replace(queryParameters: queryParams);

    try {
      _channel = WebSocketChannel.connect(uri);
      // Catch async connection failures (e.g. 1008 close from server)
      // so they don't surface as unhandled exceptions.
      _channel!.ready.catchError((_) {});
      _channel!.stream.listen(
        _onFrame,
        onError: (_) => _controller?.close(),
        onDone: () => _controller?.close(),
        cancelOnError: false,
      );
    } catch (_) {
      _controller?.close();
    }

    return _controller!.stream;
  }

  void _onFrame(dynamic raw) {
    try {
      final event = RealtimeEvent.fromRaw(raw as String);
      if (event.type != RealtimeEventType.unknown) {
        _controller?.add(event);
      }
    } catch (_) {
      // ignore malformed frames
    }
  }

  /// Inject a synthetic event — used by tests and the demo trigger panel.
  void pushMockEvent(RealtimeEvent event) => _controller?.add(event);

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
