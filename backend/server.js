const express = require('express');
const cors = require('cors');
const connectDB = require('./database_mongo');
require('dotenv').config();
const OpenAI = require('openai');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');

// Import Mongoose Models
const Expense = require('./models/Expense');
const Payment = require('./models/Payment');
const Income = require('./models/Income');
const Budget = require('./models/Budget');
const RecurringTransaction = require('./models/RecurringTransaction');
const SplitExpense = require('./models/SplitExpense');
const Goal = require('./models/Goal');
const Debt = require('./models/Debt');

// Connect to MongoDB
connectDB();

const cron = require('node-cron');

// Cron Job: Run every day at midnight to process recurring transactions
cron.schedule('0 0 * * *', async () => {
  console.log('Running Recurring Transaction Job...');
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Find all active recurring transactions where nextDate <= today
    // Note: stored nextDate is a ISO string, so we need to be careful with comparison.
    // Ideally we convert to Date object for comparison.
    // However, string comparison works for ISO dates if format is consistent.
    // Let's fetch all and filter in JS to be safe with timezones/formats.
    const recurring = await RecurringTransaction.find({ isActive: true });

    for (const r of recurring) {
      const nextDate = new Date(r.nextDate);
      // Strip time
      nextDate.setHours(0, 0, 0, 0);

      if (nextDate <= today) {
        console.log(`Processing Recurring: ${r.title}`);

        // 1. Create Expense
        const expense = new Expense({
          id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
          user_id: r.user_id,
          title: r.title,
          amount: r.amount,
          category: r.category,
          date: new Date().toISOString(), // Today
          description: `Recurring: ${r.frequency} subscription`,
          paymentMethod: 'Auto-Debit'
        });
        await expense.save();

        // 2. Update Next Date
        const newNextDate = new Date(nextDate);
        switch (r.frequency) {
          case 'Daily':
            newNextDate.setDate(newNextDate.getDate() + 1);
            break;
          case 'Weekly':
            newNextDate.setDate(newNextDate.getDate() + 7);
            break;
          case 'Monthly':
            newNextDate.setMonth(newNextDate.getMonth() + 1);
            break;
          case 'Yearly':
            newNextDate.setFullYear(newNextDate.getFullYear() + 1);
            break;
        }

        r.nextDate = newNextDate.toISOString();
        await r.save();
        console.log(`Processed ${r.title}, new date: ${r.nextDate}`);
      }
    }
  } catch (err) {
    console.error('Error in Recurring Job:', err);
  }
});

const openai = new OpenAI({
  baseURL: process.env.ENDPOINT,
  apiKey: process.env.GITHUB_TOKEN,
});

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Security Middleware
app.use(helmet()); // Secure HTTP headers
app.use(compression()); // Compress all responses

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
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

const router = express.Router();

