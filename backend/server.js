const express = require('express');
const cors = require('cors');
const connectDB = require('./database_mongo');
require('dotenv').config();
const { GoogleGenerativeAI } = require("@google/generative-ai");
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const cron = require('node-cron');

// Models
const Expense = require('./models/Expense');
const Income = require('./models/Income');
const Budget = require('./models/Budget');
const RecurringTransaction = require('./models/RecurringTransaction');
const SplitExpense = require('./models/SplitExpense');
const Goal = require('./models/Goal');
const Debt = require('./models/Debt');
const Payment = require('./models/Payment');

// Connect to Database
connectDB();

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Security Middleware
app.use(helmet());
app.use(compression());

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' }
});
app.use(limiter);

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${new Date().toISOString()} ${req.method} ${req.url} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Cron Job: Run every day at midnight to process recurring transactions
cron.schedule('0 0 * * *', async () => {
  console.log('Running Recurring Transaction Job...');
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const recurring = await RecurringTransaction.find({ isActive: true });

    for (const r of recurring) {
        if (!r.nextDate) continue;
        const nextDate = new Date(r.nextDate);
        nextDate.setHours(0, 0, 0, 0);

        if (nextDate <= today) {
            // Process the transaction
            const expenseData = {
                user_id: r.userId,
                title: r.title,
                amount: r.amount,
                category: r.category,
                date: new Date().toISOString(),
                paymentMethod: 'Recurring',
                description: `Recurring: ${r.frequency}`
            };
            await Expense.create(expenseData);
            console.log(`Processed recurring expense: ${r.title}`);

            // Calculate next date
            let newDate = new Date(nextDate);
            if (r.frequency === 'Daily') newDate.setDate(newDate.getDate() + 1);
            else if (r.frequency === 'Weekly') newDate.setDate(newDate.getDate() + 7);
            else if (r.frequency === 'Monthly') newDate.setMonth(newDate.getMonth() + 1);
            else if (r.frequency === 'Yearly') newDate.setFullYear(newDate.getFullYear() + 1);

            r.nextDate = newDate.toISOString();
            await r.save();
        }
    }
  } catch (err) {
    console.error('Error in Recurring Job:', err);
  }
});

const router = express.Router();

// --- Expenses Routes ---
router.get('/expenses', async (req, res) => {
    try {
        const { user_id } = req.query;
        if (!user_id) return res.status(400).json({ error: 'User ID required' });
        const expenses = await Expense.find({ user_id }).sort({ date: -1 });
        res.json({ data: expenses });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch expenses' });
    }
});

router.post('/expenses', [
    body('title').notEmpty().trim().escape(),
    body('amount').isNumeric(),
    body('date').isISO8601()
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    
    try {
        const expense = await Expense.create(req.body);
        res.json({ data: expense });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add expense' });
    }
});

// Update Expense
router.put('/expenses/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        const updated = await Expense.findOneAndUpdate(
            { id: req.params.id, user_id },
            req.body,
            { new: true }
        );
        if (!updated) return res.status(404).json({ error: 'Expense not found' });
        res.json({ data: updated });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update expense' });
    }
});

router.delete('/expenses/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await Expense.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete expense' });
    }
});

// --- Incomes Routes ---
router.get('/incomes', async (req, res) => {
    try {
        const { user_id } = req.query;
        const incomes = await Income.find({ user_id }).sort({ date: -1 });
        res.json({ data: incomes });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch incomes' });
    }
});

router.post('/incomes', async (req, res) => {
    try {
        const income = await Income.create(req.body);
        res.json({ data: income });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add income' });
    }
});

router.delete('/incomes/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await Income.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete income' });
    }
});

// --- Recurring Routes ---
router.get('/recurring', async (req, res) => {
    try {
        const { user_id } = req.query;
        const recurring = await RecurringTransaction.find({ user_id });
        res.json({ data: recurring });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch recurring transactions' });
    }
});

router.post('/recurring', async (req, res) => {
    try {
        const recurring = await RecurringTransaction.create(req.body);
        res.json({ data: recurring });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add recurring transaction' });
    }
});

router.put('/recurring/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        const updated = await RecurringTransaction.findOneAndUpdate(
            { id: req.params.id, user_id },
            req.body,
            { new: true }
        );
        res.json({ data: updated });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update recurring transaction' });
    }
});

router.delete('/recurring/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await RecurringTransaction.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete recurring transaction' });
    }
});

// --- Budgets Routes ---
router.get('/budgets', async (req, res) => {
    try {
        const { user_id, month, year } = req.query;
        const query = { user_id };
        if (month) query.month = month;
        if (year) query.year = year;
        const budgets = await Budget.find(query);
        res.json({ data: budgets });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch budgets' });
    }
});

router.post('/budgets', async (req, res) => {
    try {
        const { id, user_id, category, limit, month, year } = req.body;
        // Upsert budget
        const budget = await Budget.findOneAndUpdate(
            { user_id, category, month, year },
            { 
                limit,
                $setOnInsert: { id: id || Date.now().toString() }
            },
            { new: true, upsert: true }
        );
        res.json({ data: budget });
    } catch (err) {
        res.status(500).json({ error: 'Failed to set budget' });
    }
});

