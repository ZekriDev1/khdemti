import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../utils/data.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zellij_background.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _service = SupabaseService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _users = await _service.getAllUsers();
      _bookings = await _service.getAllBookings();
    } catch (e) {
      debugPrint('Admin load error: ' + e.toString());
    }
    setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              backgroundColor: AppTheme.primaryRedDark,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Provider', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverview(),
                _buildUsers(),
                _buildBookings(),
                _buildSettings(),
              ],
            ),
    );
  }

  Widget _buildOverview() {
    final customers = _users.where((u) => u['role'] == 'customer').length;
    final providers = _users.where((u) => u['role'] == 'provider').length;
    final pending = _bookings.where((b) => b['status'] == 'pending').length;
    final completed = _bookings.where((b) => b['status'] == 'completed').length;

    return ZellijBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Super Admin', style: AppTheme.textTheme.headlineMedium)
                .animate().fadeIn().slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            Text('God Mode Enabled', style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Users', _users.length.toString(), Icons.people, AppTheme.cobaltBlue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Providers', providers.toString(), Icons.work, AppTheme.emeraldGreen)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Customers', customers.toString(), Icons.person, AppTheme.saffronYellow)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Bookings', _bookings.length.toString(), Icons.calendar_month, AppTheme.primaryRedDark)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent Activity', style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._bookings.take(5).map((b) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(b['status']).withOpacity(0.1),
                  child: Icon(_getStatusIcon(b['status']), color: _getStatusColor(b['status'])),
                ),
                title: Text(b['services']?['name'] ?? 'Service'),
                subtitle: Text(b['status'] ?? 'Unknown'),
                trailing: Text(_formatDate(b['created_at'])),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildUsers() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final rating = user['manual_rating'] ?? 0.0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(user['role']),
                child: Text((user['full_name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(user['full_name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['phone'] ?? ''),
                  if (user['age'] != null) Text('Age: ' + user['age'].toString()),
                  if (user['role'] == 'provider') 
                    Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(' ' + rating.toString())]),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRoleColor(user['role']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(user['role'] ?? 'unknown', style: TextStyle(color: _getRoleColor(user['role']), fontWeight: FontWeight.bold)),
              ),
            ),
          ).animate().fadeIn(delay: (30 * index).ms);
        },
      ),
    );
  }

  Widget _buildBookings() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking['services']?['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(booking['status'] ?? '', style: TextStyle(color: _getStatusColor(booking['status']), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ' + (booking['profiles']?['full_name'] ?? 'Unknown')),
                  Text('Date: ' + _formatDate(booking['scheduled_at'])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusButton('Accept', Colors.green, () => _updateBookingStatus(booking['id'], 'accepted')),
                      const SizedBox(width: 8),
                      _buildStatusButton('Reject', Colors.red, () => _updateBookingStatus(booking['id'], 'rejected')),
                      const SizedBox(width: 8),
                      _buildStatusButton('Complete', Colors.blue, () => _updateBookingStatus(booking['id'], 'completed')),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (30 * index).ms);
        },
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: ListTile(title: Text('App Version'), trailing: Text('1.0.0'))),
        Card(child: ListTile(title: Text('Database Reset'), trailing: Icon(Icons.refresh), onTap: _loadData)),
      ],
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      await _service.updateBookingStatus(bookingId, status);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking ' + status)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
      case 'super_admin':
        return AppTheme.primaryRedDark;
      case 'provider':
        return AppTheme.emeraldGreen;
      default:
        return AppTheme.cobaltBlue;
    }
  }

  Color _getStatusColor(String? status) {
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

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'accepted':
      case 'in_progress':
        return Icons.play_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  void _showAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddUserSheet(),
    ).then((_) => _loadData());
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '//';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AddUserSheet extends StatefulWidget {
  const _AddUserSheet();

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.5');
  
  String? _selectedService = 'plumber';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await SupabaseService().createProviderProfile(
        fullName: _nameController.text,
        phone: '+212' + _phoneController.text,
        age: int.tryParse(_ageController.text) ?? 25,
        rating: double.tryParse(_ratingController.text) ?? 5.0,
        serviceIds: [_selectedService!],
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider added successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Text('Add New Provider', style: AppTheme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              
              Text('Personal Info', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Name
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(border: InputBorder.none, labelText: 'Full Name', icon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              
              // Phone
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(border: InputBorder.none, labelText: 'Phone (without +212)', icon: Icon(Icons.phone_iphone)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                   Expanded(
                     child: Container(
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: InputBorder.none, labelText: 'Age', icon: Icon(Icons.cake_outlined)),
                      ),
                    ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Container(
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _ratingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: InputBorder.none, labelText: 'Confirm Rating', icon: Icon(Icons.star_outline)),
                      ),
                    ),
                   ),
                ],
              ),
              
              const SizedBox(height: 24),
              Text('Service', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedService = v),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRedDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
