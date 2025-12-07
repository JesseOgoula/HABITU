import 'package:hive/hive.dart';

part 'circle.g.dart';

/// A Circle (Cercle) is a group of users who hold each other accountable
/// for completing their habits. Core feature of HABITU's Ubuntu philosophy.
@HiveType(typeId: 1)
class Circle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String creatorId;

  @HiveField(4)
  List<String> memberIds;

  @HiveField(5)
  List<String> habitIds; // Habits tracked by this circle

  @HiveField(6)
  String? emoji; // Circle icon

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String _inviteCode; // Stored invite code

  Circle({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    List<String>? memberIds,
    List<String>? habitIds,
    this.emoji,
    DateTime? createdAt,
    String? inviteCode,
  }) : memberIds = memberIds ?? [creatorId],
       habitIds = habitIds ?? [],
       createdAt = createdAt ?? DateTime.now(),
       _inviteCode = inviteCode ?? '';

  /// Get member count
  int get memberCount => memberIds.length;

  /// Check if user is a member
  bool isMember(String userId) => memberIds.contains(userId);

  /// Check if user is the creator
  bool isCreator(String userId) => creatorId == userId;

  /// Add a member to the circle
  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
      save();
    }
  }

  /// Remove a member from the circle
  void removeMember(String userId) {
    if (userId != creatorId) {
      memberIds.remove(userId);
      save();
    }
  }

  /// Add a habit to track in this circle
  void addHabit(String habitId) {
    if (!habitIds.contains(habitId)) {
      habitIds.add(habitId);
      save();
    }
  }

  /// Get or generate invite code
  String get inviteCode =>
      _inviteCode.isNotEmpty ? _inviteCode : id.substring(0, 8).toUpperCase();

  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    List<String>? memberIds,
    List<String>? habitIds,
    String? emoji,
    DateTime? createdAt,
    String? inviteCode,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? List.from(this.memberIds),
      habitIds: habitIds ?? List.from(this.habitIds),
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? _inviteCode,
    );
  }
}
