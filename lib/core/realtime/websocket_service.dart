import 'dart:async';
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

  /// Opens a WebSocket connection authenticated via ?token= query parameter.
  ///
  /// Returns an empty broadcast stream immediately if no token is available.
  /// Unknown or malformed frames are silently dropped.
  Stream<RealtimeEvent> connect() {
    _controller?.close();
    _controller = StreamController<RealtimeEvent>.broadcast();

    final token = _tokenStore.token;
    if (token == null || token.isEmpty) {
      return _controller!.stream;
    }

    final rawUrl = _tokenStore.wsUrlOverride ?? AppConfig.wsUrl;
    final uri = Uri.parse(rawUrl).replace(
      queryParameters: {'token': token},
    );

    try {
      _channel = WebSocketChannel.connect(uri);
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
