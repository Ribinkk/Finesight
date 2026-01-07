const mongoose = require('mongoose');

const PaymentSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  amount: { type: Number, required: true },
  status: { type: String, required: true },
  razorpayOrderId: String,
  date: { type: Date, required: true },
  purpose: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Payment', PaymentSchema);
