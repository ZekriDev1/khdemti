import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/apple_widgets.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // Use simple integer for processing tab selection without TicketProvider overhead
  int _selectedTab = 0; 
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      _bookings = await _service.getMyBookings();
    } catch (e) {
      debugPrint('Error loading bookings: ${e.toString()}');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _activeBookings => _bookings.where((b) => 
    ['pending', 'accepted', 'in_progress'].contains(b['status'])).toList();

  List<Map<String, dynamic>> get _pastBookings => _bookings.where((b) => 
    ['completed', 'cancelled', 'rejected'].contains(b['status'])).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Apple Header
            AppleHeader(
              title: "My Bookings",
              subtitle: "Manage your appointments",
              trailing: AppleButton(
                width: 40,
                height: 40,
                borderRadius: 12,
                backgroundColor: Colors.white,
                onPressed: _loadBookings,
                child: const Icon(Icons.refresh, color: AppTheme.textDark, size: 20),
              ),
            ),

            // iOS Segmented Control Tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab("Active", 0),
                    _buildTab("History", 1),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // List Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTab == 0
                      ? _buildBookingsList(_activeBookings, isActive: true)
                      : _buildBookingsList(_pastBookings, isActive: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: 200.ms,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected 
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
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
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No bookings', style: AppTheme.textTheme.headlineMedium?.copyWith(color: Colors.grey[400])),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final service = booking['services'];
        final provider = booking['profiles'];
        final status = booking['status'] ?? 'pending';
        final scheduledAt = booking['scheduled_at'];

        return AppleCard(
          color: Colors.white,
          onTap: () {
             // Detail view logic here
          },
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getServiceIcon(service?['name']), color: _getStatusColor(status)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service?['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(provider?['full_name'] ?? 'Awaiting provider', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(_formatDateTime(scheduledAt), style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (booking['address'] != null) ...[
                    Icon(Icons.location_on_rounded, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(
                        (booking['address'] as String).length > 20 
                            ? '${(booking['address'] as String).substring(0, 20)}...'
                            : booking['address'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (isActive && status == 'accepted') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppleButton(
                          height: 40,
                          backgroundColor: Colors.grey[100],
                          onPressed: () {},
                          child: const Text("Contact", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppleButton(
                          height: 40,
                          onPressed: () {},
                          child: const Text("Track", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'accepted': return Colors.indigo;
      case 'in_progress': return Colors.blue;
      case 'pending': return Colors.orange;
      case 'cancelled': 
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'in_progress': return 'In Progress';
      default: return status[0].toUpperCase() + status.substring(1);
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
    return Icons.home_repair_service_rounded;
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'TBD';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
