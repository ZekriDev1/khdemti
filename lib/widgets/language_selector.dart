import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../utils/theme.dart';
import '../widgets/apple_widgets.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Language / اللغة / Langue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'English',
                'en',
                Icons.language,
                localeProvider,
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                'العربية',
                'ar',
                Icons.language,
                localeProvider,
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                'Français',
                'fr',
                Icons.language,
                localeProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String locale,
    IconData icon,
    LocaleProvider provider,
  ) {
    final isSelected = provider.currentLocale == locale;
    
    return GestureDetector(
      onTap: () => provider.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRedDark.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRedDark : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryRedDark : AppTheme.textGrey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryRedDark : AppTheme.textDark,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryRedDark,
              ),
          ],
        ),
      ),
    );
  }
}
