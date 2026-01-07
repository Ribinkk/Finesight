const mongoose = require('mongoose');

const IncomeSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  source: { type: String, required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true },
  description: String
}, { timestamps: true });

module.exports = mongoose.model('Income', IncomeSchema);
