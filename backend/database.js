const sqlite3 = require('sqlite3').verbose();
const { Pool } = require('pg');
const path = require('path');

// Check if we are running with Vercel Postgres
const isPostgres = !!process.env.POSTGRES_URL;

let db;
let pool;

if (isPostgres) {
  pool = new Pool({
    connectionString: process.env.POSTGRES_URL + "?sslmode=require",
  });
  console.log('Connected to PostgreSQL database.');
  initPgDb();
} else {
  const dbPath = path.resolve(__dirname, 'expense_tracker.db');
  db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
      console.error('Error opening database ', err.message);
    } else {
      console.log('Connected to the SQLite database.');
      initSqliteDb();
    }
  });
}

function initSqliteDb() {
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      paymentMethod TEXT NOT NULL,
      description TEXT
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      amount REAL NOT NULL,
      status TEXT NOT NULL,
      razorpayOrderId TEXT,
      date TEXT NOT NULL,
      purpose TEXT NOT NULL
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS incomes (
      id TEXT PRIMARY KEY,
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      description TEXT
    )`);
  });
}

async function initPgDb() {
  try {
    const client = await pool.connect();
    try {
      await client.query(`CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        "paymentMethod" TEXT NOT NULL,
        description TEXT
      )`);

      await client.query(`CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        "razorpayOrderId" TEXT,
        date TEXT NOT NULL,
        purpose TEXT NOT NULL
      )`);

      await client.query(`CREATE TABLE IF NOT EXISTS incomes (
        id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )`);
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Error initializing Postgres DB:', err);
  }
}

// Unified interface
module.exports = {
  // Execute a query that returns rows (SELECT)
  all: (sql, params, callback) => {
    if (isPostgres) {
      // Convert ? to $1, $2, etc.
      let i = 1;
      const pgSql = sql.replace(/\?/g, () => `$${i++}`);
      
      pool.query(pgSql, params)
        .then(res => callback(null, res.rows))
        .catch(err => callback(err, null));
    } else {
      db.all(sql, params, callback);
    }
  },

  // Execute a query that modifies data (INSERT, UPDATE, DELETE)
  run: function(sql, params, callback) {
    // Note: sqlite calls callback with `this` context containing changes/lastID
    // We need to mimic that for existing code relying on `this.changes`
    
    if (isPostgres) {
      let i = 1;
      const pgSql = sql.replace(/\?/g, () => `$${i++}`);
      
      pool.query(pgSql, params)
        .then(res => {
           // Mock the sqlite context
           const context = { changes: res.rowCount, lastID: 0 }; // lastID not easily available for UUIDs/Texts
           callback.call(context, null);
        })
        .catch(err => callback(err));
    } else {
      db.run(sql, params, callback);
    }
  }
};
