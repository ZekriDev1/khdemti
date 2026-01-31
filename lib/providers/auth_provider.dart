import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _profile;
  UserModel? get profile => _profile;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  User? get user => _supabaseService.currentUser;
  
  // Check if user is admin (god mode)
  bool get isAdmin => _profile?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check for demo mode
    final isDemoSession = prefs.getBool('is_demo_mode') ?? false;
    if (isDemoSession) {
      await enableDemoMode();
      return;
    }
    
    // Check for admin session
    final isLocalAdmin = prefs.getBool('is_admin_logged_in') ?? false;
    if (isLocalAdmin) {
      _profile = UserModel(
        id: 'admin_local',
        fullName: 'Akram Zekri',
        phone: '+212613415008',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        isVerified: true,
      );
      notifyListeners();
      return;
    }

    // Check for authenticated user
    if (user != null) {
      await loadProfile();
    }
  }

  Future<void> loginAdminLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin_logged_in', true);
    await prefs.remove('is_demo_mode');
    
    _isDemoMode = false;
    _profile = UserModel(
      id: 'admin_local',
      fullName: 'Akram Zekri',
      phone: '+212613415008',
      role: UserRole.admin,
      createdAt: DateTime.now(),
      isVerified: true,
    );
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final supabaseProfile = await _supabaseService.getUserProfile();
    if (supabaseProfile != null) {
      _profile = supabaseProfile;
      
      // Check if user is developer (god mode) based on phone
      if (supabaseProfile.phone == AppConstants.adminPhone) {
        _profile = supabaseProfile.copyWith(role: UserRole.admin);
        // Update in database
        await _supabaseService.upsertProfile(_profile!);
      }
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
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
      
      // Clear demo mode if switching to real account
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_demo_mode');
      _isDemoMode = false;
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
  
  // Apply to become a worker
  Future<void> applyAsWorker(String workerType) async {
    if (_profile == null || _isDemoMode) {
      throw Exception('Must be logged in to apply as worker');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Update user role to worker immediately
      final updatedProfile = _profile!.copyWith(
        role: UserRole.worker,
        workerType: workerType,
      );
      
      await _supabaseService.upsertProfile(updatedProfile);
      _profile = updatedProfile;
      
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enable demo mode (guest access)
  Future<void> enableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', true);
    await prefs.remove('is_admin_logged_in');
    
    _isDemoMode = true;
    _profile = UserModel.demoUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin_logged_in');
    await prefs.remove('is_demo_mode');
    
    await _supabaseService.signOut();
    _profile = null;
    _isDemoMode = false;
    notifyListeners();
  }

  Stream<UserModel?> get profileStream => _supabaseService.profileStream();
}
