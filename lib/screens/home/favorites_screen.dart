import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../services/supabase_service.dart';
import '../home/provider_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text("Saved", style: AppTheme.textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<String>>(
        future: service.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favIds = snapshot.data ?? [];
          
          if (favIds.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No favorites saved yet", style: AppTheme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          // In a real app we'd fetch the provider details for these IDs efficiently
          // For now, we'll just show them as a placeholder list requiring further fetching
          // Optimization: fetchProvidersByIds(favIds)
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: favIds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: service.getProviderById(favIds[index]),
                builder: (context, providerSnap) {
                  final provider = providerSnap.data;
                  if (provider == null) return const SizedBox();

                  return AppleCard(
                    onTap: () {
                         // Convert model to map for old screen compatibility or refactor screen
                         // For now passing a map construction
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderDetailScreen(
                                provider: provider, 
                                serviceId: 'favorite', // Placeholder/Generic service ID context
                                serviceName: 'Favorite', // Placeholder
                              ),
                            ),
                          );
                    },
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(provider.avatarUrl ?? 'https://via.placeholder.com/150'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(provider.fullName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold))),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}
