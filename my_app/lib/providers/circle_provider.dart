import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/circle.dart';

/// Provider for managing Circles (Cercles Habitu)
/// Implements the Ubuntu philosophy of communal accountability
class CircleProvider extends ChangeNotifier {
  late Box<Circle> _circleBox;
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  List<Circle> get circles => _circleBox.values.toList();

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

  /// Create a new circle
  Future<Circle> createCircle({
    required String name,
    required String creatorId,
    String? description,
    String? emoji,
  }) async {
    final circle = Circle(
      id: _uuid.v4(),
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
    final circle = _circleBox.get(circleId);
    if (circle != null) {
      circle.removeMember(userId);
      notifyListeners();
    }
  }

  /// Delete a circle (only creator can do this)
  Future<void> deleteCircle(String circleId, String userId) async {
    final circle = _circleBox.get(circleId);
    if (circle != null && circle.isCreator(userId)) {
      await _circleBox.delete(circleId);
      notifyListeners();
    }
  }

  /// Get a circle by ID
  Circle? getCircle(String circleId) => _circleBox.get(circleId);

  /// Calculate circle completion rate for today
  double getCircleCompletionRate(
    Circle circle,
    Map<String, bool> memberCompletions,
  ) {
    if (circle.memberCount == 0) return 0;
    final completedCount = memberCompletions.values.where((v) => v).length;
    return completedCount / circle.memberCount;
  }

  /// Check if circle is fully complete today (all members validated)
  bool isCircleComplete(Circle circle, Map<String, bool> memberCompletions) {
    return circle.memberIds.every((id) => memberCompletions[id] == true);
  }
}
