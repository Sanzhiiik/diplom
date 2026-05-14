import 'package:flutter/material.dart';
import '../main.dart';
import '../services/app_locale.dart';
import '../widgets/adaptive_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String t(String key) => AppLocale.get(key);

  @override
  Widget build(BuildContext context) {
    final app = AntiCollisionApp.of(context)!;
    final s = app.settings;
    final isDark = s.isDark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: AdaptiveBody(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appearance
                _sectionTitle(t('appearance')),
                _cardW(card, [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFF2563EB)),
                    title: Text(t('dark_theme')),
                    subtitle: Text(isDark ? t('enabled') : t('disabled'),
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                    value: isDark,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (_) => setState(() => s.toggleTheme()),
                  ),
                ]),
                const SizedBox(height: 20),

                // Alerts
                _sectionTitle(t('alerts')),
                _cardW(card, [
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB)),
                    title: Text(t('sound_alerts')),
                    subtitle: Text(t('sound_desc'), style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                    value: s.soundEnabled,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => s.setSoundEnabled(v)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration, color: Color(0xFF2563EB)),
                    title: Text(t('vibration')),
                    subtitle: Text(t('vibration_desc'), style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                    value: s.vibrationEnabled,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => s.setVibrationEnabled(v)),
                  ),
                  const Divider(height: 1),
                  _sliderTile(
                    icon: Icons.timer_outlined,
                    title: t('alert_cooldown'),
                    subtitle: '${s.alertCooldownSeconds} ${t('sec')}',
                    value: s.alertCooldownSeconds.toDouble(),
                    min: 3, max: 60, divisions: 19,
                    onChanged: (v) => setState(() => s.setAlertCooldown(v.toInt())),
                  ),
                ]),
                const SizedBox(height: 20),

                // Distance thresholds
                _sectionTitle(t('distance_thresholds')),
                _cardW(card, [
                  _sliderTile(
                    icon: Icons.dangerous_rounded,
                    title: t('high_risk_red'),
                    subtitle: '${t('less_than')} ${s.dangerThreshold.toStringAsFixed(1)} м',
                    value: s.dangerThreshold, min: 1, max: 15, divisions: 28,
                    color: const Color(0xFFEF4444),
                    onChanged: (v) => setState(() => s.setDangerThreshold(v)),
                  ),
                  const Divider(height: 1),
                  _sliderTile(
                    icon: Icons.warning_rounded,
                    title: t('medium_risk_yellow'),
                    subtitle: '${t('less_than')} ${s.warningThreshold.toStringAsFixed(1)} м',
                    value: s.warningThreshold, min: 5, max: 30, divisions: 50,
                    color: const Color(0xFFF59E0B),
                    onChanged: (v) => setState(() => s.setWarningThreshold(v)),
                  ),
                ]),
                const SizedBox(height: 20),

                // Language
                _sectionTitle(t('language')),
                _cardW(card, [
                  RadioListTile<String>(
                    title: const Text('Русский'),
                    value: 'ru', groupValue: s.language,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => s.setLanguage(v!)),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Қазақша'),
                    value: 'kz', groupValue: s.language,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => s.setLanguage(v!)),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en', groupValue: s.language,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => s.setLanguage(v!)),
                  ),
                ]),
                const SizedBox(height: 20),

                // About
                _sectionTitle(t('about_app')),
                _cardW(card, [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                    title: const Text('Anti-Collision'),
                    subtitle: Text('${t('version')} 1.0.0'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Text('Beta', style: TextStyle(
                        color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(text, style: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: Theme.of(context).hintColor, letterSpacing: 0.5)),
  );

  Widget _cardW(Color color, List<Widget> children) => Container(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(children: children),
  );

  Widget _sliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: color ?? const Color(0xFF2563EB)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ])),
        ]),
        Slider(
          value: value.clamp(min, max),
          min: min, max: max, divisions: divisions,
          activeColor: color ?? const Color(0xFF2563EB),
          onChanged: onChanged,
        ),
      ]),
    );
  }
}
