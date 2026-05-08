import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../config/environment.dart';
import 'realtime_event.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<RealtimeEvent>? _controller;

  Stream<RealtimeEvent> connect() {
    _controller?.close();
    _controller = StreamController<RealtimeEvent>.broadcast();

    if (Environment.isMock) {
      return _controller!.stream;
    }

    final uri = Uri.parse('${AppConfig.wsBaseUrl}/ws');
    _channel = WebSocketChannel.connect(uri);
    _channel!.stream.listen(
      (raw) {
        try {
          final event = RealtimeEvent.fromRaw(raw as String);
          _controller!.add(event);
        } catch (_) {}
      },
      onError: (_) => _controller!.close(),
      onDone: () => _controller!.close(),
    );

    return _controller!.stream;
  }

  void pushMockEvent(RealtimeEvent event) => _controller?.add(event);

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
