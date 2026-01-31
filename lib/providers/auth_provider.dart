import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _profile;
  UserModel? get profile => _profile;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  User? get user => _auth.currentUser;
  
  String? _verificationId;
  String? get verificationId => _verificationId;
  
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
    
    // Check if we have an incoming email link (Web)
    await checkInitialLink();
    
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
    
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
       if (user == null) {
         _profile = null;
         notifyListeners();
       } else {
         loadProfile();
       }
    });
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
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    // We use the Firebase UID to fetch the profile from Supabase
    // This assumes your Supabase 'profiles' table uses the same ID or you map it.
    // For now, we'll try to fetch by the ID. If you need to link them, you might need a different lookup.
    // Since we are switching auth providers, we might need to handle the case where the profile doesn't exist yet differently.
    
    try {
      final supabaseProfile = await _supabaseService.getUserProfileById(firebaseUser.uid);
      if (supabaseProfile != null) {
        _profile = supabaseProfile;
        
        // Check if user is developer (god mode) based on phone
        if (supabaseProfile.phone == AppConstants.adminPhone) {
          _profile = supabaseProfile.copyWith(role: UserRole.admin);
          // Update in database
          await _supabaseService.upsertProfile(_profile!);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadProfile();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail({
    required String email, 
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Create User in Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) throw Exception("Failed to create user");

      // 2. Create Profile in Supabase
      // We manually create the user model and upsert it
      final newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone, // Optional, no verification
        role: UserRole.user,
        createdAt: DateTime.now(),
        isVerified: false, // Email verification could be a future step
      );

      await _supabaseService.upsertProfile(newUser);
      
      // 3. Load profile to state
      _profile = newUser;
      
      // 4. Send email verification
      await credential.user!.sendEmailVerification();
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    
    if (user.emailVerified) {
      throw Exception('Email already verified');
    }

    _isLoading = true;
    notifyListeners();
    try {
      await user.sendEmailVerification();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if email is verified and reload user
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    final updatedUser = _auth.currentUser;
    
    if (updatedUser?.emailVerified == true && _profile != null) {
      // Update profile in Supabase
      _profile = _profile!.copyWith(isVerified: true);
      await _supabaseService.upsertProfile(_profile!);
      notifyListeners();
      return true;
    }
    
    return updatedUser?.emailVerified ?? false;
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if we need to create a profile in Supabase
        var profile = await _supabaseService.getUserProfileById(user.uid);
        
        if (profile == null) {
           // Create new profile from Google data
           profile = UserModel(
             id: user.uid,
             email: user.email,
             fullName: user.displayName ?? 'Google User',
             avatarUrl: user.photoURL,
             role: UserRole.user,
             createdAt: DateTime.now(),
             isVerified: true, // Google accounts are verified
           );
           await _supabaseService.upsertProfile(profile);
        }
        
        _profile = profile;
      }

    } catch (e) {
      // Handle the error gracefully
      // print('Error signing in with Google: $e'); 
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  // --- Email Link (Magic Link) Auth ---

  Future<void> sendMagicLink(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://khdemti-ma.web.app/login', // Must be white-listed in Firebase Console
        handleCodeInApp: true,
        androidPackageName: 'com.zekri.khdemti',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.zekri.khdemti',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      
      // Save email locally to retrieve it when the user clicks the link
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailForSignIn', email);
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithLink(String email, String link) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_auth.isSignInWithEmailLink(link)) {
        final userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );
        
        // Handle Profile Creation/Loading
        final user = userCredential.user;
        if (user != null) {
          await _handleUserAfterLogin(user);
        }
      } else {
        throw Exception('Invalid Sign-In Link');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper to centralize profile logic
  Future<void> _handleUserAfterLogin(User user) async {
      var profile = await _supabaseService.getUserProfileById(user.uid);
      if (profile == null) {
         profile = UserModel(
           id: user.uid,
           email: user.email,
           fullName: user.displayName ?? 'User',
           role: UserRole.user,
           createdAt: DateTime.now(),
           isVerified: true,
         );
         await _supabaseService.upsertProfile(profile);
      }
      _profile = profile;
      
      // Clean up saved email
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('emailForSignIn');
  }

  // Check if app was opened from a dynamic link (Web mostly)
  Future<void> checkInitialLink() async {
    // This is primarily for Web where the URL contains the link
    // For mobile, you'd typically use 'app_links' or 'firebase_dynamic_links'
    // This example uses Uri.base which works for Flutter Web
    try {
       // Only valid for Web if we import universal_io or just use Uri.base which is available in dart:core
       final String currentLink = Uri.base.toString();
       
       if (_auth.isSignInWithEmailLink(currentLink)) {
          final prefs = await SharedPreferences.getInstance();
          final storedEmail = prefs.getString('emailForSignIn');
          
          if (storedEmail != null) {
             await signInWithLink(storedEmail, currentLink);
          } else {
             // If email not found (different device?), requested from UI
             // We can't auto-sign in.
          }
       }
    } catch (e) {
      // Ignore errors if not a link
    }
  }

  // Legacy OTP methods removed or kept for reference if needed, 
  // but User explicitly requested "update the Sign in process".
  // I will comment them out to clean up.

  Future<void> signInWithOtp(String phone) async {
    _isLoading = true;
    notifyListeners();
    
    final completer = Completer<void>();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await loadProfile();
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      
      await completer.future; // Wait until code is sent or verification completes
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) {
      throw Exception('Verification ID is missing. Request OTP first.');
    }
    
    _isLoading = true;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
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
    
    await _auth.signOut();
    _profile = null;
    _isDemoMode = false;
    notifyListeners();
  }

  // We can't use Supabase real-time auth stream for the User object anymore
  // But we can fallback to just exposing the profile.
  Stream<UserModel?> get profileStream async* {
     // Start with current
     yield _profile;
     
     await for (final user in _auth.authStateChanges()) {
        if (user == null) {
          yield null;
        } else {
           // Reload profile
           await loadProfile();
           yield _profile;
        }
     }
  }
}
