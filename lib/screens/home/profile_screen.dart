import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/saved_addresses_screen.dart';
import '../profile/settings_screen.dart'; // Keeping for language/etc
import '../profile/become_provider_screen.dart';
import '../profile/payment_methods_screen.dart';
import '../home/notifications_screen.dart'; // NEW
import '../home/favorites_screen.dart'; // NEW
import '../home/ad_promotion_screen.dart'; // NEW

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final profile = auth.profile;
        final name = profile?.fullName ?? 'Guest User';
        final phone = profile?.phone ?? '+212 XXX XXX XXX';
        final role = profile?.role ?? UserRole.customer;
        final isAdmin = auth.isAdmin;

        return Scaffold(
          backgroundColor: AppTheme.backgroundOffWhite,
          body: StreamBuilder<UserModel?>(
            stream: auth.profileStream,
            builder: (context, snapshot) {
              final liveProfile = snapshot.data ?? profile;
              final liveName = liveProfile?.fullName ?? name;
              final livePhone = liveProfile?.phone ?? phone;
              final liveRole = liveProfile?.role ?? role;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: AppTheme.primaryRedDark,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    backgroundImage: liveProfile?.avatarUrl != null 
                                      ? NetworkImage(liveProfile!.avatarUrl!) 
                                      : null,
                                    child: liveProfile?.avatarUrl == null 
                                      ? Text(
                                          liveName.isNotEmpty ? liveName[0].toUpperCase() : '?',
                                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryRedDark),
                                        )
                                      : null,
                                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                                  if (liveProfile?.isVerified == true)
                                      Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                        ),
                                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(liveName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(livePhone, style: const TextStyle(color: Colors.white70)),
                              if (isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Super Admin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (isAdmin)
                            Card(
                              color: AppTheme.primaryRedDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
                                title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: const Text('Manage users, bookings & more', style: TextStyle(color: Colors.white70)),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
                              ),
                            ).animate().fadeIn().shimmer(duration: 2000.ms, color: Colors.white24),
                          const SizedBox(height: 16),
                          
                          // PROVIDER SECTION
                          if (liveRole == UserRole.provider)
                             Column(
                               children: [
                                 _buildSection('Provider Tools', [
                                  _ProfileTile(
                                    icon: Icons.flash_on_rounded,
                                    title: 'Promote Services',
                                    subtitle: 'Boost visibility & get more clients',
                                    iconColor: Colors.orange,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdPromotionScreen())),
                                  ),
                                   /* Add stats dashboard here later */
                                 ]),
                                 const SizedBox(height: 16),
                               ],
                             ),

                          _buildSection('Account', [
                            _ProfileTile(
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                            ),
                            _ProfileTile(
                              icon: Icons.location_on_outlined,
                              title: 'Saved Addresses',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesScreen())),
                            ),
                             _ProfileTile(
                              icon: Icons.bookmark_border,
                              title: 'Favorites',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                            ),
                            _ProfileTile(
                              icon: Icons.payment_outlined,
                              title: 'Payment Methods',
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                              },
                            ),
                            if (liveRole == UserRole.customer)
                              _ProfileTile(
                                icon: Icons.work_outline,
                                title: 'Become a Provider',
                                subtitle: 'Start earning today!',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeProviderScreen())),
                              ),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection('Preferences', [
                            _ProfileTile(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                            ),
                            _ProfileTile(
                              icon: Icons.language,
                              title: 'Language',
                              subtitle: 'English / Français',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ),
                            _ProfileTile(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              onTap: () { 
                                // Placeholder
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Support Center coming soon!")));
                              },
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection('Other', [
                            _ProfileTile(
                              icon: Icons.info_outline,
                              title: 'About Khdemti',
                              onTap: () {
                                showAboutDialog(context: context, applicationName: 'Khdemti', applicationVersion: '1.0.0');
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.star_outline,
                              title: 'Rate the App',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thank you for rating us! ⭐⭐⭐⭐⭐')),
                                );
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.logout,
                              title: 'Log Out',
                              isDestructive: true,
                              onTap: () async {
                                await auth.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ]),
                          const SizedBox(height: 32),
                          Text('Khdemti v1.0.0', style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(height: 8),
                          Text('Made by ZEKRI', style: TextStyle(color: Colors.grey[400])),
                           const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(height: 1, indent: 50),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppTheme.textDark;
    final iColor = iconColor ?? (isDestructive ? Colors.red : AppTheme.primaryRedDark);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iColor, size: 20),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null,
      trailing:_titleIcon(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
  
  Widget _titleIcon(String title) {
    if (title == 'Language') return const Text('Modifiable', style: TextStyle(color: Colors.grey, fontSize: 13));
     return const Icon(Icons.chevron_right, color: Colors.grey, size: 20);
  }
}
