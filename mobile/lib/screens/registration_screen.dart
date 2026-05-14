import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/app_locale.dart';
import '../widgets/adaptive_layout.dart';
import '../widgets/phone_formatter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _step = 0;
  final _keys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  String t(String key) => AppLocale.get(key);

  // Шаг 1 — Личные данные
  final _phone = TextEditingController(text: '+7 ');
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPw = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();

  // Шаг 2 — Транспорт
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _phone, _email, _password, _confirmPw,
      _lastName, _firstName, _middleName,
      _model, _plate, _year, _mileage
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_keys[_step].currentState!.validate()) {
      if (_step < 1) {
        setState(() => _step++);
      } else {
        _finish();
      }
    }
  }

  void _finish() {
    final u = UserData(
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      lastName: _lastName.text.trim(),
      firstName: _firstName.text.trim(),
      middleName: _middleName.text.trim(),
      vehicleModel: _model.text.trim(),
      plateNumber: _plate.text.trim(),
      year: int.tryParse(_year.text) ?? 2024,
      mileage: int.tryParse(_mileage.text) ?? 0,
    );
    AntiCollisionApp.of(context)!.loginUser(u);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(t('registration'),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: AdaptiveBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
              child: _stepper(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: [_step1(), _step2()][_step],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_step == 1
                    ? t('finish_registration')
                    : t('continue_btn')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepper() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _step >= 1
                ? const Color(0xFF2563EB)
                : Theme.of(context).dividerColor,
            border: _step == 0
                ? Border.all(color: const Color(0xFF2563EB), width: 2)
                : null,
          ),
        ),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _step >= 1
                  ? const Color(0xFF2563EB)
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _step1() => Form(
      key: _keys[0],
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('personal_data'),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t('create_account'),
                style: TextStyle(
                    color: Theme.of(context).hintColor, fontSize: 14)),
            const SizedBox(height: 28),
            // Телефон с форматтером
            _label(t('phone')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
              decoration: const InputDecoration(hintText: '+7 XXX XXX XX XX'),
              validator: (v) {
                if (v == null || v.replaceAll(RegExp(r'[^\d]'), '').length < 11)
                  return t('required_field');
                return null;
              },
            ),
            const SizedBox(height: 20),
            _f(t('email'), _email, 'example@mail.com',
                kb: TextInputType.emailAddress),
            _f(t('password'), _password, t('min_6_chars'),
                req: true, obs: true, min: 6),
            _f(t('confirm_password'), _confirmPw, t('repeat_password'),
                obs: true, match: _password),
            const Divider(),
            const SizedBox(height: 12),
            _f(t('last_name'), _lastName, t('last_name'), req: true),
            _f(t('first_name'), _firstName, t('first_name'), req: true),
            _f(t('middle_name'), _middleName, t('middle_name')),
          ]));

  Widget _step2() => Form(
      key: _keys[1],
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('vehicle_info'),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t('vehicle_data'),
                style: TextStyle(
                    color: Theme.of(context).hintColor, fontSize: 14)),
            const SizedBox(height: 28),
            _f(t('vehicle_model'), _model, 'Volvo FH16', req: true),
            _f(t('plate_number'), _plate, '016 UKG 16'),
            Row(children: [
              Expanded(
                  child: _f(t('year'), _year, '2024',
                      kb: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(
                  child: _f(t('mileage_km'), _mileage, '0',
                      kb: TextInputType.number)),
            ]),
          ]));

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor));

  Widget _f(String label, TextEditingController c, String hint,
      {bool req = false,
      bool obs = false,
      int? min,
      TextInputType? kb,
      TextEditingController? match}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            obscureText: obs,
            keyboardType: kb,
            decoration: InputDecoration(hintText: hint),
            validator: (v) {
              if (req && (v == null || v.trim().isEmpty))
                return t('required_field');
              if (min != null && v != null && v.length < min)
                return t('min_6_chars');
              if (match != null && v != match.text)
                return t('passwords_mismatch');
              return null;
            },
          ),
        ],
      ),
    );
  }
}
