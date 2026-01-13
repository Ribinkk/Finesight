class Budget {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      category: map['category'] ?? '',
      limit: (map['limit'] ?? 0).toDouble(),
      month: map['month'] ?? 0,
      year: map['year'] ?? 0,
    );
  }
}
