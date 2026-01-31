import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  User? get user => _supabaseService.currentUser;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocalAdmin = prefs.getBool('is_admin_logged_in') ?? false;
    
    if (isLocalAdmin) {
      _isAdmin = true;
      _profile = {
        'full_name': 'Super Admin',
        'role': 'super_admin',
        'phone': '+212691157363',
      };
      notifyListeners();
    }

    if (user != null) {
      await loadProfile();
    }
  }

  Future<void> loginAdminLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin_logged_in', true);
    _isAdmin = true;
    _profile = {
      'full_name': 'Super Admin',
      'role': 'super_admin',
      'phone': '+212691157363',
    };
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final supabaseProfile = await _supabaseService.getUserProfile();
    if (supabaseProfile != null) {
      _profile = supabaseProfile;
      _isAdmin = await _supabaseService.isAdmin();
    }
    notifyListeners();
  }

  Future<void> signInWithOtp(String phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.signInWithOtp(phone);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phone, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.verifyOtp(phone, token);
      await loadProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.upsertProfile(data);
      await loadProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin_logged_in');
    await _supabaseService.signOut();
    _profile = null;
    _isAdmin = false;
    notifyListeners();
  }

  Stream<Map<String, dynamic>?> get profileStream => _supabaseService.profileStream();
}
