# Finesight - Expense Tracker App

A full-stack expense tracking application built with Flutter and Node.js.

## Features

- 📊 **Dashboard**: View expense analytics and summaries
- 💰 **Expense Management**: Add, edit, and categorize expenses
- 💳 **Payment Integration**: Razorpay payment gateway support
- 🤖 **AI Insights**: AI-powered expense analysis
- 👤 **User Profiles**: Manage categories and user settings
- 🔐 **Authentication**: Secure login system

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile/web framework
- **Dart**: Programming language

### Backend
- **Node.js**: Server runtime
- **Express**: Web framework
- **SQLite**: Database

## Project Structure

```
.
├── flutter_app/          # Flutter application
│   ├── lib/
│   │   ├── screens/      # UI screens
│   │   ├── services/     # API and auth services
│   │   └── models/       # Data models
│   └── web/              # Web assets
└── backend/              # Node.js backend
    ├── server.js         # Express server
    └── database.js       # Database configuration
```

## Getting Started

### Prerequisites
- Flutter SDK
- Node.js and npm
- Git

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   node server.js
   ```

### Frontend Setup

1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome  # For web
   flutter run            # For mobile
   ```

## Configuration

Update the API endpoint in `flutter_app/lib/services/api_service.dart` to match your backend URL.

## License

This project is open source and available under the MIT License.
