
class Payment {
  final String id;
  final double amount;
  final String status; // 'pending', 'success', 'failed'
  final String? razorpayOrderId;
  final DateTime date;
  final String purpose;

  Payment({
    required this.id,
    required this.amount,
    required this.status,
    this.razorpayOrderId,
    required this.date,
    required this.purpose,
  });
}
