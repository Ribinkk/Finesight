class SplitPerson {
  String personName;
  double amountOwed;
  bool isPaid;

  SplitPerson({
    required this.personName,
    required this.amountOwed,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'amountOwed': amountOwed,
      'isPaid': isPaid,
    };
  }

  factory SplitPerson.fromMap(Map<String, dynamic> map) {
    return SplitPerson(
      personName: map['personName'] ?? '',
      amountOwed: (map['amountOwed'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
    );
  }
}

class SplitExpense {
  final String id;
  final String userId;
  final String description;
  final double totalAmount;
  final String payer;
  final List<SplitPerson> splits;
  final DateTime date;

  SplitExpense({
    required this.id,
    required this.userId,
    required this.description,
    required this.totalAmount,
    this.payer = 'You',
    required this.splits,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'description': description,
      'totalAmount': totalAmount,
      'payer': payer,
      'splits': splits.map((s) => s.toMap()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory SplitExpense.fromMap(Map<String, dynamic> map) {
    return SplitExpense(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      description: map['description'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      payer: map['payer'] ?? 'You',
      splits: (map['splits'] as List<dynamic>?)
              ?.map((s) => SplitPerson.fromMap(s))
              .toList() ?? [],
      date: DateTime.parse(map['date']),
    );
  }
}
