const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
const PORT = 3001;

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
      [id, user_id, title, amount, category, date, paymentMethod, description]
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

router.delete('/incomes/:id', async (req, res) => {
  const userId = req.query.user_id;
  try {
    await dbRun('DELETE FROM incomes WHERE id = ? AND user_id = ?', [req.params.id, userId]);
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Budgets ---
router.get('/budgets', async (req, res) => {
  const userId = req.query.user_id;
  const month = req.query.month ? parseInt(req.query.month) : new Date().getMonth() + 1;
  const year = req.query.year ? parseInt(req.query.year) : new Date().getFullYear();
  try {
    const rows = await dbAll('SELECT * FROM budgets WHERE user_id = ? AND month = ? AND year = ?', [userId, month, year]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/budgets', async (req, res) => {
  const { id, user_id, category, limit, month, year } = req.body;
  try {
    // Upsert logic for SQLite
    await dbRun('DELETE FROM budgets WHERE user_id = ? AND category = ? AND month = ? AND year = ?', [user_id, category, month, year]);
    await dbRun(
      'INSERT INTO budgets (id, user_id, category, "limit", month, year) VALUES (?, ?, ?, ?, ?, ?)',
      [id, user_id, category, limit, month, year]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/budgets/:id', async (req, res) => {
  const userId = req.query.user_id;
  try {
    await dbRun('DELETE FROM budgets WHERE id = ? AND user_id = ?', [req.params.id, userId]);
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Recurring ---
router.get('/recurring', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM recurring_transactions WHERE user_id = ? ORDER BY nextDate', [userId]);
    res.json({ data: rows.map(r => ({...r, isActive: r.isActive === 1})) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/recurring', async (req, res) => {
  const { id, user_id, title, amount, category, frequency, nextDate, description, isActive } = req.body;
  try {
    await dbRun(
      'INSERT INTO recurring_transactions (id, user_id, title, amount, category, frequency, nextDate, description, isActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, title, amount, category, frequency, nextDate, description, isActive ? 1 : 0]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/recurring/:id', async (req, res) => {
  const userId = req.query.user_id;
  const { title, amount, category, frequency, nextDate, description, isActive } = req.body;
  try {
    await dbRun(
      'UPDATE recurring_transactions SET title=?, amount=?, category=?, frequency=?, nextDate=?, description=?, isActive=? WHERE id=? AND user_id=?',
      [title, amount, category, frequency, nextDate, description, isActive ? 1 : 0, req.params.id, userId]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
     res.status(500).json({ error: err.message });
  }
});

router.delete('/recurring/:id', async (req, res) => {
  const userId = req.query.user_id;
  try {
    await dbRun('DELETE FROM recurring_transactions WHERE id = ? AND user_id = ?', [req.params.id, userId]);
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Split Expenses ---
router.get('/splits', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM split_expenses WHERE user_id = ? ORDER BY date DESC', [userId]);
    // Parse the splits JSON string back to object
    const data = rows.map(row => ({
      ...row,
      splits: JSON.parse(row.splits)
    }));
    res.json({ data });
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

router.delete('/splits/:id', async (req, res) => {
   const userId = req.query.user_id;
   try {
     await dbRun('DELETE FROM split_expenses WHERE id = ? AND user_id = ?', [req.params.id, userId]);
     res.json({ message: 'deleted' });
   } catch (err) {
     res.status(500).json({ error: err.message });
   }
});

// --- Goals ---
router.get('/goals', async (req, res) => {
  const userId = req.query.user_id;
  try {
    const rows = await dbAll('SELECT * FROM goals WHERE user_id = ? ORDER BY deadline', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/goals', async (req, res) => {
  const { id, user_id, title, targetAmount, currentAmount, deadline, color } = req.body;
  try {
    await dbRun(
      'INSERT INTO goals (id, user_id, title, targetAmount, currentAmount, deadline, color) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, user_id, title, targetAmount, currentAmount, deadline, color]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/goals/:id', async (req, res) => {
  const userId = req.query.user_id;
  const { currentAmount } = req.body; // Only updating amount for now
  try {
    await dbRun(
      'UPDATE goals SET currentAmount=? WHERE id=? AND user_id=?',
      [currentAmount, req.params.id, userId]
    );
    res.json({ message: 'success', data: req.body });
  } catch (err) {
     res.status(500).json({ error: err.message });
  }
});

router.delete('/goals/:id', async (req, res) => {
  const userId = req.query.user_id;
   try {
     await dbRun('DELETE FROM goals WHERE id = ? AND user_id = ?', [req.params.id, userId]);
     res.json({ message: 'deleted' });
   } catch (err) {
     res.status(500).json({ error: err.message });
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

app.listen(PORT, () => {
  console.log(`SQLite Server running on port ${PORT}`);
});
