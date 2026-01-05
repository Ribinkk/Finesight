import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGuestLogin;
  final bool isLoading;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onGuestLogin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Dark background similar to the provided design
    final backgroundColor = const Color(0xFF0F1218);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Programmatic Finesight AI Logo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Custom Icon: 3 Bars
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(height: 24, color: const Color(0xFF4A90E2)), // Medium Blue
                            const SizedBox(width: 4),
                            _buildBar(height: 32, color: const Color(0xFF50E3C2)), // Cyan/Teal
                            const SizedBox(width: 4),
                            _buildBar(height: 40, color: const Color(0xFF009B6E)), // Green/Teal
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Text: Finesight AI
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit( // Using Outfit or Inter for modern look
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Finesight ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'AI',
                              // User requested Yellow for AI
                              style: TextStyle(color: Color(0xFFFFD700)), 
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Understand your spending',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),

              // Login Buttons
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login),
                              const SizedBox(width: 12),
                              Text(
                                'Continue',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: onGuestLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
                          ),
                          child: Text(
                            'Continue as Guest',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color.withOpacity(0.6),
            color,
          ],
        ),
      ),
    );
  }
}
