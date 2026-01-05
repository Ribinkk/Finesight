const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// --- Expenses API ---

// GET all expenses
app.get('/expenses', (req, res) => {
  db.all('SELECT * FROM expenses ORDER BY date DESC', [], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new expense
app.post('/expenses', (req, res) => {
  const { id, title, amount, category, date, paymentMethod, description } = req.body;
  const sql = 'INSERT INTO expenses (id, title, amount, category, date, paymentMethod, description) VALUES (?,?,?,?,?,?,?)';
  const params = [id, title, amount, category, date, paymentMethod, description];
  
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

// DELETE expense
app.delete('/expenses/:id', (req, res) => {
  const sql = 'DELETE FROM expenses WHERE id = ?';
  db.run(sql, req.params.id, function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ message: 'deleted', changes: this.changes });
  });
});

// --- Payments API ---

// GET all payments
app.get('/payments', (req, res) => {
  db.all('SELECT * FROM payments ORDER BY date DESC', [], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new payment
app.post('/payments', (req, res) => {
  const { id, amount, status, razorpayOrderId, date, purpose } = req.body;
  const sql = 'INSERT INTO payments (id, amount, status, razorpayOrderId, date, purpose) VALUES (?,?,?,?,?,?)';
  const params = [id, amount, status, razorpayOrderId, date, purpose];
  
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

// GET all incomes
app.get('/incomes', (req, res) => {
  db.all('SELECT * FROM incomes ORDER BY date DESC', [], (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ data: rows });
  });
});

// POST new income
app.post('/incomes', (req, res) => {
  const { id, source, amount, date, description } = req.body;
  const sql = 'INSERT INTO incomes (id, source, amount, date, description) VALUES (?,?,?,?,?)';
  const params = [id, source, amount, date, description];
  
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

// DELETE income
app.delete('/incomes/:id', (req, res) => {
  const sql = 'DELETE FROM incomes WHERE id = ?';
  db.run(sql, req.params.id, function (err) {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.json({ message: 'deleted', changes: this.changes });
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
