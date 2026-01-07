class Budget {
  final String id;
  final String category;
  final double limit;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? json['_id'] ?? '',
      category: json['category'] ?? '',
      limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }
}
