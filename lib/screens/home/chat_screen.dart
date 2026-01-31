import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../utils/theme.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final bookings = await _service.getMyBookings();
      setState(() {
        _bookings = bookings; // In a real app, we might group by provider/user unique IDs
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(title: const Text('Messages'), backgroundColor: AppTheme.primaryRedDark, foregroundColor: Colors.white),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty 
          ? const Center(child: Text('No active bookings to chat about.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                // If I am customer, show provider name. If I am provider, show customer name.
                // For simplicity, we just look for provider name as this is Customer App mostly.
                final otherUser = booking['profiles'] ?? {}; // This is provider via foreign key in logic usually
                final name = otherUser['full_name'] ?? 'Provider';
                final service = booking['services']?['name'] ?? 'Service';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryRedDark.withOpacity(0.1),
                      child: Text(name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryRedDark)),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(service + ' • ' + (booking['status'] ?? 'pending')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(
                            bookingId: booking['id'],
                            otherUserName: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
