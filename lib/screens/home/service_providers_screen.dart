import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../utils/data.dart';
import '../../services/supabase_service.dart';
import '../../models/user_model.dart';
import '../../widgets/apple_widgets.dart';
import 'provider_detail_screen.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final ServiceCategory category;
  const ServiceProvidersScreen({super.key, required this.category});

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  final SupabaseService _service = SupabaseService();
  List<UserModel> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    try {
      _providers = await _service.getProviders(serviceId: widget.category.id);
    } catch (e) {
      debugPrint('Error loading providers: ' + e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.category.icon, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text('No providers yet', style: AppTheme.textTheme.headlineMedium),
                       const SizedBox(height: 8),
                      const Text('Providers for this service will appear here'),
                      const SizedBox(height: 24),
                      AppleButton(
                         width: 200,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request sent! We will notify when providers are available.')),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_active, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                             Text('Notify Me', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : RefreshIndicator(
                  onRefresh: _loadProviders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _providers.length,
                    itemBuilder: (context, index) {
                      final p = _providers[index];
                      final name = p.fullName ?? 'Provider';
                      final isOnline = p.isOnline;

                      return AppleCard(
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProviderDetailScreen(
                                  provider: p,
                                  serviceId: widget.category.id,
                                  serviceName: widget.category.name,
                                ),
                              ),
                            );
                        },
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: widget.category.color.withOpacity(0.2),
                                  backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
                                  child: p.avatarUrl == null ? Text(
                                    name.isNotEmpty ? name[0] : '?', 
                                    style: TextStyle(color: widget.category.color, fontSize: 24, fontWeight: FontWeight.bold)
                                  ) : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppTheme.emeraldGreen : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const Text(' --- ', style: TextStyle(fontSize: 12)),
                                      Text(
                                        isOnline ? 'Available' : 'Offline',
                                        style: TextStyle(
                                          color: isOnline ? AppTheme.emeraldGreen : Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
                ),
    );
  }
}
