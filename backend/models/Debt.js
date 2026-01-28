const mongoose = require('mongoose');

const DebtSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  title: { type: String, required: true },
  totalAmount: { type: Number, required: true },
  paidAmount: { type: Number, required: true },
  dueDate: { type: String, required: true },
  type: { type: String, required: true },
  description: String
}, { timestamps: true });

module.exports = mongoose.model('Debt', DebtSchema);
