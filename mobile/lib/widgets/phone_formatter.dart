import 'package:flutter/services.dart';

/// Форматтер номера телефона: +7 XXX XXX XX XX
/// Автоматически ставит +7 и пробелы
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Берём только цифры из нового значения
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Убираем лидирующие 7 или 8 если пользователь набирает с них
    if (digits.startsWith('7') && digits.length > 1) {
      digits = digits.substring(1);
    } else if (digits.startsWith('8') && digits.length > 1) {
      digits = digits.substring(1);
    }

    // Максимум 10 цифр после +7
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    // Форматируем: +7 XXX XXX XX XX
    final buf = StringBuffer('+7 ');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 8) buf.write(' ');
      buf.write(digits[i]);
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
