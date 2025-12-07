import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/circle.dart';
import '../services/circle_sync_service.dart';

/// Provider for managing Circles (Cercles Habitu)
/// Implements offline-first with Supabase sync
class CircleProvider extends ChangeNotifier {
  late Box<Circle> _circleBox;
  final CircleSyncService _syncService = CircleSyncService();
  bool _isInitialized = false;
  bool _isSyncing = false;

  List<Circle> get circles => _circleBox.values.toList();
  bool get isSyncing => _isSyncing;

  /// Get circles where user is a member
  List<Circle> getMyCircles(String userId) {
    return circles.where((c) => c.isMember(userId)).toList();
  }

  /// Get circles created by user
  List<Circle> getCreatedCircles(String userId) {
    return circles.where((c) => c.isCreator(userId)).toList();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _circleBox = await Hive.openBox<Circle>('circles');
    _isInitialized = true;
    notifyListeners();
  }

  /// Sync circles from Supabase
  Future<void> syncFromCloud(String userId) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final cloudCircles = await _syncService.fetchUserCircles(userId);

      // Update local storage with cloud data
      for (final circle in cloudCircles) {
        await _circleBox.put(circle.id, circle);
      }

      // Remove circles no longer in cloud
      final cloudIds = cloudCircles.map((c) => c.id).toSet();
      final localIds = _circleBox.keys.toSet();
      for (final localId in localIds) {
        if (!cloudIds.contains(localId)) {
          await _circleBox.delete(localId);
        }
      }
    } catch (e) {
      print('Error syncing circles: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  /// Create a new circle
  Future<Circle> createCircle({
    required String name,
    required String creatorId,
    String? description,
    String? emoji,
  }) async {
    // Try cloud first
    final cloudCircle = await _syncService.createCircle(
      name: name,
      creatorId: creatorId,
      description: description,
      emoji: emoji,
    );

    if (cloudCircle != null) {
      await _circleBox.put(cloudCircle.id, cloudCircle);
      notifyListeners();
      return cloudCircle;
    }

    // Fallback to local only
    final circle = Circle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      creatorId: creatorId,
      description: description,
      emoji: emoji ?? '🌍',
    );
    await _circleBox.put(circle.id, circle);
    notifyListeners();
    return circle;
  }

  /// Join a circle by invite code
  Future<bool> joinCircleByCode(String code, String userId) async {
    // Try cloud first
    final cloudCircle = await _syncService.joinCircleByCode(code, userId);

    if (cloudCircle != null) {
      await _circleBox.put(cloudCircle.id, cloudCircle);
      notifyListeners();
      return true;
    }

    // Fallback to local search
    final circle = circles.firstWhere(
      (c) => c.inviteCode == code.toUpperCase(),
      orElse: () => Circle(id: '', name: '', creatorId: ''),
    );

    if (circle.id.isEmpty) return false;

    circle.addMember(userId);
    notifyListeners();
    return true;
  }

  /// Leave a circle
  Future<void> leaveCircle(String circleId, String userId) async {
    // Try cloud
    await _syncService.leaveCircle(circleId, userId);

    // Update local
    final circle = _circleBox.get(circleId);
    if (circle != null) {
      circle.removeMember(userId);
      if (!circle.isMember(userId)) {
        await _circleBox.delete(circleId);
      }
      notifyListeners();
    }
  }

  /// Delete a circle (only creator can do this)
  Future<void> deleteCircle(String circleId, String userId) async {
    final circle = _circleBox.get(circleId);
    if (circle != null && circle.isCreator(userId)) {
      // Try cloud
      await _syncService.deleteCircle(circleId, userId);

      // Delete local
      await _circleBox.delete(circleId);
      notifyListeners();
    }
  }

  /// Get a circle by ID
  Circle? getCircle(String circleId) => _circleBox.get(circleId);

  /// Get members of a circle from cloud
  Future<List<Map<String, dynamic>>> getCircleMembers(String circleId) async {
    return await _syncService.getCircleMembers(circleId);
  }

  /// Calculate circle completion rate for today
  double getCircleCompletionRate(
    Circle circle,
    Map<String, bool> memberCompletions,
  ) {
    if (circle.memberCount == 0) return 0;
    final completedCount = memberCompletions.values.where((v) => v).length;
    return completedCount / circle.memberCount;
  }

  /// Check if circle is fully complete today
  bool isCircleComplete(Circle circle, Map<String, bool> memberCompletions) {
    return circle.memberIds.every((id) => memberCompletions[id] == true);
  }
}
