import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Notifications', [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
            _SettingsTile(
              icon: Icons.sms_outlined,
              title: 'SMS Notifications',
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Language', [
            _SettingsTile(
              icon: Icons.language,
              title: 'App Language',
              subtitle: 'French',
              onTap: () => _showLanguageDialog(context),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Support', [
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About Khdemti',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            _SettingsTile(
              icon: Icons.star_outline,
              title: 'Rate the App',
              onTap: () => _rateApp(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTheme.textTheme.titleLarge),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Francais'),
              leading: Radio(value: 'fr', groupValue: 'fr', onChanged: (v) {}),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('العربية'),
              leading: Radio(value: 'ar', groupValue: 'fr', onChanged: (v) {}),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio(value: 'en', groupValue: 'fr', onChanged: (v) {}),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _rateApp(BuildContext context) {
    final storeUrl = Platform.isIOS
        ? 'https://apps.apple.com/app/khdemti'
        : 'https://play.google.com/store/apps/details?id=com.zekri.khdemti';
    launchUrl(Uri.parse(storeUrl));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textGrey),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQ('How do I book a service?', 'Search for a service, select a provider, choose date/time, and confirm your booking.'),
          _buildFAQ('How do I cancel a booking?', 'Go to Bookings tab, find your booking, and tap Cancel.'),
          _buildFAQ('How do I become a provider?', 'Contact us at support@khdemti.ma to register as a service provider.'),
          _buildFAQ('Payment methods?', 'We accept cash on delivery and mobile payments.'),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 48, color: AppTheme.cobaltBlue),
                  const SizedBox(height: 12),
                  const Text('Need more help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Contact our support team'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('mailto:support@khdemti.ma')),
                    icon: const Icon(Icons.email),
                    label: const Text('Email Support'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('About Khdemti'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.handyman_rounded, size: 80, color: AppTheme.primaryRedDark)
                .animate().scale(duration: 500.ms),
            const SizedBox(height: 16),
            const Text('Khdemti', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('v1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundOffWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Khdemti is a Moroccan local services marketplace connecting customers with trusted professionals. From plumbers to electricians, we bring quality services to your doorstep.\n\nOur mission is to empower local workers and provide convenient, reliable services to every Moroccan household.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Made with love in Morocco', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('© 2026 Khdemti. All rights reserved.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
