import 'package:intl/intl.dart';

class FormatHelper {
  FormatHelper._();

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _numberFormatter = NumberFormat('#,##0.##', 'id_ID');

  static final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  static final _dateTimeFormatter =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  static final _dateInputFormatter = DateFormat('yyyy-MM-dd');

  // Rp 12.500
  static String currency(num? value) {
    if (value == null) return 'Rp 0';
    return _currencyFormatter.format(value);
  }

  // 1.234,5
  static String number(num? value) {
    if (value == null) return '0';
    return _numberFormatter.format(value);
  }

  // 12 Jan 2025
  static String date(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date);
  }

  static String dateFromString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      return _dateFormatter.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // 12 Jan 2025, 08:30
  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFormatter.format(date);
  }

  // yyyy-MM-dd (untuk Supabase)
  static String dateToInput(DateTime date) => _dateInputFormatter.format(date);

  // Parse dari string ke DateTime
  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // 12,5 kg / 6 ltr
  static String jumlahSatuan(num? jumlah, String? satuan) {
    return '${number(jumlah)} ${satuan ?? ''}';
  }
}