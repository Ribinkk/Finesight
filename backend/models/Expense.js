const mongoose = require('mongoose');

const ExpenseSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true }, // Keeping client-side ID or we can rely on _id
  user_id: { type: String, required: true, index: true },
  title: { type: String, required: true },
  amount: { type: Number, required: true },
  category: { type: String, required: true },
  date: { type: Date, required: true },
  paymentMethod: { type: String, required: true },
  description: String
}, { timestamps: true });

module.exports = mongoose.model('Expense', ExpenseSchema);
