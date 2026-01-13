import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app';

  static Future<Map<String, dynamic>> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      if (from == to) {
        return {'amount': amount, 'rate': 1.0};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/latest?amount=$amount&from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final convertedAmount = rates[to];
        // rate = convertedAmount / amount
        return {'amount': convertedAmount, 'rate': convertedAmount / amount};
      } else {
        throw Exception('Failed to convert currency');
      }
    } catch (e) {
      debugPrint('Currency conversion error: $e');
      rethrow;
    }
  }

  // Common currencies list
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'AUD',
    'CAD',
    'SGD',
    'JPY',
    'CNY',
    'CHF',
    'NZD',
  ];
}
