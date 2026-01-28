const mongoose = require('mongoose');

const BudgetSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  category: { type: String, required: true },
  limit: { type: Number, required: true },
  month: { type: Number, required: true },
  year: { type: Number, required: true }
}, { timestamps: true });

// Composite index for efficient querying by user, month, year
BudgetSchema.index({ user_id: 1, month: 1, year: 1 });

module.exports = mongoose.model('Budget', BudgetSchema);
