import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user profiles in Supabase
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Get the Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Create or update a user profile in Supabase
  Future<void> createOrUpdateProfile({
    required String id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('Creating/updating profile for user: $id');

      await _supabase.from('profil').upsert({
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Profile saved successfully');
    } catch (e) {
      debugPrint('Error saving profile: $e');
      rethrow;
    }
  }

  /// Get a user profile by ID
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profil')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Check if a profile exists for the given user ID
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _supabase
          .from('profil')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking profile existence: $e');
      return false;
    }
  }
}
