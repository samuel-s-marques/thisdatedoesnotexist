import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebsocketService {
  Stream<Map<String, dynamic>> get messageStream;
  Future<void> authenticate();
  Future<void> connect();
  Future<void> disconnect();
  void send(String event, Map<String, dynamic> data);
}

class WebsocketServiceImpl implements WebsocketService {
  WebSocketChannel? _channel;
  final String _wss = const String.fromEnvironment('WSS_SERVER');
  AuthService authService = Modular.get();
  bool _isConnected = false;
  bool _isAuthenticated = false;
  Timer? _reconnectTimer;
  final int _reconnectIntervalInSeconds = 5;
  StreamController<Map<String, dynamic>> messageStreamController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messageStream => messageStreamController.stream;

  @override
  Future<void> authenticate() async {
    try {
      _channel!.sink.add(
        jsonEncode({
          'type': 'auth',
          'user_id': authService.getUser()!.uid,
          'token': await authService.getToken(),
        }),
      );

      _isAuthenticated = true;
    } catch (e) {
      if (kDebugMode) {
        print('Websocket authentication error: $e');
      }
      _isAuthenticated = false;
    }
  }

  void _reconnect() {
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer.periodic(
        Duration(seconds: _reconnectIntervalInSeconds),
        (timer) async {
          if (!_isConnected || !_isAuthenticated) {
            if (kDebugMode) {
              print('Reconnecting to websocket...');
            }
            await connect();
          }
        },
      );
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _reconnect();
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('Websocket error: $error');
    }

    disconnect();
    _reconnect();
  }

  @override
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(_wss));

    await authenticate();

    _channel!.stream.listen(
      (message) async {
        final Map<String, dynamic> json = jsonDecode(message ?? {});

        if (json['message'] == 'Unauthorized.') {
          await authenticate();
        }

        messageStreamController.add(json);
      },
      onDone: () async {
        await disconnect();
        _handleDisconnection();
      },
      onError: (error) => _handleError(error),
    );

    _isConnected = true;

    if (kDebugMode) {
      print('Websocket connected');
    }
  }

  @override
  Future<void> disconnect() async {
    if (_channel != null && _channel?.sink != null) {
      await _channel!.sink.close(1001);
    }
    _isConnected = false;
    _isAuthenticated = false;
    _reconnectTimer?.cancel();
  }

  @override
  void send(String event, Map<String, dynamic> data) {
    if (_channel != null && _channel?.sink != null) {
      data['type'] = event;

      _channel!.sink.add(jsonEncode(data));
    } else {
      if (kDebugMode) {
        print('Websocket is not connected');
      }
    }
  }
}
