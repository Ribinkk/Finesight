const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'finesight.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database ' + dbPath + ': ' + err.message);
  } else {
    console.log('Connected to the SQLite database.');
    initTables();
  }
});

function initTables() {
  db.serialize(() => {
    // Expenses
    db.run(`CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      title TEXT,
      amount REAL,
      category TEXT,
      date TEXT,
      paymentMethod TEXT,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Incomes
    db.run(`CREATE TABLE IF NOT EXISTS incomes (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      source TEXT,
      amount REAL,
      date TEXT,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Payments
    db.run(`CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      amount REAL,
      status TEXT,
      razorpayOrderId TEXT,
      date TEXT,
      purpose TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Budgets
    db.run(`CREATE TABLE IF NOT EXISTS budgets (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      category TEXT,
      "limit" REAL,
      month INTEGER,
      year INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Recurring Transactions
    db.run(`CREATE TABLE IF NOT EXISTS recurring_transactions (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      title TEXT,
      amount REAL,
      frequency TEXT,
      category TEXT,
      nextDate TEXT,
      isActive BOOLEAN,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Split Expenses
    db.run(`CREATE TABLE IF NOT EXISTS split_expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        amount REAL,
        payer TEXT,
        splits TEXT,
        date TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Goals
    db.run(`CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        targetAmount REAL,
        currentAmount REAL,
        deadline TEXT,
        isCompleted BOOLEAN,
        color INTEGER,
        icon INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Debts
    db.run(`CREATE TABLE IF NOT EXISTS debts (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        type TEXT,
        person TEXT,
        amount REAL,
        dueDate TEXT,
        isPaid BOOLEAN,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
  });
}

// Wrapper for async/await usage
const dbAsync = {
  all: (sql, params = []) => {
    return new Promise((resolve, reject) => {
      db.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  },
  get: (sql, params = []) => {
     return new Promise((resolve, reject) => {
      db.get(sql, params, (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  },
  run: (sql, params = []) => {
    return new Promise((resolve, reject) => {
        // Use standard function to access 'this.lastID' and 'this.changes'
      db.run(sql, params, function (err) {
        if (err) reject(err);
        else resolve({ lastID: this.lastID, changes: this.changes });
      });
    });
  }
};

module.exports = { db, dbAsync };
