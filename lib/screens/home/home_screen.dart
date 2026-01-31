import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/data.dart';
import '../../widgets/zellij_background.dart';
import '../../widgets/premium_ui.dart'; // Keeping for old widgets if needed
import '../../widgets/apple_widgets.dart'; // NEW
import '../../models/ad_model.dart';
import '../../services/supabase_service.dart';
import 'search_screen.dart';
import 'bookings_screen.dart';
import 'chat_screen.dart';
import '../profile/profile_screen.dart'; // Ensuring correct import
import 'urgent_help_screen.dart';
import 'service_providers_screen.dart';
import 'notifications_screen.dart';
import 'ad_promotion_screen.dart';
import 'promo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const BookingsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      extendBody: true, 
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UrgentHelpScreen()),
                );
              },
              backgroundColor: Colors.redAccent,
              elevation: 4,
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white)
                  .animate(onPlay: (c) => c.repeat())
                  .shake(delay: 2000.ms),
              label: const Text("URGENT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
            ).animate().scale(delay: 500.ms).shimmer(delay: 2000.ms, duration: 1500.ms)
          : null,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) {
               setState(() => _selectedIndex = idx);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded, color: AppTheme.primaryRedDark),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_month, color: AppTheme.primaryRedDark),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.primaryRedDark),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppTheme.primaryRedDark),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subtle Background
        Container(
          height: 300,
           decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), AppTheme.backgroundWhite],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140, // Reduced height for cleaner look
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<AuthProvider>(
                                      builder: (context, auth, _) {
                                        // FIXED: Using strong typing
                                        final name = auth.profile?.fullName?.split(' ').first ?? "Marhba";
                                        return Text("Hello, $name 👋", 
                                          style: GoogleFonts.outfit(color: AppTheme.primaryRedDark, fontSize: 18, fontWeight: FontWeight.w500));
                                      },
                                    ),
                                    Text(
                                      "Find a Service",
                                      style: GoogleFonts.outfit(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                AppleButton(
                                  width: 48,
                                  height: 48,
                                  borderRadius: 24,
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                                  },
                                  child: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 26),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Search Bar Area
            SliverToBoxAdapter(
              child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                 child: AppleButton(
                  height: 56,
                  backgroundColor: Colors.white,
                  borderRadius: 16,
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, color: AppTheme.primaryRedDark),
                      const SizedBox(width: 8),
                      Text("What do you need?", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                 ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SPONSORED ADS SECTION
                    FutureBuilder<List<AdModel>>(
                      future: SupabaseService().getAds(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          // Show horizontally scrolling ads
                          return Container(
                            height: 140,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (_,__) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final ad = snapshot.data![index];
                                return Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.primaryRedDark.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.yellow, size: 16),
                                          const SizedBox(width: 4),
                                          Text("SPONSORED", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(ad.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        ad.description, 
                                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13), 
                                        maxLines: 2, 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        // Default Promo if no ads
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromoScreen())),
                          child: AppleCard(
                            padding: const EdgeInsets.all(0),
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryRedDark, Color(0xFFE53935)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -20, bottom: -20,
                                    child: Icon(Icons.local_offer, size: 180, color: Colors.white.withOpacity(0.1)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                          child: const Text("PROMO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                        const SizedBox(height: 12),
                                        Text("25% OFF", style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0)),
                                        const Text("Home Cleaning", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    
                    // Feature Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Categories", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                          child: const Text("View All", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Categories Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, 
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    return AppleButton(
                      backgroundColor: Colors.white,
                      isGlass: false,
                      borderRadius: 24,
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceProvidersScreen(category: cat),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(cat.icon, style: const TextStyle(fontSize: 32)),
                          ).animate().scale(delay: (50 * index).ms),
                          const SizedBox(height: 16),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.2, end: 0);
                  },
                  childCount: categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ],
    );
  }
}
