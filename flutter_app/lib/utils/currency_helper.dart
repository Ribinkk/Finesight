import 'package:intl/intl.dart';

class CurrencyHelper {
  static String selectedCurrency = 'INR';

  static const Map<String, double> rates = {
    'INR': 1.0,
    'USD': 0.012,
    'EUR': 0.011,
    'GBP': 0.0095,
    'AUD': 0.018,
    'CAD': 0.016,
  };

  static const Map<String, String> symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AUD': 'A\$',
    'CAD': 'C\$',
  };

  static String format(double amount) {
    double converted = convert(amount);
    final format = NumberFormat.currency(symbol: symbols[selectedCurrency], decimalDigits: 2);
    return format.format(converted);
  }

  static double convert(double amountInInr) {
    // Assuming base is INR (since currently all mock data is INR)
    double rate = rates[selectedCurrency] ?? 1.0;
    return amountInInr * rate;
  }
}
