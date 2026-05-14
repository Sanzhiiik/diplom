import 'package:flutter/material.dart';
import 'dart:convert';

class UserData {
  String password, firstName, lastName, middleName, email, phone;
  String vehicleModel, plateNumber;
  int year, mileage, totalTrips;
  double totalKm;

  UserData({
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.middleName = '',
    this.email = '',
    this.phone = '',
    this.vehicleModel = '',
    this.plateNumber = '',
    this.year = 2024,
    this.mileage = 0,
    this.totalTrips = 0,
    this.totalKm = 0,
  });

  String get fullName {
    final p = [lastName, firstName, middleName]
        .where((s) => s.isNotEmpty)
        .toList();
    return p.isEmpty ? 'Водитель' : p.join(' ');
  }

  /// Для сохранения на устройстве
  Map<String, dynamic> toJson() => {
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'email': email,
        'phone': phone,
        'vehicle_model': vehicleModel,
        'plate_number': plateNumber,
        'year': year,
        'mileage': mileage,
        'total_trips': totalTrips,
        'total_km': totalKm,
      };

  /// Загрузка с устройства
  factory UserData.fromJson(Map<String, dynamic> j) => UserData(
        password: j['password'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        middleName: j['middle_name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        vehicleModel: j['vehicle_model'] ?? '',
        plateNumber: j['plate_number'] ?? '',
        year: j['year'] ?? 2024,
        mileage: j['mileage'] ?? 0,
        totalTrips: j['total_trips'] ?? 0,
        totalKm: (j['total_km'] ?? 0).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory UserData.fromJsonString(String s) =>
      UserData.fromJson(jsonDecode(s));

  static UserData demo() => UserData(
        password: '123456',
        firstName: 'Ильяс',
        lastName: 'Жамбылов',
        middleName: 'Серикович',
        email: 'ilyas.zhambylov@mail.ru',
        phone: '+7 701 555 1234',
        vehicleModel: 'Volvo FH16',
        plateNumber: '016 UKG 16',
        year: 2022,
        mileage: 87452,
        totalTrips: 156,
        totalKm: 38245,
      );
}

enum ProximityLevel { safe, warning, danger, none }

class SensorData {
  final String zone, zoneName;
  final double? distance;
  final bool detected;
  const SensorData(
      {required this.zone,
      required this.zoneName,
      this.distance,
      this.detected = false});

  ProximityLevel get level {
    if (!detected || distance == null) return ProximityLevel.none;
    if (distance! < 1) return ProximityLevel.danger;
    if (distance! < 2) return ProximityLevel.warning;
    return ProximityLevel.safe;
  }

  Color get levelColor {
    switch (level) {
      case ProximityLevel.safe:
        return const Color(0xFF22C55E);
      case ProximityLevel.warning:
        return const Color(0xFFF59E0B);
      case ProximityLevel.danger:
        return const Color(0xFFEF4444);
      case ProximityLevel.none:
        return const Color(0xFFCBD5E1);
    }
  }

  factory SensorData.fromJson(Map<String, dynamic> j) {
    const n = {
      'front': 'Передняя',
      'rear': 'Задняя',
      'left': 'Левая',
      'right': 'Правая'
    };
    return SensorData(
        zone: j['zone'],
        zoneName: n[j['zone']] ?? j['zone'],
        distance: (j['distance'] as num?)?.toDouble(),
        detected: j['detected'] ?? false);
  }
}

class SensorSnapshot {
  final SensorData front, rear, left, right;
  final DateTime timestamp;
  const SensorSnapshot(
      {required this.front,
      required this.rear,
      required this.left,
      required this.right,
      required this.timestamp});

  List<SensorData> get detectedZones =>
      [front, rear, left, right].where((s) => s.detected).toList();
  List<SensorData> get allZones => [front, rear, left, right];

  ProximityLevel get overallRisk {
    final l = allZones.map((z) => z.level).toList();
    if (l.contains(ProximityLevel.danger)) return ProximityLevel.danger;
    if (l.contains(ProximityLevel.warning)) return ProximityLevel.warning;
    if (l.contains(ProximityLevel.safe)) return ProximityLevel.safe;
    return ProximityLevel.none;
  }

  bool get hasBlindSpot =>
      (left.detected && left.distance != null && left.distance! < 3) ||
      (right.detected && right.distance != null && right.distance! < 3);

  factory SensorSnapshot.empty() => SensorSnapshot(
      front: const SensorData(zone: 'front', zoneName: 'Передняя'),
      rear: const SensorData(zone: 'rear', zoneName: 'Задняя'),
      left: const SensorData(zone: 'left', zoneName: 'Левая'),
      right: const SensorData(zone: 'right', zoneName: 'Правая'),
      timestamp: DateTime.now());

  factory SensorSnapshot.fromJson(Map<String, dynamic> j) {
    final z =
        (j['zones'] as List).map((x) => SensorData.fromJson(x)).toList();
    SensorData f(String n) =>
        z.firstWhere((x) => x.zone == n,
            orElse: () => SensorData(zone: n, zoneName: n));
    return SensorSnapshot(
        front: f('front'),
        rear: f('rear'),
        left: f('left'),
        right: f('right'),
        timestamp: j['timestamp'] != null
            ? DateTime.parse(j['timestamp'])
            : DateTime.now());
  }
}
