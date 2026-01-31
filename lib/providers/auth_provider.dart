import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _profile;
  UserModel? get profile => _profile;

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
      _profile = UserModel(
        id: 'admin_local',
        fullName: 'Akram Zekri',
        phone: '+212613415008',
        role: UserRole.super_admin,
        createdAt: DateTime.now(),
        isVerified: true,
      );
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
    _profile = UserModel(
      id: 'admin_local',
      fullName: 'Akram Zekri',
      phone: '+212613415008',
      role: UserRole.super_admin,
      createdAt: DateTime.now(),
      isVerified: true,
    );
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final supabaseProfile = await _supabaseService.getUserProfile();
    if (supabaseProfile != null) {
      _profile = supabaseProfile;
      _isAdmin = supabaseProfile.role == UserRole.admin || supabaseProfile.role == UserRole.super_admin;
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

  Future<void> updateProfile(UserModel userModel) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.upsertProfile(userModel);
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

  Stream<UserModel?> get profileStream => _supabaseService.profileStream();
}
