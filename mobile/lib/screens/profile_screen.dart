import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/app_locale.dart';
import '../widgets/adaptive_layout.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserData user;
  const ProfileScreen({super.key, required this.user});

  String t(String key) => AppLocale.get(key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final appState = AntiCollisionApp.of(context)!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(t('profile'),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => appState.settings.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: AdaptiveBody(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Карточка водителя
                _cardW(card, Column(children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 2),
                    ),
                    child: Icon(Icons.person_outline_rounded,
                        size: 34,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(t('truck_driver'),
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: 16),
                  // Телефон как основной идентификатор
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB)
                          .withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_rounded,
                            color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          user.phone.isNotEmpty ? user.phone : '—',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                ])),
                const SizedBox(height: 16),

                // Контакты
                _cardW(card, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('contact_data'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _infoRow(Icons.email_outlined, t('email'),
                          user.email.isNotEmpty ? user.email : '—'),
                      _infoRow(Icons.phone_outlined, t('phone'),
                          user.phone.isNotEmpty ? user.phone : '—'),
                    ])),
                const SizedBox(height: 16),

                // Транспорт
                _cardW(card, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('vehicle_info'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                          child: const Icon(
                              Icons.local_shipping_rounded,
                              color: Color(0xFF2563EB),
                              size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(
                                  user.vehicleModel.isNotEmpty
                                      ? user.vehicleModel
                                      : '—',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(t('truck_driver'),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .hintColor)),
                            ])),
                      ]),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _detailRow(
                          t('plate_number'), user.plateNumber),
                      _detailRow(t('year'), '${user.year}'),
                      _detailRow(t('mileage'),
                          '${_formatNum(user.mileage)} км'),
                    ])),
                const SizedBox(height: 16),

                // Статистика
                Row(children: [
                  Expanded(
                      child: _cardW(
                          card,
                          Column(children: [
                            Text('${user.totalTrips}',
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(t('trips'),
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).hintColor)),
                          ]))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _cardW(
                          card,
                          Column(children: [
                            Text(
                                _formatNum(user.totalKm.toInt()),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(t('km_driven'),
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).hintColor)),
                          ]))),
                ]),
                const SizedBox(height: 16),

                // Настройки
                _cardW(
                    card,
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SettingsScreen())),
                      borderRadius: BorderRadius.circular(16),
                      child: Row(children: [
                        const Icon(Icons.settings_rounded,
                            color: Color(0xFF2563EB)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Text(t('settings'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500))),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).hintColor),
                      ]),
                    )),
                const SizedBox(height: 16),

                // Выход
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => appState.logoutUser(),
                    icon: const Icon(Icons.logout,
                        color: Color(0xFFEF4444)),
                    label: Text(t('logout'),
                        style: const TextStyle(
                            color: Color(0xFFEF4444))),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                          color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardW(Color c, Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: child);

  Widget _infoRow(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF94A3B8))),
          const Spacer(),
          Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );

  Widget _detailRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF94A3B8))),
            Text(value.isNotEmpty ? value : '—',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ]));

  String _formatNum(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }
}
