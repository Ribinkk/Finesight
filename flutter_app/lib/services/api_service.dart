import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/income.dart';

class ApiService {
  // Platform-specific base URL
  // Production: Firebase Cloud Functions URL
  // Development Web: localhost
  // Development Android Emulator: 10.0.2.2
  // Development Physical Device: your computer's IP
  static String get baseUrl {
    if (kIsWeb) {
      // In production (Vercel), api is at /api
      if (const bool.fromEnvironment('dart.vm.product')) {
        // In Vercel, the API is served at /api/...
        // The rewrite rule in vercel.json handles this.
        return '/api'; 
      }
      return 'http://localhost:3001';
    } else {
      // For mobile devices, use the IP address
      // Change this to 10.0.2.2:3001 for Android emulator
      return 'http://192.168.16.158:3001';
    }
  }

  // --- Expenses ---
  static Future<List<Expense>> getExpenses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/expenses'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> expensesJson = data['data'];
        return expensesJson.map((json) {
           return Expense(
             id: json['id'],
             title: json['title'],
             amount: (json['amount'] as num).toDouble(),
             category: json['category'],
             date: DateTime.parse(json['date']), // Backend stores ISO string
             paymentMethod: json['paymentMethod'],
             description: json['description'],
           );
        }).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
      return []; // Return empty list on error for resiliency
    }
  }

  static Future<void> addExpense(Expense expense) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': expense.id,
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date.toIso8601String(),
          'paymentMethod': expense.paymentMethod,
          'description': expense.description,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  static Future<void> deleteExpense(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/expenses/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // --- Payments ---
  static Future<List<Payment>> getPayments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payments'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> paymentsJson = data['data'];
        return paymentsJson.map((json) {
          return Payment(
            id: json['id'],
            amount: (json['amount'] as num).toDouble(),
            status: json['status'],
            razorpayOrderId: json['razorpayOrderId'],
            date: DateTime.parse(json['date']),
            purpose: json['purpose'],
          );
        }).toList();
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  static Future<void> addPayment(Payment payment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': payment.id,
          'amount': payment.amount,
          'status': payment.status,
          'razorpayOrderId': payment.razorpayOrderId,
          'date': payment.date.toIso8601String(),
          'purpose': payment.purpose,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add payment');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Incomes ---
  static Future<List<Income>> getIncomes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incomes'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> incomesJson = data['data'];
        return incomesJson.map((json) {
           return Income.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load incomes');
      }
    } catch (e) {
      print('Error fetching incomes: $e');
      return [];
    }
  }

  static Future<void> addIncome(Income income) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incomes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(income.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add income');
      }
    } catch (e) {
      print('Error adding income: $e');
      rethrow;
    }
  }

  static Future<void> deleteIncome(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/incomes/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete income');
      }
    } catch (e) {
      print('Error deleting income: $e');
      rethrow;
    }
  }
}
