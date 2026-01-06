const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// --- Expenses API ---

// GET expenses for a specific user
app.get('/expenses', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  db.all('SELECT * FROM expenses WHERE user_id = ? ORDER BY date DESC', [userId], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new expense
app.post('/expenses', (req, res) => {
  console.log('POST /expenses body:', req.body);
  const { id, user_id, title, amount, category, date, paymentMethod, description } = req.body;
  
  if (!user_id) {
    console.error('Error: user_id is required');
    return res.status(400).json({ error: 'user_id is required' });
  }

  // Defensive: Ensure user_id is a string
  const safeUserId = String(user_id);
  console.log('DEBUG: safeUserId:', safeUserId, 'Type:', typeof safeUserId);

  const sql = 'INSERT INTO expenses (id, user_id, title, amount, category, date, paymentMethod, description) VALUES (?,?,?,?,?,?,?,?)';
  const params = [id, safeUserId, title, amount, category, date, paymentMethod, description];
  
  db.run(sql, params, function (err) {
    if (err) {
      console.error('Database Error:', err.message);
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({
      message: 'success',
      data: req.body,
      changes: this.changes
    });
  });
});

// DELETE expense (verify user ownership)
app.delete('/expenses/:id', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  const sql = 'DELETE FROM expenses WHERE id = ? AND user_id = ?';
  db.run(sql, [req.params.id, userId], function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ message: 'deleted', changes: this.changes });
  });
});

// --- Payments API ---

// GET payments for a specific user
app.get('/payments', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  db.all('SELECT * FROM payments WHERE user_id = ? ORDER BY date DESC', [userId], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new payment
app.post('/payments', (req, res) => {
  const { id, user_id, amount, status, razorpayOrderId, date, purpose } = req.body;
  if (!user_id) {
    return res.status(400).json({ error: 'user_id is required' });
  }
  const sql = 'INSERT INTO payments (id, user_id, amount, status, razorpayOrderId, date, purpose) VALUES (?,?,?,?,?,?,?)';
  const params = [id, user_id, amount, status, razorpayOrderId, date, purpose];
  
  db.run(sql, params, function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({
      message: 'success',
      data: req.body,
      changes: this.changes
    });
  });
});

// --- Incomes API ---

// GET incomes for a specific user
app.get('/incomes', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  db.all('SELECT * FROM incomes WHERE user_id = ? ORDER BY date DESC', [userId], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new income
app.post('/incomes', (req, res) => {
  const { id, user_id, source, amount, date, description } = req.body;
  if (!user_id) {
    return res.status(400).json({ error: 'user_id is required' });
  }
  const sql = 'INSERT INTO incomes (id, user_id, source, amount, date, description) VALUES (?,?,?,?,?,?)';
  const params = [id, user_id, source, amount, date, description];
  
  db.run(sql, params, function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({
      message: 'success',
      data: req.body,
      changes: this.changes
    });
  });
});

// DELETE income (verify user ownership)
app.delete('/incomes/:id', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }
  const sql = 'DELETE FROM incomes WHERE id = ? AND user_id = ?';
  db.run(sql, [req.params.id, userId], function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ message: 'deleted', changes: this.changes });
  });
});


// Export for Vercel
module.exports = app;

// Only listen if run directly (local dev)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}
