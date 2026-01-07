const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const Expense = require('./models/Expense');
const Payment = require('./models/Payment');
const Income = require('./models/Income');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
// Note: In Vercel, set MONGODB_URI environment variable
const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.warn('Warning: MONGODB_URI is not defined. Database connection will fail.');
} else {
  mongoose.connect(MONGODB_URI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('MongoDB connection error:', err));
}

const router = express.Router();

// --- Expenses API ---

// GET expenses for a specific user
router.get('/expenses', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  try {
    const expenses = await Expense.find({ user_id: userId }).sort({ date: -1 });
    // Transform _id to id if needed, but we are storing a custom 'id' field from frontend
    // The frontend expects { data: [...] }
    res.json({ data: expenses });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new expense
router.post('/expenses', async (req, res) => {
  try {
    const { id, user_id, title, amount, category, date, paymentMethod, description } = req.body;
    
    if (!user_id) {
       return res.status(400).json({ error: 'user_id is required' });
    }

    const newExpense = new Expense({
      id, // Client-side ID
      user_id,
      title,
      amount,
      category,
      date,
      paymentMethod,
      description
    });

    await newExpense.save();
    res.json({ message: 'success', data: newExpense });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE expense
router.delete('/expenses/:id', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
     return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  try {
    // We search by the custom 'id' field, NOT default _id
    const result = await Expense.findOneAndDelete({ id: req.params.id, user_id: userId });
    if (!result) {
      return res.status(404).json({ error: 'Expense not found' });
    }
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Payments API ---

// GET payments
router.get('/payments', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  try {
    const payments = await Payment.find({ user_id: userId }).sort({ date: -1 });
    res.json({ data: payments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new payment
router.post('/payments', async (req, res) => {
  try {
    const { id, user_id, amount, status, razorpayOrderId, date, purpose } = req.body;
    if (!user_id) {
       return res.status(400).json({ error: 'user_id is required' });
    }

    const newPayment = new Payment({
      id,
      user_id,
      amount,
      status,
      razorpayOrderId,
      date,
      purpose
    });

    await newPayment.save();
    res.json({ message: 'success', data: newPayment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Incomes API ---

// GET incomes
router.get('/incomes', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  try {
    const incomes = await Income.find({ user_id: userId }).sort({ date: -1 });
    res.json({ data: incomes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new income
router.post('/incomes', async (req, res) => {
  try {
    const { id, user_id, source, amount, date, description } = req.body;
    if (!user_id) {
       return res.status(400).json({ error: 'user_id is required' });
    }
    
    const newIncome = new Income({
      id,
      user_id,
      source,
      amount,
      date,
      description
    });
    
    await newIncome.save();
    res.json({ message: 'success', data: newIncome });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE income
router.delete('/incomes/:id', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
     return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  try {
    const result = await Income.findOneAndDelete({ id: req.params.id, user_id: userId });
    if (!result) {
      return res.status(404).json({ error: 'Income not found' });
    }
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Mount router
app.use('/api', router);
app.use('/', router);

// Export for Vercel
module.exports = app;

// Only listen if run directly (local dev)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}
