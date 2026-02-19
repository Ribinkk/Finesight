import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';

class ReminderScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const ReminderScreen({super.key, required this.user, required this.isDark});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _dailyReminder = true;
  bool _billReminder = true;
  bool _updates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitch(
            'Daily Reminder',
            'Get a reminder to log expenses every evening',
            _dailyReminder,
            (val) => setState(() => _dailyReminder = val),
          ),
          _buildSwitch(
            'Bill Reminders',
            'Get notified about upcoming recurring bills',
            _billReminder,
            (val) => setState(() => _billReminder = val),
          ),
          _buildSwitch(
            'App Updates',
            'Receive news about new features',
            _updates,
            (val) => setState(() => _updates = val),
          ),

          if (_dailyReminder)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  'Note: Notifications are simulated in this web demo.',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).primaryColor,
        title: Text(
          title,
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: widget.isDark ? Colors.grey : Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
