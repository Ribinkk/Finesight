const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${new Date().toISOString()} ${req.method} ${req.url} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Helper for Promisified DB
function dbAll(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

function dbRun(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
}

const router = express.Router();

// --- Expenses ---
router.get('/expenses', async (req, res) => {
  const userId = req.query.user_id;
  if (!userId) return res.status(400).json({ error: 'user_id required' });
  try {
    const rows = await dbAll('SELECT * FROM expenses WHERE user_id = ? ORDER BY date DESC', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/expenses', async (req, res) => {
  const { id, user_id, title, amount, category, date, paymentMethod, description } = req.body;
  try {
    await dbRun(
      'INSERT INTO expenses (id, user_id, title, amount, category, date, paymentMethod, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, title, amount, category, date, paymentMethod, description || '']
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/expenses/:id', async (req, res) => {
  const userId = req.query.user_id;
  try {
    await dbRun('DELETE FROM expenses WHERE id = ? AND user_id = ?', [req.params.id, userId]);
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Payments ---
router.get('/payments', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM payments WHERE user_id = ? ORDER BY date DESC', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/payments', async (req, res) => {
  const { id, user_id, amount, status, razorpayOrderId, date, purpose } = req.body;
  try {
    await dbRun(
      'INSERT INTO payments (id, user_id, amount, status, razorpayOrderId, date, purpose) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, amount, status, razorpayOrderId, date, purpose]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Incomes ---
router.get('/incomes', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM incomes WHERE user_id = ? ORDER BY date DESC', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/incomes', async (req, res) => {
  const { id, user_id, source, amount, date, description } = req.body;
  try {
    await dbRun(
      'INSERT INTO incomes (id, user_id, source, amount, date, description) VALUES (?, ?, ?, ?, ?, ?)',
      [id, user_id, source, amount, date, description]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Budgets ---
router.get('/budgets', async (req, res) => {
  const { user_id, month, year } = req.query;
  try {
    const rows = await dbAll(
      'SELECT * FROM budgets WHERE user_id = ? AND month = ? AND year = ?',
      [user_id, month, year]
    );
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/budgets', async (req, res) => {
  const { id, user_id, category, limit, month, year } = req.body;
  try {
    await dbRun(
      'INSERT OR REPLACE INTO budgets (id, user_id, category, "limit", month, year) VALUES (?, ?, ?, ?, ?, ?)',
      [id || Date.now().toString(), user_id, category, limit, month, year]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Recurring Transactions ---
router.get('/recurring', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM recurring_transactions WHERE user_id = ?', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/recurring', async (req, res) => {
  const { id, user_id, title, amount, category, frequency, nextDate, description } = req.body;
  try {
    await dbRun(
      'INSERT INTO recurring_transactions (id, user_id, title, amount, category, frequency, nextDate, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, title, amount, category, frequency, nextDate, description]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Split Expenses ---
router.get('/splits', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM split_expenses WHERE user_id = ?', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/splits', async (req, res) => {
  const { id, user_id, description, totalAmount, payer, splits, date } = req.body;
  try {
    await dbRun(
      'INSERT INTO split_expenses (id, user_id, description, totalAmount, payer, splits, date) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, description, totalAmount, payer, JSON.stringify(splits), date]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Goals ---
router.get('/goals', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM goals WHERE user_id = ?', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/goals', async (req, res) => {
  const { id, user_id, title, targetAmount, currentAmount, deadline, color } = req.body;
  try {
    await dbRun(
      'INSERT OR REPLACE INTO goals (id, user_id, title, targetAmount, currentAmount, deadline, color) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, title, targetAmount, currentAmount, deadline, color]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Analytics ---
router.get('/analytics', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const expenses = await dbAll('SELECT * FROM expenses WHERE user_id = ?', [userId]);
    const categoryTotals = {};
    const monthlyTrends = {};
    
    expenses.forEach(e => {
        categoryTotals[e.category] = (categoryTotals[e.category] || 0) + e.amount;
        const d = new Date(e.date);
        const key = `${d.getFullYear()}-${d.getMonth() + 1}`;
        monthlyTrends[key] = (monthlyTrends[key] || 0) + e.amount;
    });
    
    res.json({ data: { categoryTotals, monthlyTrends } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.use('/api', router);

// Root route for health check
app.get('/', (req, res) => {
  res.json({ status: 'Finesight API is running' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
