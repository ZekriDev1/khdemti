import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../services/supabase_service.dart';
import '../../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text("Notifications", style: AppTheme.textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: SupabaseService().getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? [];
          
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No notifications yet", style: AppTheme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return AppleCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColorType(note.type).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIconType(note.type), color: _getColorType(note.type), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(note.message, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMd().add_Hm().format(note.createdAt),
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (!note.isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppTheme.primaryRedDark, shape: BoxShape.circle),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorType(String type) {
    switch (type) {
      case 'booking': return Colors.blue;
      case 'promo': return Colors.purple;
      case 'system': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getIconType(String type) {
    switch (type) {
      case 'booking': return Icons.calendar_today;
      case 'promo': return Icons.local_offer;
      case 'system': return Icons.info_outline;
      default: return Icons.notifications;
    }
  }
}
