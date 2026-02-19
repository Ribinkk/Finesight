import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AIScreen extends StatefulWidget {
  final List<Expense> expenses;
  final bool isDark;
  final UserModel? user;
  final VoidCallback? onDataChanged;

  const AIScreen({
    super.key,
    required this.expenses,
    required this.isDark,
    this.user,
    this.onDataChanged,
  });

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // precise initial context
    _messages.add({
      'role': 'system',
      'content':
          'I am your financial assistant. Ask me anything about your expenses!',
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Prepare context from expenses
      // optimize by sending only relevant summary or last N expenses if needed
      // For now, let's send a summary to avoid token limits if many expenses
      final expenseSummary = widget.expenses
          .map(
            (e) =>
                "${e.date.toIso8601String().split('T')[0]}: ${e.title} - ${e.amount} (${e.category})",
          )
          .join('\n');

      final context = [
        {
          'role': 'system',
          'content': 'Current Expenses Data:\n$expenseSummary',
        },
      ];

      final reply = await ApiService.chatWithAI(
        userMessage,
        context,
        widget.user?.uid ?? '',
      );

      if (mounted) {
        setState(() {
          // Check if this was an action (starts with ✅)
          final isAction = reply.contains('✅');
          // Clean markdown formatting from reply
          final cleanReply = reply
              .replaceAll('**', '') // Remove bold markdown
              .replaceAll('*', '') // Remove italic markdown
              .replaceAll('__', '') // Remove underline markdown
              .replaceAll(
                '_',
                ' ',
              ); // Remove single underscores (replace with space)

          _messages.add({
            'role': 'assistant',
            'content': cleanReply,
            'isAction': isAction.toString(),
          });
          _isLoading = false;
        });
        _scrollToBottom();

        // If AI performed an action, refresh data
        if (reply.contains('✅')) {
          widget.onDataChanged?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Error: $e\n\nPlease try again later.',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: widget.isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Financial Assistant',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Chat Area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              final isSystem = msg['role'] == 'system';

              if (isSystem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : (widget.isDark
                              ? const Color(0xFF334155)
                              : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      if (!isUser)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    msg['content']!,
                    style: GoogleFonts.inter(
                      color: isUser
                          ? Colors.white
                          : (widget.isDark ? Colors.white : Colors.black87),
                      height: 1.4,
                    ),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0);
            },
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about your spending...',
                    hintStyle: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: widget.isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          LucideIcons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
