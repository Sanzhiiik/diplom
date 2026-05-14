import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/app_locale.dart';
import '../services/user_storage.dart';
import '../widgets/adaptive_layout.dart';
import '../widgets/phone_formatter.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneC = TextEditingController(text: '+7 ');
  final _passwordC = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _loading = false;

  String t(String key) => AppLocale.get(key);

  @override
  void dispose() {
    _phoneC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final saved = await UserStorage.loadSavedUser();

    if (!mounted) return;

    if (saved != null &&
        _normalizePhone(saved.phone) == _normalizePhone(_phoneC.text) &&
        saved.password == _passwordC.text) {
      AntiCollisionApp.of(context)!.loginUser(saved);
    } else {
      setState(() {
        _loading = false;
        _error = t('wrong_credentials');
      });
    }
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AdaptiveBody(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(t('app_name'),
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 4),
                    Text(t('app_subtitle'),
                        style: TextStyle(fontSize: 14, color: subColor)),
                    const SizedBox(height: 48),

                    // Номер телефона
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(t('phone'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: labelColor)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      decoration: InputDecoration(
                        hintText: '+7 XXX XXX XX XX',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF94A3B8)),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // Пароль
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(t('password'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: labelColor)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordC,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: t('enter_password'),
                        prefixIcon: const Icon(Icons.lock_outlined,
                            color: Color(0xFF94A3B8)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onSubmitted: (_) => _login(),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 14))),
                      ]),
                    ],

                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5))
                          : Text(t('login')),
                    ),
                    const SizedBox(height: 24),
                    Text(t('no_account'),
                        style:
                            TextStyle(color: subColor, fontSize: 14)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RegistrationScreen())),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t('register'),
                              style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF2563EB), size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
