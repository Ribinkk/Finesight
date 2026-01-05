const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'expense_tracker.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database ', err.message);
  } else {
    console.log('Connected to the SQLite database.');
    initDb();
  }
});

function initDb() {
  db.serialize(() => {
    // Expenses Table
    db.run(`CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      paymentMethod TEXT NOT NULL,
      description TEXT
    )`);

    // Payments Table
    db.run(`CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      amount REAL NOT NULL,
      status TEXT NOT NULL,
      razorpayOrderId TEXT,
      date TEXT NOT NULL,
      purpose TEXT NOT NULL
    )`);

    // Incomes Table
    db.run(`CREATE TABLE IF NOT EXISTS incomes (
      id TEXT PRIMARY KEY,
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      description TEXT
    )`);
  });
}

module.exports = db;
