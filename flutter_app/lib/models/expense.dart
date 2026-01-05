
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String? description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.description,
  });
}
