import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/income.dart';
import '../models/budget.dart';
import '../models/recurring_transaction.dart';
import '../models/split_expense.dart';
import '../models/goal.dart';

class ApiService {
  // Platform-specific base URL
  static String get baseUrl {
    if (kIsWeb) {
      if (const bool.fromEnvironment('dart.vm.product')) {
        return '/api';
      }
      return 'http://localhost:3001/api';
    } else {
      return 'http://192.168.16.158:3001/api';
    }
  }

  // --- Expenses ---
  static Future<List<Expense>> getExpenses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/expenses?user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> expensesJson = data['data'];
        return expensesJson.map((json) {
          return Expense(
            id: json['id'],
            title: json['title'],
            amount: (json['amount'] as num).toDouble(),
            category: json['category'],
            date: DateTime.parse(json['date']),
            paymentMethod: json['paymentMethod'],
            description: json['description'],
          );
        }).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      return [];
    }
  }

  static Future<void> addExpense(Expense expense, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': expense.id,
          'user_id': userId,
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date.toIso8601String(),
          'paymentMethod': expense.paymentMethod,
          'description': expense.description,
        }),
      );
      debugPrint('DEBUG: addExpense response status: ${response.statusCode}');
      debugPrint('DEBUG: addExpense response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to add expense: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  static Future<void> deleteExpense(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  // --- Payments ---
  static Future<List<Payment>> getPayments(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments?user_id=$userId'),
      );
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
      debugPrint('Error fetching payments: $e');
      return [];
    }
  }

  static Future<void> addPayment(Payment payment, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': payment.id,
          'user_id': userId,
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
  static Future<List<Income>> getIncomes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incomes?user_id=$userId'),
      );
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
      debugPrint('Error fetching incomes: $e');
      return [];
    }
  }

  static Future<void> addIncome(Income income, String userId) async {
    try {
      final incomeJson = income.toJson();
      incomeJson['user_id'] = userId;
      final response = await http.post(
        Uri.parse('$baseUrl/incomes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(incomeJson),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add income');
      }
    } catch (e) {
      debugPrint('Error adding income: $e');
      rethrow;
    }
  }

  static Future<void> deleteIncome(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/incomes/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete income');
      }
    } catch (e) {
      debugPrint('Error deleting income: $e');
      rethrow;
    }
  }

  // --- Budgets ---
  static Future<List<Budget>> getBudgets(
    String userId, {
    int? month,
    int? year,
  }) async {
    try {
      String query = 'user_id=$userId';
      if (month != null) query += '&month=$month';
      if (year != null) query += '&year=$year';

      final response = await http.get(Uri.parse('$baseUrl/budgets?$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> budgetsJson = data['data'];
        return budgetsJson.map((json) => Budget.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      debugPrint('Error fetching budgets: $e');
      return [];
    }
  }

  static Future<void> setBudget(Budget budget) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/budgets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(budget.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to set budget');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteBudget(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/budgets/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete budget');
      }
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  // --- Recurring Transactions ---
  static Future<List<RecurringTransaction>> getRecurringTransactions(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recurring?user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> recurringJson = data['data'];
        return recurringJson
            .map((json) => RecurringTransaction.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load recurring transactions');
      }
    } catch (e) {
      debugPrint('Error fetching recurring transactions: $e');
      return [];
    }
  }

  static Future<void> addRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recurring'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add recurring transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/recurring/${transaction.id}?user_id=${transaction.userId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update recurring transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteRecurringTransaction(
    String id,
    String userId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/recurring/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete recurring transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Analytics ---
  static Future<Map<String, dynamic>> getAnalytics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics?user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      return {};
    }
  }

  // --- Split Expenses ---
  static Future<List<SplitExpense>> getSplitExpenses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/splits?user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> splitsJson = data['data'];
        return splitsJson.map((json) => SplitExpense.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load split expenses');
      }
    } catch (e) {
      debugPrint('Error fetching split expenses: $e');
      return [];
    }
  }

  static Future<void> addSplitExpense(SplitExpense split) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/splits'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(split.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add split expense');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateSplitExpense(SplitExpense split) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/splits/${split.id}?user_id=${split.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(split.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update split expense');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteSplitExpense(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/splits/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete split expense');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Goals ---
  static Future<List<Goal>> getGoals(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals?user_id=$userId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> goalsJson = data['data'];
        return goalsJson.map((json) => Goal.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load goals');
      }
    } catch (e) {
      debugPrint('Error fetching goals: $e');
      return [];
    }
  }

  static Future<void> addGoal(Goal goal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/goals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(goal.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add goal');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateGoal(Goal goal) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/goals/${goal.id}?user_id=${goal.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(goal.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update goal');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteGoal(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/goals/$id?user_id=$userId'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete goal');
      }
    } catch (e) {
      rethrow;
    }
  }
}
