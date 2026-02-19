import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    // Premium dark gradient background
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF020617), // Slate 950
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Robot & Branding Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom Procedural "AI Bot" Animation
                    SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow behind
                              Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor,
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.2, 1.2),
                                    duration: 2.seconds,
                                  ),

                              // Robot Head
                              Container(
                                width: 90,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0), // Slate 200
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Antenna
                                    Positioned(
                                      top: -10,
                                      left: 40, // Center-ish
                                      child: Column(
                                        children: [
                                          Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .animate(
                                                onPlay: (c) =>
                                                    c.repeat(reverse: true),
                                              )
                                              .fade(
                                                begin: 0.4,
                                                end: 1.0,
                                                duration: 1.seconds,
                                              ),
                                          Container(
                                            width: 2,
                                            height: 10,
                                            color: Colors.grey.shade400,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Face Screen
                                    Center(
                                      child: Container(
                                        width: 70,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1E293B,
                                          ), // Dark screen
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Left Eye
                                            Container(
                                                  width: 18,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Color.lerp(
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      Colors.white,
                                                      0.5,
                                                    ), // Lighter dynamic glow
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        blurRadius: 10,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                .animate(
                                                  onPlay: (c) => c.repeat(),
                                                )
                                                .scaleY(
                                                  begin: 1,
                                                  end: 1,
                                                  duration: 3.seconds,
                                                )
                                                .then()
                                                .scaleY(
                                                  begin: 1,
                                                  end: 0.1,
                                                  duration: 100.ms,
                                                  curve: Curves.easeInOut,
                                                )
                                                .then()
                                                .scaleY(
                                                  begin: 0.1,
                                                  end: 1,
                                                  duration: 100.ms,
                                                  curve: Curves.easeInOut,
                                                ),

                                            // Right Eye
                                            Container(
                                                  width: 18,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Color.lerp(
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      Colors.white,
                                                      0.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        blurRadius: 10,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                .animate(
                                                  onPlay: (c) => c.repeat(),
                                                )
                                                .scaleY(
                                                  begin: 1,
                                                  end: 1,
                                                  duration: 3.seconds,
                                                )
                                                .then()
                                                .scaleY(
                                                  begin: 1,
                                                  end: 0.1,
                                                  duration: 100.ms,
                                                  curve: Curves.easeInOut,
                                                )
                                                .then()
                                                .scaleY(
                                                  begin: 0.1,
                                                  end: 1,
                                                  duration: 100.ms,
                                                  curve: Curves.easeInOut,
                                                ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: 0,
                          end: -8,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ), // Float animation

                    const SizedBox(height: 24),

                    // Brand Name
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Finesight ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'AI',
                            style: TextStyle(
                              color: const Color(0xFFFFD700), // Gold/Yellow
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.yellow.withValues(alpha: 0.5),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    // Slogan
                    Text(
                      'Understand your spending.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  ],
                ),

                const Spacer(),

                // Buttons Section
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 4,
                              shadowColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.g_mobiledata,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sign in with Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: onGuestLogin,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade400,
                            ),
                            child: Text(
                              'Continue as Guest',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                        ],
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
