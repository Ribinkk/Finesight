const http = require('http');
const BASE = 'http://localhost:3001/api';
const USER_ID = 'wRSGWqInjKOmqYEWk4Y5Kuf6NBo2';

function post(path, data) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(data);
    const url = new URL(BASE + path);
    const opts = { hostname: url.hostname, port: url.port, path: url.pathname, method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) } };
    const req = http.request(opts, (res) => {
      let d = ''; res.on('data', (c) => (d += c));
      res.on('end', () => { console.log(`  ${res.statusCode===200?'✅':'❌'} ${path} -> ${res.statusCode}`); resolve(d); });
    });
    req.on('error', reject); req.write(body); req.end();
  });
}
function d(daysAgo) { const dt = new Date(); dt.setDate(dt.getDate() - daysAgo); return dt.toISOString(); }
function id() { return Date.now().toString() + Math.random().toString(36).substr(2,6); }

async function seed() {
  console.log('📦 Expenses:');
  const expenses = [
    { title: 'Swiggy Order', amount: 450, category: 'Food', paymentMethod: 'UPI', daysAgo: 0 },
    { title: 'Zomato Dinner', amount: 680, category: 'Food', paymentMethod: 'UPI', daysAgo: 1 },
    { title: 'Chai & Snacks', amount: 120, category: 'Food', paymentMethod: 'Cash', daysAgo: 2 },
    { title: 'Biriyani House', amount: 350, category: 'Food', paymentMethod: 'UPI', daysAgo: 3 },
    { title: 'Coffee Shop', amount: 280, category: 'Food', paymentMethod: 'Card', daysAgo: 5 },
    { title: 'Uber Ride', amount: 230, category: 'Transport', paymentMethod: 'UPI', daysAgo: 0 },
    { title: 'Metro Recharge', amount: 500, category: 'Transport', paymentMethod: 'UPI', daysAgo: 4 },
    { title: 'Ola Auto', amount: 150, category: 'Transport', paymentMethod: 'Cash', daysAgo: 6 },
    { title: 'Petrol', amount: 1200, category: 'Transport', paymentMethod: 'Card', daysAgo: 7 },
    { title: 'Amazon Purchase', amount: 1999, category: 'Shopping', paymentMethod: 'Card', daysAgo: 1 },
    { title: 'Flipkart Sale', amount: 3499, category: 'Shopping', paymentMethod: 'UPI', daysAgo: 3 },
    { title: 'Myntra Clothes', amount: 1850, category: 'Shopping', paymentMethod: 'Card', daysAgo: 8 },
    { title: 'Electricity Bill', amount: 1800, category: 'Bills', paymentMethod: 'UPI', daysAgo: 2 },
    { title: 'WiFi Bill', amount: 699, category: 'Bills', paymentMethod: 'UPI', daysAgo: 5 },
    { title: 'Mobile Recharge', amount: 399, category: 'Bills', paymentMethod: 'UPI', daysAgo: 7 },
    { title: 'Netflix', amount: 649, category: 'Entertainment', paymentMethod: 'Card', daysAgo: 1 },
    { title: 'Movie Tickets', amount: 550, category: 'Entertainment', paymentMethod: 'UPI', daysAgo: 4 },
    { title: 'Spotify Premium', amount: 119, category: 'Entertainment', paymentMethod: 'Card', daysAgo: 6 },
    { title: 'Doctor Visit', amount: 800, category: 'Health', paymentMethod: 'Cash', daysAgo: 3 },
    { title: 'Pharmacy', amount: 450, category: 'Health', paymentMethod: 'UPI', daysAgo: 5 },
    { title: 'Gym Membership', amount: 1500, category: 'Health', paymentMethod: 'Card', daysAgo: 9 },
    { title: 'Udemy Course', amount: 499, category: 'Education', paymentMethod: 'Card', daysAgo: 2 },
    { title: 'Books', amount: 750, category: 'Education', paymentMethod: 'UPI', daysAgo: 6 },
    { title: 'BigBasket', amount: 2300, category: 'Groceries', paymentMethod: 'UPI', daysAgo: 0 },
    { title: 'Vegetables', amount: 650, category: 'Groceries', paymentMethod: 'Cash', daysAgo: 3 },
    { title: 'D-Mart', amount: 1800, category: 'Groceries', paymentMethod: 'Card', daysAgo: 7 },
    { title: 'Room Rent', amount: 12000, category: 'Rent', paymentMethod: 'UPI', daysAgo: 1 },
    { title: 'Water Bill', amount: 200, category: 'Utilities', paymentMethod: 'UPI', daysAgo: 4 },
    { title: 'Gas Cylinder', amount: 900, category: 'Utilities', paymentMethod: 'Cash', daysAgo: 8 },
    // Last month
    { title: 'Swiggy', amount: 520, category: 'Food', paymentMethod: 'UPI', daysAgo: 35 },
    { title: 'Restaurant', amount: 1200, category: 'Food', paymentMethod: 'Card', daysAgo: 38 },
    { title: 'Ola Ride', amount: 340, category: 'Transport', paymentMethod: 'UPI', daysAgo: 32 },
    { title: 'Amazon', amount: 2500, category: 'Shopping', paymentMethod: 'Card', daysAgo: 40 },
    { title: 'Electricity', amount: 1600, category: 'Bills', paymentMethod: 'UPI', daysAgo: 36 },
    { title: 'Rent', amount: 12000, category: 'Rent', paymentMethod: 'UPI', daysAgo: 33 },
    { title: 'Groceries', amount: 3200, category: 'Groceries', paymentMethod: 'UPI', daysAgo: 37 },
    { title: 'Gym', amount: 1500, category: 'Health', paymentMethod: 'Card', daysAgo: 39 },
  ];
  for (const e of expenses) {
    await post('/expenses', { id: id(), user_id: USER_ID, title: e.title, amount: e.amount,
      category: e.category, date: d(e.daysAgo), paymentMethod: e.paymentMethod, description: `Mock: ${e.title}` });
  }

  console.log('\n💰 Incomes:');
  const incomes = [
    { source: 'Monthly Salary', amount: 65000, daysAgo: 1 },
    { source: 'Freelance Project', amount: 15000, daysAgo: 5 },
    { source: 'Stock Dividend', amount: 2500, daysAgo: 8 },
    { source: 'Last Month Salary', amount: 65000, daysAgo: 32 },
  ];
  for (const i of incomes) {
    await post('/incomes', { id: id(), user_id: USER_ID, source: i.source, amount: i.amount,
      date: d(i.daysAgo), description: `Mock: ${i.source}` });
  }

  console.log('\n📊 Budgets:');
  const now = new Date();
  const budgets = [
    { category: 'Food', limit: 5000 }, { category: 'Transport', limit: 3000 },
    { category: 'Shopping', limit: 5000 }, { category: 'Entertainment', limit: 2000 },
    { category: 'Groceries', limit: 6000 },
  ];
  for (const b of budgets) {
    await post('/budgets', { id: id(), user_id: USER_ID, category: b.category, limit: b.limit,
      month: now.getMonth() + 1, year: now.getFullYear() });
  }

  console.log('\n🔄 Recurring:');
  const recurring = [
    { title: 'Netflix', amount: 649, frequency: 'Monthly', category: 'Entertainment' },
    { title: 'Spotify', amount: 119, frequency: 'Monthly', category: 'Entertainment' },
    { title: 'Gym', amount: 1500, frequency: 'Monthly', category: 'Health' },
    { title: 'Cloud Storage', amount: 130, frequency: 'Monthly', category: 'Bills' },
  ];
  for (const r of recurring) {
    const next = new Date(); next.setMonth(next.getMonth() + 1);
    await post('/recurring', { id: id(), user_id: USER_ID, title: r.title, amount: r.amount,
      frequency: r.frequency, category: r.category, nextDate: next.toISOString(), isActive: true });
  }

  console.log('\n🎉 All done! Hot restart the Flutter app.');
}
seed().catch(console.error);
