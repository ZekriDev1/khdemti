class AppLocale {
  static const String defaultLocale = 'en';
  
  // Supported locales
  static const List<String> supportedLocales = ['en', 'ar', 'fr'];
  
  // Translations
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // Home Screen
      'hello': 'Hello',
      'find_service': 'Find a Service',
      'what_need': 'What do you need?',
      'categories': 'Categories',
      'view_all': 'View All',
      'sponsored': 'SPONSORED',
      'promo': 'PROMO',
      'off': 'OFF',
      'home_cleaning': 'Home Cleaning',
      
      // Navigation
      'home': 'Home',
      'bookings': 'Bookings',
      'chat': 'Chat',
      'profile': 'Profile',
      
      // Bookings
      'my_bookings': 'My Bookings',
      'manage_appointments': 'Manage your appointments',
      'active': 'Active',
      'history': 'History',
      'no_bookings': 'No bookings',
      'contact': 'Contact',
      'track': 'Track',
      
      // Auth
      'welcome_back': 'Welcome Back',
      'login_service': 'Login to ask for a service',
      'phone_number': 'Phone Number',
      'send_code': 'Send Code',
      'terms_conditions': 'By continuing, you agree to our Terms & Conditions.',
      
      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
    },
    'ar': {
      // Home Screen
      'hello': 'مرحبا',
      'find_service': 'ابحث عن خدمة',
      'what_need': 'ماذا تحتاج؟',
      'categories': 'الفئات',
      'view_all': 'عرض الكل',
      'sponsored': 'إعلان',
      'promo': 'عرض',
      'off': 'خصم',
      'home_cleaning': 'تنظيف المنزل',
      
      // Navigation
      'home': 'الرئيسية',
      'bookings': 'الحجوزات',
      'chat': 'المحادثات',
      'profile': 'الملف الشخصي',
      
      // Bookings
      'my_bookings': 'حجوزاتي',
      'manage_appointments': 'إدارة مواعيدك',
      'active': 'نشط',
      'history': 'السجل',
      'no_bookings': 'لا توجد حجوزات',
      'contact': 'اتصال',
      'track': 'تتبع',
      
      // Auth
      'welcome_back': 'مرحبا بعودتك',
      'login_service': 'سجل الدخول لطلب خدمة',
      'phone_number': 'رقم الهاتف',
      'send_code': 'إرسال الرمز',
      'terms_conditions': 'بالمتابعة، أنت توافق على الشروط والأحكام.',
      
      // Common
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
    },
    'fr': {
      // Home Screen
      'hello': 'Bonjour',
      'find_service': 'Trouver un service',
      'what_need': 'De quoi avez-vous besoin?',
      'categories': 'Catégories',
      'view_all': 'Voir tout',
      'sponsored': 'SPONSORISÉ',
      'promo': 'PROMO',
      'off': 'RÉDUCTION',
      'home_cleaning': 'Nettoyage à domicile',
      
      // Navigation
      'home': 'Accueil',
      'bookings': 'Réservations',
      'chat': 'Chat',
      'profile': 'Profil',
      
      // Bookings
      'my_bookings': 'Mes réservations',
      'manage_appointments': 'Gérer vos rendez-vous',
      'active': 'Actif',
      'history': 'Historique',
      'no_bookings': 'Aucune réservation',
      'contact': 'Contacter',
      'track': 'Suivre',
      
      // Auth
      'welcome_back': 'Bon retour',
      'login_service': 'Connectez-vous pour demander un service',
      'phone_number': 'Numéro de téléphone',
      'send_code': 'Envoyer le code',
      'terms_conditions': 'En continuant, vous acceptez nos conditions générales.',
      
      // Common
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
    },
  };
  
  static String translate(String key, String locale) {
    return translations[locale]?[key] ?? translations[defaultLocale]![key] ?? key;
  }
}
