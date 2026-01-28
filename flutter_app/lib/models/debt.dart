class Debt {
  final String id;
  final String userId;
  final String title;
  final double totalAmount;
  final double paidAmount;
  final DateTime dueDate;
  final String type; // 'Lent' or 'Borrowed'
  final String? description;

  Debt({
    required this.id,
    required this.userId,
    required this.title,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'description': description,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate']),
      type: map['type'],
      description: map['description'],
    );
  }
}