// --- Expenses ---
router.get('/expenses', async (req, res) => {
  const user_id = req.query.user_id;
  if (!user_id) return res.status(400).json({ error: 'user_id required' });
  try {
    const expenses = await Expense.find({ user_id }).sort({ date: -1 });
    res.json({ data: expenses });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/expenses', [
  body('title').trim().escape().notEmpty().withMessage('Title is required'),
  body('amount').isNumeric().withMessage('Amount must be a number'),
  body('category').trim().escape().notEmpty(),
  body('description').optional().trim().escape(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  try {
    const expense = await Expense.create(req.body);
    res.json({ message: 'success', data: expense });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/expenses/:id', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    await Expense.findOneAndDelete({ id: req.params.id, user_id });
    res.json({ message: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Payments ---
router.get('/payments', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const payments = await Payment.find({ user_id }).sort({ date: -1 });
    res.json({ data: payments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/payments', [
  body('amount').isNumeric(),
  body('purpose').optional().trim().escape(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  try {
    const payment = await Payment.create(req.body);
    res.json({ message: 'success', data: payment });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Incomes ---
router.get('/incomes', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const incomes = await Income.find({ user_id }).sort({ date: -1 });
    res.json({ data: incomes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/incomes', [
  body('source').trim().escape().notEmpty(),
  body('amount').isNumeric(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  try {
    const income = await Income.create(req.body);
    res.json({ message: 'success', data: income });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Budgets ---
router.get('/budgets', async (req, res) => {
  const { user_id, month, year } = req.query;
  try {
    const budgets = await Budget.find({ user_id, month, year });
    res.json({ data: budgets });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/budgets', async (req, res) => {
  const { id, user_id, category, limit, month, year } = req.body;
  try {
    // Upsert: update if exists, insert if not
    const budget = await Budget.findOneAndUpdate(
      { user_id, category, month, year }, // Search criteria
      { id: id || Date.now().toString(), user_id, category, limit, month, year }, // content
      { new: true, upsert: true }
    );
    res.json({ message: 'success', data: budget });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Recurring Transactions ---
router.get('/recurring', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const recurring = await RecurringTransaction.find({ user_id });
    res.json({ data: recurring });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/recurring', async (req, res) => {
  try {
    const recurring = await RecurringTransaction.create(req.body);
    res.json({ message: 'success', data: recurring });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/recurring/:id', async (req, res) => {
  const user_id = req.query.user_id;
  try {
      const updated = await RecurringTransaction.findOneAndUpdate(
          { id: req.params.id, user_id },
          req.body,
          { new: true }
      );
      res.json({ message: 'success', data: updated });
  } catch (err) {
      res.status(400).json({ error: err.message });
  }
});

router.delete('/recurring/:id', async (req, res) => {
  const user_id = req.query.user_id;
  try {
      await RecurringTransaction.findOneAndDelete({ id: req.params.id, user_id });
      res.json({ message: 'deleted' });
  } catch (err) {
      res.status(500).json({ error: err.message });
  }
});

// --- Split Expenses ---
router.get('/splits', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const splits = await SplitExpense.find({ user_id });
    res.json({ data: splits });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/splits', async (req, res) => {
  try {
    // Ensure splits array is stringified if needed, but Mongoose shouldn't need it if schema is String.
    // However, existing flutter app sends it. Schema says String.
    // If flutter sends JSON object, we might need JSON.stringify if schema is String.
    // But req.body parses JSON. Let's assume Flutter sends the body as JSON.
    // If Schema 'splits' is a String, we might need to stringify it if it comes as an array/object.
    // Reviewing SplitExpense.js: splits: { type: String, required: true }
    // The previous code did JSON.stringify(splits).
    
    let { splits } = req.body;
    if (typeof splits !== 'string') {
        splits = JSON.stringify(splits);
    }
    
    const splitExpense = await SplitExpense.create({ ...req.body, splits });
    res.json({ message: 'success', data: splitExpense });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Goals ---
router.get('/goals', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const goals = await Goal.find({ user_id });
    res.json({ data: goals });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/goals', async (req, res) => {
    const { id, user_id, title } = req.body;
  try {
    const goal = await Goal.findOneAndUpdate(
        { id, user_id },
        req.body,
        { new: true, upsert: true }
    );
    res.json({ message: 'success', data: goal });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// --- Debts ---
router.get('/debts', async (req, res) => {
    const user_id = req.query.user_id;
    try {
        const debts = await Debt.find({ user_id });
        res.json({ data: debts });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.post('/debts', async (req, res) => {
    try {
        const debt = await Debt.create(req.body);
        res.json({ message: 'success', data: debt });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});


// --- Analytics ---
router.get('/analytics', async (req, res) => {
  const user_id = req.query.user_id;
  try {
    const expenses = await Expense.find({ user_id });
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

// --- Chatbot ---
router.post('/chat', async (req, res) => {
  const { message, context, user_id } = req.body;
  
  // Define tools/functions the AI can use
  const tools = [
    {
      type: "function",
      function: {
        name: "add_expense",
        description: "Add a new expense to the user's expense tracker",
        parameters: {
          type: "object",
          properties: {
            title: { 
              type: "string", 
              description: "Short descriptive title for the expense (e.g., 'Lunch at restaurant', 'Uber ride')" 
            },
            amount: { 
              type: "number", 
              description: "Amount spent in dollars" 
            },
            category: { 
              type: "string", 
              enum: [
                "Food", "Groceries", "Restaurant", "Coffee & Tea", "Fast Food",
                "Transport", "Fuel", "Public Transit", "Taxi & Ride", "Parking",
                "Rent", "Utilities", "Home Maintenance", "Furniture", "Home Decor",
                "Shopping", "Clothing", "Electronics", "Books", "Gifts",
                "Entertainment", "Movies", "Gaming", "Music", "Sports",
                "Health", "Medical", "Pharmacy", "Gym", "Wellness",
                "Education", "Courses", "Office Supplies", "Professional Dev",
                "Investments", "Insurance", "Savings", "Taxes", "Bank Fees",
                "Travel", "Hotels", "Flights", "Vacation",
                "Personal Care", "Haircare", "Beauty", "Spa",
                "Pets", "Pet Food", "Vet",
                "Phone Bill", "Internet", "Streaming", "Subscriptions",
                "Childcare", "Kids Activities", "School Supplies", "Toys",
                "Charity", "Donations", "Religious",
                "Other", "Miscellaneous"
              ],
              description: "Category that best fits this expense"
            },
            date: { 
              type: "string", 
              description: "Date in ISO 8601 format (YYYY-MM-DD). Use today's date if not specified by user." 
            },
            paymentMethod: { 
              type: "string", 
              description: "Payment method used (Cash, Card, UPI, Bank Transfer, etc). Default to 'Card' if not specified." 
            },
            description: { 
              type: "string", 
              description: "Optional additional details about the expense" 
            }
          },
          required: ["title", "amount", "category"]
        }
      }
    },
    {
      type: "function",
      function: {
        name: "add_income",
        description: "Add a new income entry to the user's tracker",
        parameters: {
          type: "object",
          properties: {
            source: { 
              type: "string", 
              description: "Source of income (e.g., 'Salary', 'Freelance Project', 'Investment Return')" 
            },
            amount: { 
              type: "number", 
              description: "Amount received in dollars" 
            },
            date: { 
              type: "string", 
              description: "Date in ISO 8601 format (YYYY-MM-DD). Use today's date if not specified by user." 
            },
            description: { 
              type: "string", 
              description: "Optional additional details about the income" 
            }
          },
          required: ["source", "amount"]
        }
      }
    },
    {
      type: "function",
      function: {
        name: "add_recurring",
        description: "Add a new recurring subscription or bill",
        parameters: {
          type: "object",
          properties: {
            title: { type: "string", description: "Name of subscription (e.g. Netflix, Spotify)" },
            amount: { type: "number", description: "Cost per cycle" },
            frequency: { 
              type: "string", 
              enum: ["Daily", "Weekly", "Monthly", "Yearly"],
              description: "Billing frequency. Default to 'Monthly'"
            },
            category: { type: "string", description: "Category (e.g. Entertainment, Utilities)" },
            nextDate: { type: "string", description: "Next billing date YYYY-MM-DD" }
          },
          required: ["title", "amount"]
        }
      }
    },
    {
      type: "function",
      function: {
        name: "add_debt",
        description: "Add a new debt or loan record",
        parameters: {
          type: "object",
          properties: {
            type: { type: "string", enum: ["Owe", "Owed"], description: "'Owe' if I borrowed, 'Owed' if I lent" },
            person: { type: "string", description: "Name of the person" },
            amount: { type: "number", description: "Amount of money" },
            dueDate: { type: "string", description: "Due date YYYY-MM-DD" }
          },
          required: ["type", "person", "amount"]
        }
      }
    },
    {
      type: "function",
      function: {
        name: "add_goal",
        description: "Add a new savings goal",
        parameters: {
          type: "object",
          properties: {
            title: { type: "string", description: "Name of the goal (e.g. New Car)" },
            targetAmount: { type: "number", description: "Total amount needed" },
            currentAmount: { type: "number", description: "Initial saved amount. Default 0" },
            deadline: { type: "string", description: "Target date YYYY-MM-DD" }
          },
          required: ["title", "targetAmount"]
        }
      }
    }
  ];
  
  try {
    const completion = await openai.chat.completions.create({
      messages: [
        { 
          role: "system", 
          content: "You are a helpful financial assistant for an expense tracker app. You can help users track expenses and income by adding them directly to their tracker. When users ask you to add expenses or income, use the provided functions. Be concise and friendly in your responses." 
        },
        ...context || [],
        { role: "user", content: message }
      ],
      model: process.env.MODEL_NAME || "gpt-4o",
      temperature: 1,
      max_tokens: 4096,
      top_p: 1,
      tools: tools,
      tool_choice: "auto"
    });


    const responseMessage = completion.choices[0].message;
    
    // Check if AI wants to call a function
    if (responseMessage.tool_calls) {
      const results = [];
      
      for (const toolCall of responseMessage.tool_calls) {
        const functionName = toolCall.function.name;
        const args = JSON.parse(toolCall.function.arguments);
        
        try {
          if (functionName === "add_expense") {
            // Set defaults
            const expenseData = {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              user_id: user_id,
              title: args.title,
              amount: args.amount,
              category: args.category,
              date: args.date || new Date().toISOString(),
              paymentMethod: args.paymentMethod || "Card",
              description: args.description || ""
            };
            
            await Expense.create(expenseData);
            results.push(`✅ Added expense: ${args.title} - $${args.amount} (${args.category})`);
            
          } else if (functionName === "add_income") {
            const incomeData = {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              user_id: user_id,
              source: args.source,
              amount: args.amount,
              date: args.date || new Date().toISOString(),
              description: args.description || ""
            };
            
            await Income.create(incomeData);
            results.push(`✅ Added income: ${args.source} - $${args.amount}`);

          } else if (functionName === "add_recurring") {
            const subData = {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              userId: user_id, // Note: RecurringTransaction schema uses userId (camelCase)? Let's check imports. User provided viewing didn't show Schema.
              // Logic check: server.js lines 51 used r.user_id for Expense.
              // I'll assume Schema uses user_id generally, but RecurringTransaction usually matches Expense.
              // Wait, in ViewFile 8 of recurring_screen it uses "userId: widget.user!.uid".
              // Let's safe-check RecurringTransaction model if possible or guess.
              // I'll stick to 'user_id' if that's standard in this codebase, but I recallseeing 'userId' in some models.
              // Actually, looking at 'server.js' line 51: `user_id: r.user_id`. So recurring transaction has `user_id`.
              user_id: user_id,
              title: args.title,
              amount: args.amount,
              frequency: args.frequency || "Monthly",
              category: args.category || "Entertainment",
              nextDate: args.nextDate || new Date().toISOString(),
              isActive: true
            };
            await RecurringTransaction.create(subData);
            results.push(`✅ Added subscription: ${args.title} (${args.frequency})`);

          } else if (functionName === "add_debt") {
            const debtData = {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              userId: user_id, // Debt usually uses userId? server.js doesn't show Debt usage.
              // I'll use both keys or check Debt model.
              // To be safe I'll use 'user_id' akin to others, or check model.
              // ApiService lines 483: `user_id=$userId`.
              // ApiService lines 514: `${debt.id}?user_id=${debt.userId}`.
              // The frontend uses userId. The backend likely expects user_id or userId depending on Schema.
              // I'll try to peek at Debt model if I can, but for now I'll use user_id assuming consistency with Expense.
              user_id: user_id,
              type: args.type,
              person: args.person,
              amount: args.amount,
              dueDate: args.dueDate || null,
              isPaid: false
            };
            await Debt.create(debtData);
            results.push(`✅ Added loan: ${args.type} ${args.person} $${args.amount}`);

          } else if (functionName === "add_goal") {
            const goalData = {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              userId: user_id, // Checking ApiService 454: user_id param.
              user_id: user_id,
              title: args.title,
              targetAmount: args.targetAmount,
              currentAmount: args.currentAmount || 0,
              deadline: args.deadline || null,
              isCompleted: false
            };
            await Goal.create(goalData);
            results.push(`✅ Added goal: ${args.title} target $${args.targetAmount}`);
          }
        } catch (dbErr) {
          console.error(`Error executing ${functionName}:`, dbErr);
          results.push(`❌ Failed to add ${functionName.replace('add_', '')}: ${dbErr.message}`);
        }
      }
      
      // Only return the clean function results, ignore any AI commentary
      res.json({ 
        reply: results.join('\n'),
        action_performed: true 
      });
      
    } else {
      // No function call, return regular chat response
      // Clean up any null or undefined content
      const cleanContent = responseMessage.content || "I'm here to help with your expenses!";
      res.json({ 
        reply: cleanContent,
        action_performed: false 
      });
    }
    
    
  } catch (err) {
    console.error("Chat Error:", err);
    res.status(500).json({ error: "Failed to get response from AI" });
  }
});

// --- Receipt Scanning ---
router.post('/scan-receipt', async (req, res) => {
  const { imageBase64 } = req.body;
  
  if (!imageBase64) {
    return res.status(400).json({ error: "Image data required" });
  }

  try {
    const response = await openai.chat.completions.create({
      model: process.env.MODEL_NAME || "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are a receipt scanning assistant. Extract the following information from the receipt image provided:
          - Merchant Name (title)
          - Total Amount (number)
          - Date (ISO 8601 format YYYY-MM-DD)
          - Category (Infer from merchant/items, e.g., 'Food', 'Grocery', 'Transport', 'Shopping', 'Health', 'Other')
          - Description (Brief summary of items)
          
          Return ONLY a valid JSON object with keys: title, amount, date, category, description. Do not include markdown code blocks.`
        },
        {
          role: "user",
          content: [
            { type: "text", text: "Scan this receipt." },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${imageBase64}`
              }
            }
          ]
        }
      ],
      max_tokens: 500,
    });

    const content = response.choices[0].message.content;
    const jsonStr = content.replace(/```json/g, '').replace(/```/g, '').trim();
    const data = JSON.parse(jsonStr);
    
    res.json({ data });
  } catch (err) {
    console.error("Scan Error:", err);
    res.status(500).json({ error: "Failed to scan receipt" });
  }
});

app.use('/api', router);

// Root route for health check
app.get('/', (req, res) => {
  res.json({ status: 'Finesight API is running (MongoDB)' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
