import 'package:flutter/services.dart';
import '../models/user_model.dart';
import 'app_settings.dart';

class AlertService {
  final AppSettings settings;
  DateTime? _lastAlertTime;
  AlertService({required this.settings});

  void checkAndAlert(SensorSnapshot snapshot) {
    if (snapshot.overallRisk == ProximityLevel.none || snapshot.overallRisk == ProximityLevel.safe) return;
    final now = DateTime.now();
    if (_lastAlertTime != null && now.difference(_lastAlertTime!).inSeconds < settings.alertCooldownSeconds) return;
    _lastAlertTime = now;
    if (snapshot.overallRisk == ProximityLevel.danger) {
      if (settings.vibrationEnabled) { HapticFeedback.heavyImpact(); Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact()); Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact()); }
      if (settings.soundEnabled) SystemSound.play(SystemSoundType.alert);
    } else if (snapshot.overallRisk == ProximityLevel.warning) {
      if (settings.vibrationEnabled) HapticFeedback.mediumImpact();
      if (settings.soundEnabled) SystemSound.play(SystemSoundType.click);
    }
  }
}
