import 'package:flutter/material.dart';
import '../services/app_locale.dart';
import '../widgets/adaptive_layout.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _selectedCamera = 0;
  final _cameras = [
    _CameraInfo('front_cam', Icons.videocam_rounded, true),
    _CameraInfo('rear_cam', Icons.videocam_rounded, true),
    _CameraInfo('left_cam', Icons.videocam_outlined, false),
    _CameraInfo('right_cam', Icons.videocam_outlined, false),
  ];

  String t(String key) => AppLocale.get(key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cam = _cameras[_selectedCamera];

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // Хедер
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
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('video_analytics'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(t('realtime_video'),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // Статус подключения
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cam.connected
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cam.connected
                                  ? t('connected')
                                  : t('disconnected'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
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
                    // Выбор камеры
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: List.generate(_cameras.length, (i) {
                          final sel = _selectedCamera == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCamera = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  t(_cameras[i].nameKey),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Видео окно
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFF475569),
                          width: 2,
                        ),
                      ),
                      child: cam.connected
                          ? Stack(
                              children: [
                                // Плейсхолдер видеопотока
                                Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam_rounded,
                                        size: 48,
                                        color: Colors.white
                                            .withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        t('video_stream_placeholder'),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t('connect_sensor_hint'),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.3),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // LIVE индикатор
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle,
                                            color: Colors.white,
                                            size: 8),
                                        SizedBox(width: 4),
                                        Text('LIVE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Название камеры
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t(cam.nameKey),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                // Время
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 1)),
                                      builder: (_, __) {
                                        final now = DateTime.now();
                                        return Text(
                                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontFamily: 'monospace'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_off_rounded,
                                      size: 48,
                                      color:
                                          Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text(t('camera_offline'),
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.4),
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Информация о камерах
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('cameras_status'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          ..._cameras.asMap().entries.map((e) =>
                              _cameraStatusRow(e.key, e.value, isDark)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Подсказка по подключению
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(
                            isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF2563EB)
                                .withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 8),
                              Text(t('how_to_connect'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _connectStep('1', t('connect_step_1')),
                          _connectStep('2', t('connect_step_2')),
                          _connectStep('3', t('connect_step_3')),
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

  Widget _cameraStatusRow(int index, _CameraInfo cam, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            cam.icon,
            size: 20,
            color: cam.connected
                ? const Color(0xFF22C55E)
                : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(t(cam.nameKey),
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 15)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cam.connected
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : const Color(0xFF94A3B8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cam.connected ? t('online') : t('offline'),
              style: TextStyle(
                color: cam.connected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF2563EB).withOpacity(0.8))),
          ),
        ],
      ),
    );
  }
}

class _CameraInfo {
  final String nameKey;
  final IconData icon;
  final bool connected;
  _CameraInfo(this.nameKey, this.icon, this.connected);
}
