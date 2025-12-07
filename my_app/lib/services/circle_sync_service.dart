import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/circle.dart';

/// Service to synchronize circles with Supabase
class CircleSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all circles for the current user
  Future<List<Circle>> fetchUserCircles(String userId) async {
    try {
      // Get circle IDs the user is a member of
      final memberResponse = await _supabase
          .from('circle_members')
          .select('circle_id')
          .eq('user_id', userId);

      final circleIds = (memberResponse as List)
          .map((m) => m['circle_id'] as String)
          .toList();

      if (circleIds.isEmpty) return [];

      // Get circle details
      final circlesResponse = await _supabase
          .from('circles')
          .select()
          .inFilter('id', circleIds);

      final circles = <Circle>[];
      for (final data in circlesResponse) {
        // Get member count
        final membersResponse = await _supabase
            .from('circle_members')
            .select('user_id')
            .eq('circle_id', data['id']);

        final memberIds = (membersResponse as List)
            .map((m) => m['user_id'] as String)
            .toList();

        circles.add(
          Circle(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            emoji: data['emoji'],
            inviteCode: data['invite_code'],
            creatorId: data['creator_id'],
            memberIds: memberIds,
            createdAt: DateTime.parse(data['created_at']),
          ),
        );
      }

      return circles;
    } catch (e) {
      print('Error fetching circles: $e');
      return [];
    }
  }

  /// Create a new circle
  Future<Circle?> createCircle({
    required String name,
    required String creatorId,
    String? description,
    String? emoji,
  }) async {
    try {
      // Generate invite code
      final inviteCode = _generateInviteCode();

      // Insert circle
      final response = await _supabase
          .from('circles')
          .insert({
            'name': name,
            'description': description,
            'emoji': emoji ?? '🌍',
            'invite_code': inviteCode,
            'creator_id': creatorId,
          })
          .select()
          .single();

      // Add creator as member
      await _supabase.from('circle_members').insert({
        'circle_id': response['id'],
        'user_id': creatorId,
        'role': 'creator',
      });

      return Circle(
        id: response['id'],
        name: response['name'],
        description: response['description'],
        emoji: response['emoji'],
        inviteCode: response['invite_code'],
        creatorId: response['creator_id'],
        memberIds: [creatorId],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('Error creating circle: $e');
      return null;
    }
  }

  /// Join a circle by invite code
  Future<Circle?> joinCircleByCode(String inviteCode, String userId) async {
    try {
      // Find circle by invite code
      final response = await _supabase
          .from('circles')
          .select()
          .eq('invite_code', inviteCode.toUpperCase())
          .maybeSingle();

      if (response == null) return null;

      // Check if already a member
      final existingMember = await _supabase
          .from('circle_members')
          .select()
          .eq('circle_id', response['id'])
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        // Already a member, just return the circle
        return await _getCircleById(response['id']);
      }

      // Add user as member
      await _supabase.from('circle_members').insert({
        'circle_id': response['id'],
        'user_id': userId,
        'role': 'member',
      });

      return await _getCircleById(response['id']);
    } catch (e) {
      print('Error joining circle: $e');
      return null;
    }
  }

  /// Leave a circle
  Future<bool> leaveCircle(String circleId, String userId) async {
    try {
      await _supabase
          .from('circle_members')
          .delete()
          .eq('circle_id', circleId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error leaving circle: $e');
      return false;
    }
  }

  /// Delete a circle (creator only)
  Future<bool> deleteCircle(String circleId, String creatorId) async {
    try {
      // Verify creator
      final circle = await _supabase
          .from('circles')
          .select()
          .eq('id', circleId)
          .eq('creator_id', creatorId)
          .maybeSingle();

      if (circle == null) return false;

      // Delete members first (cascade should handle this, but just in case)
      await _supabase.from('circle_members').delete().eq('circle_id', circleId);

      // Delete circle
      await _supabase.from('circles').delete().eq('id', circleId);

      return true;
    } catch (e) {
      print('Error deleting circle: $e');
      return false;
    }
  }

  /// Get circle by ID
  Future<Circle?> _getCircleById(String circleId) async {
    try {
      final response = await _supabase
          .from('circles')
          .select()
          .eq('id', circleId)
          .single();

      final membersResponse = await _supabase
          .from('circle_members')
          .select('user_id')
          .eq('circle_id', circleId);

      final memberIds = (membersResponse as List)
          .map((m) => m['user_id'] as String)
          .toList();

      return Circle(
        id: response['id'],
        name: response['name'],
        description: response['description'],
        emoji: response['emoji'],
        inviteCode: response['invite_code'],
        creatorId: response['creator_id'],
        memberIds: memberIds,
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('Error getting circle: $e');
      return null;
    }
  }

  /// Get members of a circle with their profile info
  Future<List<Map<String, dynamic>>> getCircleMembers(String circleId) async {
    try {
      final response = await _supabase
          .from('circle_members')
          .select('user_id, role, joined_at')
          .eq('circle_id', circleId);

      final members = <Map<String, dynamic>>[];
      for (final member in response) {
        // Get user profile
        final profile = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', member['user_id'])
            .maybeSingle();

        members.add({
          'user_id': member['user_id'],
          'role': member['role'],
          'joined_at': member['joined_at'],
          'display_name': profile?['display_name'] ?? 'Membre',
          'avatar_url': profile?['avatar_url'],
        });
      }
      return members;
    } catch (e) {
      print('Error getting circle members: $e');
      return [];
    }
  }

  /// Generate a random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 6; i++) {
      code += chars[(random + i * 7) % chars.length];
    }
    return code;
  }
}
