const mongoose = require('mongoose');

const GoalSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  user_id: { type: String, required: true, index: true },
  title: { type: String, required: true },
  targetAmount: { type: Number, required: true },
  currentAmount: { type: Number, required: true },
  deadline: { type: String, required: true },
  color: { type: Number, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Goal', GoalSchema);
