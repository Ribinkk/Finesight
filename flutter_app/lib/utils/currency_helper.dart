import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {
  static String selectedCurrency = 'INR';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCurrency = prefs.getString('currency') ?? 'INR';
  }

  static Future<void> setCurrency(String code) async {
    selectedCurrency = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', code);
  }

  static final Map<String, double> rates = {
    'INR': 1.0,
    'USD': 0.012,
    'EUR': 0.011,
    'GBP': 0.009,
    'JPY': 1.80,
    'AUD': 0.018,
    'CAD': 0.016,
    'CNY': 0.086,
    'RUB': 1.10,
    'SGD': 0.016,
    'AED': 0.044,
  };

  static final Map<String, String> symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CNY': '¥',
    'RUB': '₽',
    'SGD': 'S\$',
    'AED': 'dh',
  };

  static String format(double amount) {
    final symbol = symbols[selectedCurrency] ?? '₹';
    return NumberFormat.currency(
      locale: 'en_US', // Use generic locale but custom symbol
      symbol: symbol,
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatCompact(double amount) {
    final symbol = symbols[selectedCurrency] ?? '₹';
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 0,
    ).format(amount);
  }
}
