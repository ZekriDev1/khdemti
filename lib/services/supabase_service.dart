import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // AUTH
  Future<void> signInWithOtp(String phone) async {
    await client.auth.signInWithOtp(phone: phone, shouldCreateUser: true);
  }

  Future<AuthResponse> verifyOtp(String phone, String token) async {
    return await client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  // PROFILES
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await client.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await client.from('profiles').upsert({'id': user.id, ...data});
  }

  Stream<Map<String, dynamic>?> profileStream() {
    final user = currentUser;
    if (user == null) return Stream.value(null);
    return client.from('profiles').stream(primaryKey: ['id']).eq('id', user.id).map((list) => list.isNotEmpty ? list.first : null);
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    return await client.from('services').select().order('name');
  }

  Future<List<Map<String, dynamic>>> getProviders({String? serviceId}) async {
    var query = client.from('profiles').select().eq('role', 'provider');
    if (serviceId != null) {
      final providerIds = await client.from('provider_services').select('provider_id').eq('service_id', serviceId);
      final ids = (providerIds as List).map((e) => e['provider_id']).toList();
      if (ids.isEmpty) return [];
      query = client.from('profiles').select().inFilter('id', ids);
    }
    return await query;
  }

  Future<Map<String, dynamic>?> getProviderById(String id) async {
    return await client.from('profiles').select().eq('id', id).maybeSingle();
  }

  Future<double> getProviderRating(String providerId) async {
    final result = await client.from('ratings').select('rating').eq('target_id', providerId);
    if (result.isEmpty) return 0.0;
    final ratings = (result as List).map((e) => (e['rating'] as num).toDouble()).toList();
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final user = currentUser;
    if (user == null) return [];
    return await client.from('bookings').select('*, services(*), profiles!bookings_provider_id_fkey(*)').eq('customer_id', user.id).order('created_at', ascending: false);
  }

  Future<void> createBooking({
    required String serviceId,
    String? providerId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
    bool isUrgent = false,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await client.from('bookings').insert({
      'customer_id': user.id,
      'provider_id': providerId,
      'service_id': serviceId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'address': address,
      'notes': notes,
      'is_urgent': isUrgent,
      'status': 'pending',
    });
  }

  // ADMIN
  Future<bool> isAdmin() async {
    final profile = await getUserProfile();
    return profile?['role'] == 'admin' || profile?['role'] == 'super_admin';
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await client.from('profiles').select().order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    return await client.from('bookings').select('*, services(*), profiles!bookings_customer_id_fkey(*), profiles!bookings_provider_id_fkey(*)').order('created_at', ascending: false);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await client.from('profiles').update({'role': role}).eq('id', userId);
  }

  Future<void> createProviderProfile({
    required String fullName,
    required String phone,
    required int age,
    required double rating,
    required List<String> serviceIds,
    String? bio,
  }) async {
    // 0. Check if exists
    final existing = await client.from('profiles').select().eq('phone', phone).maybeSingle();
    
    String providerId;
    
    if (existing != null) {
      // User exists, just update role and fields
      providerId = existing['id'];
      await client.from('profiles').update({
        'role': 'provider', // Promote to provider
        'full_name': fullName,
        'age': age,
        'manual_rating': rating,
        'bio': bio,
        'is_verified': true,
      }).eq('id', providerId);
    } else {
      // 1. Create New Profile
      final profileRes = await client.from('profiles').insert({
        'full_name': fullName,
        'phone': phone,
        'age': age,
        'manual_rating': rating,
        'role': 'provider',
        'bio': bio,
        'is_online': true,
        'is_verified': true,
      }).select().single();
      providerId = profileRes['id'];
    }

    // 2. Add Services (Upsert to avoid duplicates)
    if (serviceIds.isNotEmpty) {
      final servicesData = serviceIds.map((id) => {
        'provider_id': providerId,
        'service_id': id,
        'is_available': true,
      }).toList();
      
      await client.from('provider_services').upsert(servicesData);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await client.from('bookings').update({'status': status}).eq('id', bookingId);
  }

  // ADDRESSES
  Future<List<Map<String, dynamic>>> getSavedAddresses() async {
    final user = currentUser;
    if (user == null) return [];
    return await client.from('saved_addresses').select().eq('user_id', user.id);
  }

  Future<void> saveAddress(Map<String, dynamic> address) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await client.from('saved_addresses').insert({'user_id': user.id, ...address});
  }

  Future<void> deleteAddress(String addressId) async {
    await client.from('saved_addresses').delete().eq('id', addressId);
  }

  // CHAT
  Stream<List<Map<String, dynamic>>> getMessages(String bookingId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true);
  }

  Future<void> sendMessage({
    required String bookingId,
    required String content,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await client.from('messages').insert({
      'booking_id': bookingId,
      'sender_id': user.id,
      'content': content,
    });
  }
}
