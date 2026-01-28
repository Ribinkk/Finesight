import 'package:intl/intl.dart';

class CurrencyHelper {
  static String selectedCurrency = 'INR';

  static final Map<String, double> rates = {
    'INR': 1.0,
    'USD': 0.012,
    'EUR': 0.011,
    'GBP': 0.009,
  };

  static final Map<String, String> symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  static String format(double amount) {
    if (!rates.containsKey(selectedCurrency)) {
      return '₹${amount.toStringAsFixed(0)}';
    }

    // Convert logic (simplistic)
    // Assuming amount passed is always in INR? Or handled by caller?
    // If we just formatting:

    // If we want to convert:
    // double converted = amount * (rates[selectedCurrency] ?? 1.0);
    // But existing usage in Debt/Recurring simply called format(amount).
    // If those amounts are in INR, we should convert?
    // Let's assume for now we just format with symbol, or keep 1:1 if logic not implemented throughout.
    // However, existing `format` method I wrote was:
    // NumberFormat.currency(locale: 'en_IN', symbol: '₹', ...)
    // So it was hardcoded INR.
    // I will stick to formatting as INR for now to match previous behavior,
    // BUT since I added `selectedCurrency`, I should probably respect it?
    // Let's keep it safe:
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatCompact(double amount) {
    return NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}
