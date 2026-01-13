class RecurringTransaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String frequency; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  final DateTime nextDate;
  final String? description;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.nextDate,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'nextDate': nextDate.toIso8601String(),
      'description': description,
      'isActive': isActive,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      frequency: map['frequency'] ?? 'Monthly',
      nextDate: DateTime.parse(map['nextDate']),
      description: map['description'],
      isActive: map['isActive'] ?? true,
    );
  }
}
