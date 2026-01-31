import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/locale.dart';

class LocaleProvider extends ChangeNotifier {
  String _currentLocale = AppLocale.defaultLocale;
  
  String get currentLocale => _currentLocale;
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString('app_locale') ?? AppLocale.defaultLocale;
    notifyListeners();
  }
  
  Future<void> setLocale(String locale) async {
    if (!AppLocale.supportedLocales.contains(locale)) return;
    
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    notifyListeners();
  }
  
  String translate(String key) {
    return AppLocale.translate(key, _currentLocale);
  }
  
  bool get isRTL => _currentLocale == 'ar';
}
