import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../utils/data.dart';
import '../../services/supabase_service.dart';
import 'provider_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = categories;
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _filterCategories(widget.initialQuery!);
    }
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = categories;
      } else {
        _filteredCategories = categories
            .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Search Services'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCategories('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('No services found', style: AppTheme.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Try a different search term', style: AppTheme.textTheme.bodyMedium),
                      ],
                    ).animate().fadeIn(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _filteredCategories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 28))),
                          ),
                          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Tap to view providers'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceProvidersScreen(category: cat),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ServiceProvidersScreen extends StatefulWidget {
  final ServiceCategory category;
  const ServiceProvidersScreen({super.key, required this.category});

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _providers = [];
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
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
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
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request sent! We will notify when providers are available.')),
                          );
                        },
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Notify Me'),
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
                      final name = p['full_name'] ?? 'Provider';
                      final isOnline = p['is_online'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: widget.category.color,
                                      child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
                ),
    );
  }
}
