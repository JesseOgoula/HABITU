import 'package:hive/hive.dart';

part 'habit.g.dart';

enum HabitCategory { morning, evening, anytime }

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int categoryIndex;

  @HiveField(4)
  int targetMinutes;

  @HiveField(5)
  String? scheduledTime;

  @HiveField(6)
  List<String> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryIndex,
    this.targetMinutes = 0,
    this.scheduledTime,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  HabitCategory get category => HabitCategory.values[categoryIndex];
  set category(HabitCategory cat) => categoryIndex = cat.index;

  bool isCompletedOn(DateTime date) {
    final dateStr = _formatDate(date);
    return completedDates.contains(dateStr);
  }

  void toggleCompletion(DateTime date) {
    final dateStr = _formatDate(date);
    if (completedDates.contains(dateStr)) {
      completedDates.remove(dateStr);
    } else {
      completedDates.add(dateStr);
    }
    save();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? categoryIndex,
    int? targetMinutes,
    String? scheduledTime,
    List<String>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedDates: completedDates ?? List.from(this.completedDates),
    );
  }
}
