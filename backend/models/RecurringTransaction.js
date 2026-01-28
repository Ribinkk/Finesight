const mongoose = require('mongoose');

const RecurringTransactionSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  title: { type: String, required: true },
  amount: { type: Number, required: true },
  category: { type: String, required: true },
  frequency: { type: String, required: true },
  nextDate: { type: String, required: true },
  description: String,
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('RecurringTransaction', RecurringTransactionSchema);
