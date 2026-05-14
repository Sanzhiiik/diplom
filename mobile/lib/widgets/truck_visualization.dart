import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user_model.dart';

class TruckVisualization extends StatefulWidget {
  final SensorSnapshot snapshot;
  const TruckVisualization({super.key, required this.snapshot});

  @override
  State<TruckVisualization> createState() => _TruckVisualizationState();
}

class _TruckVisualizationState extends State<TruckVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TruckVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Пульсация только при красной зоне
    if (widget.snapshot.overallRisk == ProximityLevel.danger) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _TruckRadarPainter(
                snapshot: widget.snapshot,
                pulseValue: _pulseAnimation.value,
                isDark: isDark,
              ),
              child: Center(child: _buildTruck(isDark)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTruck(bool isDark) {
    return SizedBox(
      width: 70,
      height: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кабина
          Container(
            width: 46,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF93C5FD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 14),
                    Container(width: 8, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ],
            ),
          ),
          // Кузов
          Container(
            width: 56,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(6)),
              border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    width: 40, height: 1,
                    color: const Color(0xFF60A5FA).withOpacity(0.5),
                  ),
                  if (i < 2) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 14, height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white38 : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2))),
              Container(width: 14, height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white38 : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ],
      ),
    );
  }
}

class _TruckRadarPainter extends CustomPainter {
  final SensorSnapshot snapshot;
  final double pulseValue;
  final bool isDark;

  _TruckRadarPainter({
    required this.snapshot,
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Фон
    canvas.drawCircle(center, radius,
      Paint()..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    // Кольца
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3,
        Paint()
          ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);
    }

    _drawZone(canvas, center, radius, snapshot.front, _ZP.front);
    _drawZone(canvas, center, radius, snapshot.rear, _ZP.rear);
    _drawZone(canvas, center, radius, snapshot.left, _ZP.left);
    _drawZone(canvas, center, radius, snapshot.right, _ZP.right);

    // Обводка
    canvas.drawCircle(center, radius,
      Paint()
        ..color = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);

    _drawLabel(canvas, center, radius, 'ЛЕВАЯ', _ZP.left);
    _drawLabel(canvas, center, radius, 'ПРАВАЯ', _ZP.right);
    _drawLabel(canvas, center, radius, 'ЗАДНЯЯ ЗОНА', _ZP.rear);
  }

  void _drawZone(Canvas canvas, Offset center, double radius,
      SensorData data, _ZP position) {
    final color = data.levelColor;
    final isActive = data.detected;
    final isDanger = data.level == ProximityLevel.danger;

    double startAngle, sweepAngle;
    const innerRadius = 0.35;

    switch (position) {
      case _ZP.front:
        startAngle = -math.pi * 0.75;
        sweepAngle = math.pi * 0.5;
        break;
      case _ZP.rear:
        startAngle = math.pi * 0.25;
        sweepAngle = math.pi * 0.5;
        break;
      case _ZP.left:
        startAngle = math.pi * 0.75;
        sweepAngle = math.pi * 0.5;
        break;
      case _ZP.right:
        startAngle = -math.pi * 0.25;
        sweepAngle = math.pi * 0.5;
        break;
    }

    final inner = radius * innerRadius;
    final path = Path()
      ..moveTo(
        center.dx + inner * math.cos(startAngle),
        center.dy + inner * math.sin(startAngle))
      ..arcTo(Rect.fromCircle(center: center, radius: inner),
        startAngle, sweepAngle, false)
      ..lineTo(
        center.dx + radius * math.cos(startAngle + sweepAngle),
        center.dy + radius * math.sin(startAngle + sweepAngle))
      ..arcTo(Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle, -sweepAngle, false)
      ..close();

    // Пульсация для красной зоны
    final opacity = isDanger && isActive ? pulseValue : (isActive ? 0.35 : 0.0);
    final bgColor = isActive
        ? color.withOpacity(opacity.clamp(0.15, 0.6))
        : (isDark ? const Color(0xFF253349) : const Color(0xFFE8ECF0));

    canvas.drawPath(path, Paint()..color = bgColor);
    canvas.drawPath(path, Paint()
      ..color = isActive ? color.withOpacity(0.6) : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius,
      String text, _ZP position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    Offset offset;
    switch (position) {
      case _ZP.left:
        offset = Offset(center.dx - radius + 8, center.dy - tp.height / 2);
        break;
      case _ZP.right:
        offset = Offset(center.dx + radius - tp.width - 8, center.dy - tp.height / 2);
        break;
      case _ZP.rear:
        offset = Offset(center.dx - tp.width / 2, center.dy + radius - tp.height - 10);
        break;
      case _ZP.front:
        offset = Offset(center.dx - tp.width / 2, center.dy - radius + 10);
        break;
    }
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TruckRadarPainter old) => true;
}

enum _ZP { front, rear, left, right }
