class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String? description;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.description,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      source: json['source'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
