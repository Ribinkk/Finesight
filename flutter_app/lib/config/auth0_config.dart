class Auth0Config {
  static const String domain = 'finesight.jp.auth0.com';
  static const String clientId = 'R3qpPARt2PJV5eD0bFxaOmJdtIx0CuOc';
  
  // Callback scheme for mobile platforms
  static const String scheme = 'com.finesight.expensetracker';
  
  // Scopes to request
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access', // For refresh tokens
  ];
}
