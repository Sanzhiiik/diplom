import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/user_model.dart';

class SensorService {
  static const String _wsUrl = 'ws://172.20.10.8:8000/ws/app';
  static const double _maxRangeM = 4.0;

  final StreamController<SensorSnapshot> _snapshotController =
      StreamController<SensorSnapshot>.broadcast();

  Stream<SensorSnapshot> get sensorStream => _snapshotController.stream;

  WebSocketChannel? _channel;
  bool _disposed = false;
  SensorSnapshot _lastSnapshot = SensorSnapshot.empty();
  SensorSnapshot get lastSnapshot => _lastSnapshot;

  void startMonitoring() {
    _connect();
  }

  void stopMonitoring() {
    _channel?.sink.close();
  }

  void _connect() {
    if (_disposed) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _channel!.stream.listen(
        (message) {
          try {
            final data =
                jsonDecode(message as String) as Map<String, dynamic>;
            final snapshot = _parseEsp32Json(data);
            _lastSnapshot = snapshot;
            if (!_snapshotController.isClosed) {
              _snapshotController.add(snapshot);
            }
          } catch (e) {
            print('[SENSOR] ошибка парсинга: $e');
          }
        },
        onDone: () {
          print('[SENSOR] соединение закрыто — переподключаюсь');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 3), _connect);
          }
        },
        onError: (e) {
          print('[SENSOR] ошибка: $e');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 3), _connect);
          }
        },
      );
    } catch (e) {
      print('[SENSOR] не удалось подключиться: $e');
      if (!_disposed) {
        Future.delayed(const Duration(seconds: 3), _connect);
      }
    }
  }

  SensorSnapshot _parseEsp32Json(Map<String, dynamic> data) {
    final readings = (data['readings'] as Map<String, dynamic>?) ?? {};

    SensorData buildZone(String zone, String zoneName) {
      final distCm = (readings[zone] as num?)?.toDouble();
      if (distCm == null || distCm < 0) {
        return SensorData(zone: zone, zoneName: zoneName);
      }
      final distM = distCm / 100.0;
      return SensorData(
        zone: zone,
        zoneName: zoneName,
        distance: distM,
        detected: distM <= _maxRangeM,
      );
    }

    return SensorSnapshot(
      front: SensorData(zone: 'front', zoneName: 'Передняя'),
      rear:  buildZone('rear',  'Задняя'),  // ← теперь читает данные
      left:  buildZone('left',  'Левая'),
      right: buildZone('right', 'Правая'),
      timestamp: DateTime.now(),
    );
  }

  void updateSensorData(SensorSnapshot snapshot) {
    _lastSnapshot = snapshot;
    if (!_snapshotController.isClosed) {
      _snapshotController.add(snapshot);
    }
  }

  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _snapshotController.close();
  }
}