router.delete('/budgets/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await Budget.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete budget' });
    }
});

// --- Split Expenses Routes ---
router.get('/splits', async (req, res) => {
    try {
        const { user_id } = req.query;
        const splits = await SplitExpense.find({ user_id });
        res.json({ data: splits });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch split expenses' });
    }
});

router.post('/splits', async (req, res) => {
    try {
        const splitData = {
            ...req.body,
            id: req.body.id || Date.now().toString()
        };
        const split = await SplitExpense.create(splitData);
        res.json({ data: split });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add split expense' });
    }
});

router.put('/splits/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        const updated = await SplitExpense.findOneAndUpdate(
            { id: req.params.id, user_id },
            req.body,
            { new: true }
        );
        res.json({ data: updated });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update split expense' });
    }
});

router.delete('/splits/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await SplitExpense.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete split expense' });
    }
});

// --- Goals Routes ---
router.get('/goals', async (req, res) => {
    try {
        const { user_id } = req.query;
        const goals = await Goal.find({ user_id });
        res.json({ data: goals });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch goals' });
    }
});

router.post('/goals', async (req, res) => {
    try {
        const goal = await Goal.create(req.body);
        res.json({ data: goal });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add goal' });
    }
});

router.put('/goals/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        const updated = await Goal.findOneAndUpdate(
            { id: req.params.id, user_id },
            req.body,
            { new: true }
        );
        res.json({ data: updated });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update goal' });
    }
});

router.delete('/goals/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await Goal.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete goal' });
    }
});

// --- Debts Routes ---
router.get('/debts', async (req, res) => {
    try {
        const { user_id } = req.query;
        const debts = await Debt.find({ user_id });
        res.json({ data: debts });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch debts' });
    }
});

router.post('/debts', async (req, res) => {
    try {
        const debt = await Debt.create(req.body);
        res.json({ data: debt });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add debt' });
    }
});

router.put('/debts/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        const updated = await Debt.findOneAndUpdate(
            { id: req.params.id, user_id },
            req.body,
            { new: true }
        );
        res.json({ data: updated });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update debt' });
    }
});

router.delete('/debts/:id', async (req, res) => {
    try {
        const { user_id } = req.query;
        await Debt.findOneAndDelete({ id: req.params.id, user_id });
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete debt' });
    }
});

// --- Payments Routes ---
router.get('/payments', async (req, res) => {
    try {
        const { user_id } = req.query;
        const payments = await Payment.find({ user_id }).sort({ date: -1 });
        res.json({ data: payments });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch payments' });
    }
});

router.post('/payments', async (req, res) => {
    try {
        const payment = await Payment.create(req.body);
        res.json({ data: payment });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add payment' });
    }
});

// --- Analytics ---
router.get('/analytics', async (req, res) => {
    try {
        const { user_id } = req.query;
        const expenses = await Expense.find({ user_id });
        const data = expenses.map(e => ({
            id: e.id,
            title: e.title,
            amount: e.amount,
            date: e.date,
            category: e.category
        }));
        res.json({ data });
    } catch (err) {
        res.status(500).json({ error: 'Failed to fetch analytics' });
    }
});

