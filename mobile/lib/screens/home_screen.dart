import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/incident_tracker.dart';
import '../services/app_locale.dart';
import 'monitoring_screen.dart';
import 'analysis_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserData user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final IncidentTracker _tracker = IncidentTracker();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final lang = AppLocale.currentLang;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MonitoringScreen(key: ValueKey('mon_$lang'), user: widget.user, tracker: _tracker),
          CameraScreen(key: ValueKey('cam_$lang')),
          AnalysisScreen(key: ValueKey('ana_$lang'), user: widget.user, tracker: _tracker),
          ProfileScreen(key: ValueKey('pro_$lang'), user: widget.user),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bg,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.radar, AppLocale.get('monitoring')),
                _navItem(1, Icons.videocam_rounded, AppLocale.get('camera')),
                _navItem(2, Icons.bar_chart_rounded, AppLocale.get('analysis')),
                _navItem(3, Icons.person_rounded, AppLocale.get('profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFF2563EB).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: sel
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
