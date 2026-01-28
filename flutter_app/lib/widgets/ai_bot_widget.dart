import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AIBotWidget extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const AIBotWidget({super.key, required this.user, required this.isDark});

  @override
  State<AIBotWidget> createState() => _AIBotWidgetState();
}

class _AIBotWidgetState extends State<AIBotWidget> {
  bool _isOpen = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "assistant", "content": "Hey I am Connor, how can I help you?"},
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.user == null) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isTyping = true;
      _controller.clear();
    });

    try {
      // Prepare context (basic for now, can be expanded)
      final contextData = [
        {
          "role": "system",
          "content":
              "You are Connor, an advanced AI financial assistant. You have complete control to add records.",
        },
      ];

      final reply = await ApiService.chatWithAI(
        text,
        contextData,
        widget.user!.uid,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"role": "assistant", "content": reply});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "role": "assistant",
            "content":
                "Error: Could not connect to Finesight Core. Please ensure the backend server is running.",
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chat Window
          if (_isOpen)
            Container(
              width: 350,
              height: 500,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009B6E),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Mini Robot Head
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.bot,
                              color: const Color(0xFF009B6E),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connor AI',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'I can add loans, goals, & more',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _isOpen = false),
                        ),
                      ],
                    ),
                  ),

                  // Messages
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? const Color(0xFF334155)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(
                                width: 40,
                                child: LinearProgressIndicator(minHeight: 2),
                              ),
                            ),
                          );
                        }

                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child:
                              Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 260,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFF009B6E)
                                          : (widget.isDark
                                                ? const Color(0xFF334155)
                                                : Colors.grey.shade100),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isUser ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isUser ? 4 : 16,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      msg['content']!,
                                      style: GoogleFonts.inter(
                                        color: isUser
                                            ? Colors.white
                                            : (widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: 0.2, end: 0),
                        );
                      },
                    ),
                  ),

                  // Input
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type "Add subscription..."',
                              hintStyle: TextStyle(
                                color: widget.isDark
                                    ? Colors.white38
                                    : Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: widget.isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(LucideIcons.send),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF009B6E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(
              alignment: Alignment.bottomRight,
              duration: 300.ms,
              curve: Curves.easeOutBack,
            ),

          // Parallel Layout for Bubble and Button
          if (!_isOpen)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Welcome Bubble (Speech Bubble)
                Container(
                      margin: const EdgeInsets.only(bottom: 12, right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                          16,
                        ).copyWith(bottomRight: Radius.zero),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Hey I am Connor,\nhow can I help you?",
                            style: GoogleFonts.inter(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isOpen = true,
                            ), // Open chat on tap
                            child: Icon(
                              LucideIcons.arrowRightCircle,
                              size: 16,
                              color: const Color(0xFF009B6E),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

                // Floating Button
                GestureDetector(
                  onTap: () => setState(() => _isOpen = !_isOpen),
                  child:
                      Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF009B6E),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF009B6E,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Procedural Robot Head (Mini Version)
                                Container(
                                  width: 36,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 28,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E293B),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF00E5FF),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Container(
                                                width: 6,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF00E5FF),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Antenna
                                      const Positioned(
                                        top: -6,
                                        left: 17,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -4, duration: 2.seconds),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
