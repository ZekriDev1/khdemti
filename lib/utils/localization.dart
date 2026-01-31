import 'package:flutter/material.dart';

class L10n {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Khdemti',
      'find_service': 'Find a Service',
      'search_placeholder': 'Search for any service...',
      'categories': 'Categories',
      'see_all': 'See All',
      'home': 'Home',
      'bookings': 'Bookings',
      'chat': 'Chat',
      'profile': 'Profile',
      'urgent': 'URGENT',
      'book_now': 'Book Now',
      'confirm_booking': 'Confirm Booking',
      'welcome': 'Welcome',
    },
    'fr': {
      'title': 'Khdemti',
      'find_service': 'Trouver un Service',
      'search_placeholder': 'Rechercher un service...',
      'categories': 'Catégories',
      'see_all': 'Voir tout',
      'home': 'Accueil',
      'bookings': 'Réservations',
      'chat': 'Messages',
      'profile': 'Profil',
      'urgent': 'URGENT',
      'book_now': 'Réserver',
      'confirm_booking': 'Confirmer la réservation',
      'welcome': 'Bienvenue',
    },
    'ar': {
      'title': 'خدمتي',
      'find_service': 'ابحث عن خدمة',
      'search_placeholder': 'ابحث عن أي خدمة...',
      'categories': 'التصنيفات',
      'see_all': 'عرض الكل',
      'home': 'الرئيسية',
      'bookings': 'حجوزاتي',
      'chat': 'الرسائل',
      'profile': 'ملفي',
      'urgent': 'طوارئ',
      'book_now': 'احجز الآن',
      'confirm_booking': 'تأكيد الحجز',
      'welcome': 'مرحباً',
    },
  };

  static String get(BuildContext context, String key) {
    // Basic locale detection - defaults to EN for now or you can hook up to a provider
    return _localizedValues['en']![key] ?? key;
    // To implement real switching, we'd need a Provider<Locale>.
  }
  
  static String tr(String key) => _localizedValues['en']![key] ?? key;
}
