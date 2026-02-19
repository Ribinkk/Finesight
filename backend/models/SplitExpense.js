const mongoose = require('mongoose');

const SplitExpenseSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  description: { type: String, required: true },
  totalAmount: { type: Number, required: true },
  payer: { type: String, required: true },
  splits: { type: Array, required: true }, 
  date: { type: Date, required: true }
}, { timestamps: true });

module.exports = mongoose.model('SplitExpense', SplitExpenseSchema);
