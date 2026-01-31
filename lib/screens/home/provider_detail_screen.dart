import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/premium_ui.dart';
import 'chat_screen.dart'; // We will link this soon

class ProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String? serviceId;
  final String? serviceName;
  
  const ProviderDetailScreen({
    super.key,
    required this.provider,
    this.serviceId,
    this.serviceName,
  });

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final SupabaseService _service = SupabaseService();
  double _rating = 0.0;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    try {
      _rating = await _service.getProviderRating(widget.provider['id']);
    } catch (e) {
      debugPrint('Error loading rating: ' + e.toString());
    }
    setState(() => _isLoadingRating = false);
  }

  void _showBookingSheet() {
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    // Round to nearest 30 min
    selectedDateTime = DateTime(
      selectedDateTime.year, 
      selectedDateTime.month, 
      selectedDateTime.day, 
      selectedDateTime.hour, 
      (selectedDateTime.minute / 30).round() * 30
    );

    final addressController = TextEditingController();
    final notesController = TextEditingController();
    
    // Sheet State
    bool isSubmitting = false;
    bool isSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Book Service', style: AppTheme.textTheme.headlineMedium),
                Text(widget.provider['full_name'] ?? 'Provider', style: TextStyle(color: Colors.grey[600])),
                
                const SizedBox(height: 24),
                const Text('Select Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // iOS Style Date Picker
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // Very subtle background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      initialDateTime: selectedDateTime,
                      minimumDate: DateTime.now(),
                      maximumDate: DateTime.now().add(const Duration(days: 30)),
                      minuteInterval: 15,
                      mode: CupertinoDatePickerMode.dateAndTime,
                      onDateTimeChanged: (val) {
                         selectedDateTime = val;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                PremiumTextField(
                  controller: addressController,
                  label: 'Enter your address',
                  icon: Icons.location_on_outlined,
                ),
                
                const SizedBox(height: 16),
                const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                PremiumTextField(
                  controller: notesController,
                  label: 'Describe the issue...',
                  icon: Icons.notes,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BouncyButton(
                    onPressed: isSubmitting ? () {} : () async {
                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter address'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      
                      setSheetState(() => isSubmitting = true);
                      
                      try {
                        await _service.createBooking(
                          serviceId: widget.serviceId ?? '',
                          providerId: widget.provider['id'],
                          scheduledAt: selectedDateTime,
                          address: addressController.text,
                          notes: notesController.text,
                        );

                        // Success Feedback on Button
                         setSheetState(() => isSuccess = true);
                         await Future.delayed(600.ms); // Show success check for a bit
                         
                        if (mounted) {
                           Navigator.pop(context);
                           _showSuccessDialog();
                        }
                      } catch (e) {
                         setSheetState(() => isSubmitting = false);
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: AnimatedContainer(
                      duration: 300.ms,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.green : AppTheme.primaryRedDark,
                        borderRadius: BorderRadius.circular(isSuccess ? 28 : 16),
                         boxShadow: [
                          BoxShadow(
                            color: (isSuccess ? Colors.green : AppTheme.primaryRedDark).withOpacity(0.3), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4)
                          ),
                        ],
                      ),
                      child: isSubmitting 
                        ? (isSuccess 
                            ? const Icon(Icons.check, color: Colors.white, size: 30).animate().scale()
                            : const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                        : const Text('Confirm Booking', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppTheme.emeraldGreen)
              .animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Your provider has been notified.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRedDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.provider['full_name'] ?? 'Provider';
    final isOnline = widget.provider['is_online'] == true;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.primaryRedDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
                  // Pattern overlay
                  Positioned.fill(
                    child: Opacity(opacity: 0.1, child: Image.network('https://www.transparenttextures.com/patterns/cubes.png', repeat: ImageRepeat.repeat)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.white,
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppTheme.primaryRedDark),
                              ),
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOnline ? AppTheme.emeraldGreen : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: Text(isOnline ? 'ONLINE' : 'OFFLINE', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Dynamic Star Rating
                      if (!_isLoadingRating)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < _rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 20,
                            )),
                            const SizedBox(width: 8),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  PremiumGlassCard(
                    opacity: 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Jobs', '124', Icons.work_outline),
                        Container(width: 1, height: 40, color: Colors.grey[200]),
                        _buildStat('Exp', '5 Yrs', Icons.history),
                        Container(width: 1, height: 40, color: Colors.grey[200]),
                        _buildStat('Rate', '100DH', Icons.monetization_on_outlined),
                      ],
                    ),
                  ).animate().slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  Text('About', style: AppTheme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    widget.provider['bio'] ?? 'Professional service provider with years of experience. Committed to quality work and customer satisfaction.',
                    style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Reviews', style: AppTheme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  // Placeholder for Reviews
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.grey, radius: 16, child: Icon(Icons.person, color: Colors.white, size: 16)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Happy Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Great service, very professional!', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PremiumGlassCard(
        opacity: 0.9,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: BouncyButton(
                  onPressed: () {
                    // Navigate to Chat
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.cobaltBlue, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: AppTheme.cobaltBlue),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: BouncyButton(
                  onPressed: _showBookingSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRedDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryRedDark.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Text('Book Now', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.cobaltBlue, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
      ],
    );
  }
}
