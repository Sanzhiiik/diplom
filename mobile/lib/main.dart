import 'package:flutter/material.dart';
import 'services/app_settings.dart';
import 'services/user_storage.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AntiCollisionApp());
}

class AntiCollisionApp extends StatefulWidget {
  const AntiCollisionApp({super.key});

  static _AntiCollisionAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AntiCollisionAppState>();

  @override
  State<AntiCollisionApp> createState() => _AntiCollisionAppState();
}

class _AntiCollisionAppState extends State<AntiCollisionApp> {
  final AppSettings settings = AppSettings();

  UserData? loggedInUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    settings.addListener(() => setState(() {}));
    _loadSavedUser();
  }

  /// При запуске — проверяем есть ли залогиненный пользователь
  Future<void> _loadSavedUser() async {
    final saved = await UserStorage.loadLoggedInUser();
    setState(() {
      loggedInUser = saved;
      _loading = false;
    });
  }

  /// Логин — сохраняем на устройство
  void loginUser(UserData user) async {
    await UserStorage.saveUser(user);
    setState(() => loggedInUser = user);
  }

  /// Выход — только снимаем флаг, данные остаются для повторного входа
  void logoutUser() async {
    await UserStorage.logout();
    setState(() => loggedInUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti-Collision',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        inputDecorationTheme: _inputTheme(false),
        elevatedButtonTheme: _buttonTheme(),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        inputDecorationTheme: _inputTheme(true),
        elevatedButtonTheme: _buttonTheme(),
      ),

      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()))
          : loggedInUser != null
              ? HomeScreen(user: loggedInUser!)
              : const LoginScreen(),
    );
  }

  InputDecorationTheme _inputTheme(bool dark) {
    final borderColor =
        dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final fillColor = dark ? const Color(0xFF1E293B) : Colors.white;
    return InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444))),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(
          color: dark
              ? const Color(0xFF475569)
              : const Color(0xFFCBD5E1)),
    );
  }

  ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    );
  }
}
