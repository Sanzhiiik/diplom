import 'package:flutter/material.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../services/incident_tracker.dart';
import '../widgets/adaptive_layout.dart';

class AnalysisScreen extends StatefulWidget {
  final UserData user;
  final IncidentTracker tracker;
  const AnalysisScreen({super.key, required this.user, required this.tracker});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final t = widget.tracker;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Анализ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {}))],
      ),
      body: SingleChildScrollView(child: AdaptiveBody(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Статистика
          _c(card, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Статистика происшествий', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Данные в реальном времени', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat('${t.weekCount}', 'За неделю'),
              Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
              _stat('${t.monthCount}', 'За месяц'),
              Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
              _stat('${t.todayCount}', 'Сегодня'),
            ]),
            const SizedBox(height: 28),
            const Text('График за неделю', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(height: 160, child: t.weekCount > 0
              ? _BarChart(data: t.weeklyChart, isDark: isDark)
              : _Empty(isDark: isDark)),
          ])),
          const SizedBox(height: 16),

          if (t.allIncidents.isNotEmpty) ...[
            // По зонам
            _c(card, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Статистика по зонам', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ...t.zoneStats.entries.map((e) => _zoneRow(e.key, e.value, t.allIncidents.length)),
            ])),
            const SizedBox(height: 16),

            // По опасности
            _c(card, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('По уровню опасности', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _sevRow('Высокий риск (< 5 м)', t.severityStats['danger'] ?? 0, t.allIncidents.length, const Color(0xFFEF4444)),
              const SizedBox(height: 10),
              _sevRow('Средний риск (5-10 м)', t.severityStats['warning'] ?? 0, t.allIncidents.length, const Color(0xFFF59E0B)),
            ])),
            const SizedBox(height: 16),

            // Последние
            _c(card, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Последние события', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Всего: ${t.allIncidents.length}', style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
              ]),
              const SizedBox(height: 12),
              ...t.recentIncidents(count: 5).map((i) => _incident(i, isDark)),
            ])),
          ],
          const SizedBox(height: 16),

          // Интерпретация
          _c(card, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Интерпретация уровней риска', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _risk(const Color(0xFF22C55E), 'Низкий риск:', 'Дистанция более 10 метров — безопасное расстояние'),
            const SizedBox(height: 12),
            _risk(const Color(0xFFF59E0B), 'Средний риск:', 'Дистанция 5-10 метров — требуется внимание'),
            const SizedBox(height: 12),
            _risk(const Color(0xFFEF4444), 'Высокий риск:', 'Дистанция менее 5 метров — опасная близость'),
          ])),
          const SizedBox(height: 100),
        ]),
      ))),
    );
  }

  Widget _c(Color color, Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
    child: child);

  Widget _stat(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(l, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
  ]);

  Widget _zoneRow(String zone, int count, int total) {
    final p = total > 0 ? count / total : 0.0;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(zone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('$count (${(p * 100).toInt()}%)', style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: p, backgroundColor: Theme.of(context).dividerColor,
            color: const Color(0xFF2563EB), minHeight: 6)),
      ]));
  }

  Widget _sevRow(String l, int c, int total, Color color) {
    final p = total > 0 ? c / total : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8), Text(l, style: const TextStyle(fontSize: 14)),
        ]),
        Text('$c', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: p, backgroundColor: Theme.of(context).dividerColor,
          color: color, minHeight: 6)),
    ]);
  }

  Widget _incident(Incident i, bool isDark) {
    final time = '${i.timestamp.hour.toString().padLeft(2, '0')}:${i.timestamp.minute.toString().padLeft(2, '0')}:${i.timestamp.second.toString().padLeft(2, '0')}';
    final c = i.level == ProximityLevel.danger ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: c.withOpacity(isDark ? 0.1 : 0.05), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.15))),
      child: Row(children: [
        Icon(i.level == ProximityLevel.danger ? Icons.dangerous_rounded : Icons.warning_rounded, color: c, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${i.zoneName} — ${i.distance.toStringAsFixed(1)} м', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(time, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(i.level == ProximityLevel.danger ? 'ВЫСОКИЙ' : 'СРЕДНИЙ',
            style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
    );
  }

  Widget _risk(Color c, String t, String d) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
    const SizedBox(width: 12),
    Expanded(child: RichText(text: TextSpan(
      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
      children: [
        TextSpan(text: t, style: TextStyle(fontWeight: FontWeight.w600, color: c)),
        TextSpan(text: ' $d'),
      ]))),
  ]);
}

class _Empty extends StatelessWidget {
  final bool isDark;
  const _Empty({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bar_chart_rounded, size: 40, color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
      const SizedBox(height: 8),
      Text('Пока нет данных', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
    ]));
}

class _BarChart extends StatelessWidget {
  final List<int> data;
  final bool isDark;
  const _BarChart({required this.data, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final mx = data.every((v) => v == 0) ? 1.0 : data.reduce(max).toDouble();
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final lbl = TextStyle(fontSize: 10, color: Theme.of(context).hintColor);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      SizedBox(width: 24, height: 130, child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${mx.toInt()}', style: lbl),
          Text('${(mx / 2).toInt()}', style: lbl),
          const Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ])),
      const SizedBox(width: 8),
      ...List.generate(data.length, (i) {
        final h = mx > 0 ? (data[i] / mx) * 120 : 0.0;
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(height: h, margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
          const SizedBox(height: 8),
          Text(days[i], style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
        ]));
      }),
    ]);
  }
}
