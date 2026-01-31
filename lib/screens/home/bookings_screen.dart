import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../services/supabase_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      _bookings = await _service.getMyBookings();
    } catch (e) {
      debugPrint('Error loading bookings: ' + e.toString());
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _activeBookings => _bookings.where((b) => 
    ['pending', 'accepted', 'in_progress'].contains(b['status'])).toList();

  List<Map<String, dynamic>> get _pastBookings => _bookings.where((b) => 
    ['completed', 'cancelled', 'rejected'].contains(b['status'])).toList();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(_activeBookings, isActive: true),
                  _buildBookingsList(_pastBookings, isActive: false),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, {required bool isActive}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No  bookings', style: AppTheme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Your bookings will appear here', style: AppTheme.textTheme.bodyMedium),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final service = booking['services'];
        final provider = booking['profiles'];
        final status = booking['status'] ?? 'pending';
        final scheduledAt = booking['scheduled_at'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getServiceIcon(service?['name']), color: _getStatusColor(status)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service?['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(provider?['full_name'] ?? 'Awaiting provider', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatStatus(status),
                        style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(_formatDateTime(scheduledAt), style: TextStyle(color: Colors.grey[600])),
                    const Spacer(),
                    if (booking['address'] != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            (booking['address'] as String).length > 20 
                                ? (booking['address'] as String).substring(0, 20) + '...'
                                : booking['address'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isActive && status == 'accepted') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contacting provider...')),
                            );
                          },
                          child: const Text('Contact'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tracking coming soon!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRedDark),
                          child: const Text('Track', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'accepted':
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  IconData _getServiceIcon(String? serviceName) {
    if (serviceName == null) return Icons.home_repair_service;
    final name = serviceName.toLowerCase();
    if (name.contains('plumb')) return Icons.plumbing;
    if (name.contains('electric')) return Icons.electric_bolt;
    if (name.contains('clean')) return Icons.cleaning_services;
    if (name.contains('paint')) return Icons.format_paint;
    if (name.contains('ac') || name.contains('cool')) return Icons.ac_unit;
    return Icons.home_repair_service;
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'TBD';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
