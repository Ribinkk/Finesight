const mongoose = require('mongoose');

const BudgetSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  category: { type: String, required: true },
  limit: { type: Number, required: true },
  month: { type: Number, required: true }, // 1-12
  year: { type: Number, required: true },
}, { timestamps: true });

// Compound index for faster lookups
BudgetSchema.index({ user_id: 1, category: 1, month: 1, year: 1 }, { unique: true });

module.exports = mongoose.model('Budget', BudgetSchema);
