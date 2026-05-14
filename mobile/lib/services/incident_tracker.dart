import '../models/user_model.dart';

class Incident {
  final String id;
  final DateTime timestamp;
  final String zone;
  final String zoneName;
  final double distance;
  final ProximityLevel level;

  Incident({
    required this.id,
    required this.timestamp,
    required this.zone,
    required this.zoneName,
    required this.distance,
    required this.level,
  });
}

class IncidentTracker {
  final List<Incident> _incidents = [];
  List<Incident> get allIncidents => List.unmodifiable(_incidents);
  int _idCounter = 0;
  final Map<String, DateTime> _lastIncidentTime = {};
  static const Duration _cooldown = Duration(seconds: 10);

  void processSensorSnapshot(SensorSnapshot snapshot) {
    for (final sensor in snapshot.allZones) {
      if (sensor.detected &&
          sensor.distance != null &&
          (sensor.level == ProximityLevel.warning ||
              sensor.level == ProximityLevel.danger)) {
        _tryRecordIncident(sensor, snapshot.timestamp);
      }
    }
  }

  void _tryRecordIncident(SensorData sensor, DateTime timestamp) {
    final lastTime = _lastIncidentTime[sensor.zone];
    if (lastTime != null && timestamp.difference(lastTime) < _cooldown) return;
    _lastIncidentTime[sensor.zone] = timestamp;
    _idCounter++;
    _incidents.add(Incident(
      id: 'INC-${_idCounter.toString().padLeft(5, '0')}',
      timestamp: timestamp,
      zone: sensor.zone,
      zoneName: sensor.zoneName,
      distance: sensor.distance!,
      level: sensor.level,
    ));
  }

  int get todayCount => todayIncidents.length;
  int get weekCount => weekIncidents.length;
  int get monthCount => monthIncidents.length;

  List<Incident> get todayIncidents {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _incidents.where((i) => i.timestamp.isAfter(start)).toList();
  }

  List<Incident> get weekIncidents {
    final now = DateTime.now();
    final ws = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(ws.year, ws.month, ws.day);
    return _incidents.where((i) => i.timestamp.isAfter(start)).toList();
  }

  List<Incident> get monthIncidents {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _incidents.where((i) => i.timestamp.isAfter(start)).toList();
  }

  List<int> get weeklyChart {
    final now = DateTime.now();
    final ws = now.subtract(Duration(days: now.weekday - 1));
    final chart = List.filled(7, 0);
    for (final i in weekIncidents) {
      final d = i.timestamp.difference(DateTime(ws.year, ws.month, ws.day)).inDays;
      if (d >= 0 && d < 7) chart[d]++;
    }
    return chart;
  }

  Map<String, int> get zoneStats {
    final s = <String, int>{};
    for (final i in _incidents) s[i.zoneName] = (s[i.zoneName] ?? 0) + 1;
    return s;
  }

  Map<String, int> get severityStats {
    int d = 0, w = 0;
    for (final i in _incidents) {
      if (i.level == ProximityLevel.danger) d++;
      else w++;
    }
    return {'danger': d, 'warning': w};
  }

  List<Incident> recentIncidents({int count = 10}) {
    final sorted = List<Incident>.from(_incidents)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(count).toList();
  }
}
