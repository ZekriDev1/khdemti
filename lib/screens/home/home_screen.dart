import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/data.dart';
import '../../widgets/zellij_background.dart';
import '../../widgets/premium_ui.dart';
import 'search_screen.dart';
import 'bookings_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'urgent_help_screen.dart';
import 'provider_detail_screen.dart';
import 'home_screen.dart'; // Self import is redundant but harmless
import '../profile/notifications_screen.dart';
import '../home/promo_screen.dart';

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
      backgroundColor: AppTheme.backgroundOffWhite,
      extendBody: true, // Important for glass bottom nav
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
              // Light haptic on tab change
              if (_selectedIndex != idx) {
                // HapticFeedback.selectionClick(); // Needs services import, omitting for safety
              } 
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
    return ZellijBackground(
      fullScreen: true, // Let background span full height
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent, // Glass effect instead
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
                                      final name = auth.profile?['full_name']?.split(' ')?.first ?? "Marhba";
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
                              BouncyButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 28),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Hero(
                            tag: 'searchBar',
                            child: BouncyButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                                );
                              },
                              child: PremiumGlassCard(
                                opacity: 0.9,
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, color: AppTheme.primaryRedDark, size: 28),
                                    const SizedBox(width: 16),
                                    Text("What do you need help with?", 
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  // Special Offer Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PromoScreen()));
                    },
                    child: PremiumGlassCard(
                      opacity: 0.9,
                      padding: EdgeInsets.zero,
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
                              right: -20,
                              bottom: -20,
                              child: Icon(Icons.local_offer, size: 180, color: Colors.white.withOpacity(0.1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text("PROMO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      const SizedBox(height: 12),
                                      Text("25% OFF", 
                                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0)),
                                      const SizedBox(height: 4),
                                      const Text("Home Cleaning", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 30,
                              bottom: 30,
                              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 80)
                                .animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms),

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
                crossAxisCount: 3, // Less crowded
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  return BouncyButton(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceProvidersScreen(category: cat),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24), // Softer corners
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
                          BoxShadow(color: cat.color.withOpacity(0.1), blurRadius: 0, spreadRadius: 0), // Tint
                        ],
                      ),
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
    );
  }
}
