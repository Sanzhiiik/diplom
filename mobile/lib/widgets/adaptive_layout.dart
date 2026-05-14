import 'package:flutter/material.dart';

/// Хелпер для адаптивной вёрстки
class Adaptive {
  /// Это планшет? (ширина > 600)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  /// Максимальная ширина контента (на планшете — по центру)
  static double contentWidth(BuildContext context) =>
      isTablet(context) ? 500 : double.infinity;

  /// Горизонтальные отступы
  static double horizontalPadding(BuildContext context) =>
      isTablet(context) ? 40 : 16;
}

/// Обёртка которая центрирует контент на планшете
class AdaptiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AdaptiveBody({
    super.key,
    required this.child,
    this.maxWidth = 540,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
