import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/sensor_service.dart';
import '../services/incident_tracker.dart';
import '../services/alert_service.dart';
import '../services/app_locale.dart';
import '../widgets/truck_visualization.dart';
import '../widgets/adaptive_layout.dart';

class MonitoringScreen extends StatefulWidget {
  final UserData user;
  final IncidentTracker tracker;
  const MonitoringScreen(
      {super.key, required this.user, required this.tracker});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final SensorService _sensor = SensorService();
  late AlertService _alert;
  SensorSnapshot _snap = SensorSnapshot.empty();

  String t(String key) => AppLocale.get(key);

  @override
  void initState() {
    super.initState();
    _sensor.sensorStream.listen((data) {
      if (!mounted) return;
      setState(() => _snap = data);
      widget.tracker.processSensorSnapshot(data);
      _alert.checkAndAlert(data);
    });
    _sensor.startMonitoring();
    // startDemo() удалён — используем только реальные данные
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alert =
        AlertService(settings: AntiCollisionApp.of(context)!.settings);
  }

  @override
  void dispose() {
    _sensor.dispose();
    super.dispose();
  }

  Color get _riskColor {
    switch (_snap.overallRisk) {
      case ProximityLevel.safe:    return const Color(0xFF22C55E);
      case ProximityLevel.warning: return const Color(0xFFF59E0B);
      case ProximityLevel.danger:  return const Color(0xFFEF4444);
      case ProximityLevel.none:    return const Color(0xFF94A3B8);
    }
  }

  String get _riskText {
    switch (_snap.overallRisk) {
      case ProximityLevel.safe:    return t('low');
      case ProximityLevel.warning: return t('medium');
      case ProximityLevel.danger:  return t('high');
      case ProximityLevel.none:    return t('no_data');
    }
  }

  IconData get _riskIcon {
    switch (_snap.overallRisk) {
      case ProximityLevel.safe:    return Icons.check_circle;
      case ProximityLevel.warning: return Icons.warning_rounded;
      case ProximityLevel.danger:  return Icons.dangerous_rounded;
      case ProximityLevel.none:    return Icons.sensors_off;
    }
  }

  String _zoneName(SensorData d) {
    switch (d.zone) {
      case 'front': return t('zone_front');
      case 'rear':  return t('zone_rear');
      case 'left':  return t('zone_left');
      case 'right': return t('zone_right');
      default:      return d.zoneName;
    }
  }

  String _levelText(SensorData d) {
    switch (d.level) {
      case ProximityLevel.safe:    return t('low');
      case ProximityLevel.warning: return t('medium');
      case ProximityLevel.danger:  return t('high');
      case ProximityLevel.none:    return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detected = _snap.detectedZones;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgColor   = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E3A8A)]
                      : [const Color(0xFF1E3A8A), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.radar, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('monitoring'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text('Anti-Collision System',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _snap.hasBlindSpot
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _snap.hasBlindSpot ? t('blind_spot') : t('clear'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AdaptiveBody(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Уровень риска
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _riskColor.withOpacity(isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _riskColor.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Icon(_riskIcon, color: _riskColor, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('current_risk_level'),
                                style: TextStyle(
                                    color: _riskColor.withOpacity(0.8),
                                    fontSize: 13)),
                            Text(_riskText,
                                style: TextStyle(
                                    color: _riskColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Визуализация грузовика
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: TruckVisualization(snapshot: _snap),
                    ),
                    const SizedBox(height: 16),

                    // Список зон
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Icon(Icons.wifi_tethering,
                                    size: 20, color: Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(t('proximity'),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${t('today')}: ${widget.tracker.todayCount}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (detected.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(children: [
                                  const Icon(Icons.sensors_off,
                                      size: 32, color: Color(0xFFCBD5E1)),
                                  const SizedBox(height: 8),
                                  Text(t('no_objects'),
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8))),
                                ]),
                              ),
                            )
                          else
                            ...detected.map((d) => _zoneItem(d, isDark)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneItem(SensorData d, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: d.levelColor)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(_zoneName(d),
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 15))),
        if (d.distance != null)
          Text('${d.distance!.toStringAsFixed(1)} м',
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: d.levelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: d.levelColor.withOpacity(0.3)),
          ),
          child: Text(_levelText(d),
              style: TextStyle(
                  color: d.levelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}