// --- AI Chat (Gemini) ---
router.post('/chat', async (req, res) => {
  const { message, context, user_id } = req.body;
  if (!user_id) return res.status(400).json({ error: "User ID required" });

  try {
    const model = genAI.getGenerativeModel({ 
        model: "gemini-1.5-pro",
        systemInstruction: `You are a helpful financial assistant for of Expense Tracker App. 
        You help users verify expenses, income, etc., by calling functions.
        
        If the user asks to add an expense, income, subscription, debt, or goal, you MUST return a strict JSON object with a specific structure.
        Do NOT output complex markdown or code blocks for function calls. Just output the raw JSON string if you intend to trigger an action.
        
        The allowed JSON formats for ACTIONS are:
        1. Add Expense: {"action": "add_expense", "title": "...", "amount": 123, "category": "...", "date": "ISO8601", "paymentMethod": "...", "description": "..."}
        2. Add Income: {"action": "add_income", "source": "...", "amount": 123, "date": "ISO8601", "description": "..."}
        3. Add Recurring: {"action": "add_recurring", "title": "...", "amount": 123, "frequency": "Monthly/Weekly", "category": "...", "nextDate": "ISO8601"}
        4. Add Debt: {"action": "add_debt", "type": "Owe/Owed", "person": "...", "amount": 123, "dueDate": "ISO8601"}
        5. Add Goal: {"action": "add_goal", "title": "...", "targetAmount": 123, "currentAmount": 0, "deadline": "ISO8601"}
        
        If no action is needed, just reply with plain text conversational advice.
        `
    });

    const chat = model.startChat({
        history: context ? context.map(c => {
            // Gemini history roles must alternate between 'user' and 'model'
            // 'system' is not a valid role in history when using startChat with systemInstruction
            let role = c.role;
            if (role === 'system') role = 'user';
            if (role === 'assistant') role = 'model';
            
            return {
                role: role,
                parts: [{ text: c.content }]
            };
        }).filter(c => c.role === 'user' || c.role === 'model') : []
    });

    // Ensure history alternates and starts/ends correctly if needed
    // (Simplified for now, but role mapping is the main fix)


    const result = await chat.sendMessage(message);
    const responseText = result.response.text();

    console.log("Gemini Response:", responseText);

    // Attempt to parse JSON action
    let actionData = null;
    let cleanText = responseText.trim();
    
    // Simple heuristic to extract JSON
    if (cleanText.startsWith('{') && cleanText.endsWith('}')) {
        try {
            actionData = JSON.parse(cleanText);
        } catch (e) {
            console.error("Failed to parse JSON from AI", e);
        }
    } else if (cleanText.includes('```json')) {
        const match = cleanText.match(/```json([\s\S]*?)```/);
        if (match) {
            try {
                actionData = JSON.parse(match[1]);
            } catch (e) { /* ignore */ }
        }
    }

    if (actionData && actionData.action) {
        const results = [];
        const functionName = actionData.action;
        
        try {
            if (functionName === "add_expense") {
               const expenseData = {
                  id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
                  user_id: user_id,
                  title: actionData.title,
                  amount: actionData.amount,
                  category: actionData.category,
                  date: actionData.date || new Date().toISOString(),
                  paymentMethod: actionData.paymentMethod || "Card",
                  description: actionData.description || ""
               };
               await Expense.create(expenseData);
               results.push(`✅ Added expense: ${actionData.title} - $${actionData.amount} (${actionData.category})`);

            } else if (functionName === "add_income") {
               const incomeData = {
                  id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
                  user_id: user_id,
                  source: actionData.source,
                  amount: actionData.amount,
                  date: actionData.date || new Date().toISOString(),
                  description: actionData.description || ""
               };
               await Income.create(incomeData);
               results.push(`✅ Added income: ${actionData.source} - $${actionData.amount}`);
            
            } else if (functionName === "add_recurring") {
                const subData = {
                    id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
                    user_id: user_id,
                    title: actionData.title,
                    amount: actionData.amount,
                    frequency: actionData.frequency || "Monthly",
                    category: actionData.category || "Entertainment",
                    nextDate: actionData.nextDate || new Date().toISOString(),
                    isActive: true
                };
                await RecurringTransaction.create(subData);
                results.push(`✅ Added subscription: ${actionData.title}`);
                
            } else if (functionName === "add_debt") {
                const debtData = {
                    id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
                    user_id: user_id,
                    type: actionData.type,
                    person: actionData.person,
                    amount: actionData.amount,
                    dueDate: actionData.dueDate || null,
                    isPaid: false
                };
                await Debt.create(debtData);
                results.push(`✅ Added loan: ${actionData.type} ${actionData.person}`);
                
            } else if (functionName === "add_goal") {
                const goalData = {
                    id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
                    user_id: user_id,
                    title: actionData.title,
                    targetAmount: actionData.targetAmount,
                    currentAmount: actionData.currentAmount || 0,
                    deadline: actionData.deadline || null,
                    isCompleted: false
                };
                await Goal.create(goalData);
                results.push(`✅ Added goal: ${actionData.title}`);
            }

            res.json({ reply: results.join('\n'), action_performed: true });
        } catch (dbErr) {
            console.error("DB Error:", dbErr);
            res.json({ reply: `Error: ${dbErr.message}`, action_performed: false });
        }
    } else {
        // Normal conversation
        res.json({ reply: responseText, action_performed: false });
    }

  } catch (err) {
    console.error("Chat Error Detailed:", err);
    if (err.status) {
        console.error("Status Code:", err.status);
    }
    res.status(500).json({ error: "Failed to get response from AI", details: err.message });
  }
});

// --- Receipt Scanning (Gemini) ---
router.post('/scan-receipt', async (req, res) => {
  const { imageBase64 } = req.body;
  if (!imageBase64) return res.status(400).json({ error: "Image data required" });

  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-pro" });

    const prompt = `Inspect this receipt image. Extract:
    - Merchant Name (title)
    - Total Amount (number)
    - Date (YYYY-MM-DD)
    - Category (e.g. Food, Transport, Grocery...)
    - Description
    
    Return strict JSON with keys: title, amount, date, category, description. 
    NO CODE BLOCKS. Just the JSON.`;

    const result = await model.generateContent([
        prompt,
        {
            inlineData: {
                data: imageBase64,
                mimeType: "image/jpeg"
            }
        }
    ]);
    
    let text = result.response.text().trim();
    // Cleanup markdown if present
    if (text.startsWith('```json')) text = text.replace(/^```json/, '').replace(/```$/, '');
    else if (text.startsWith('```')) text = text.replace(/^```/, '').replace(/```$/, '');

    const data = JSON.parse(text);
    res.json({ data });

  } catch (err) {
    console.error("Receipt Scan Error:", err);
    res.status(500).json({ error: "Failed to scan receipt" });
  }
});


app.get('/', (req, res) => res.send('Finesight API is running'));

app.use('/api', router); // Main entry point

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
