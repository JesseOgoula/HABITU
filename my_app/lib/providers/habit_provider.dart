import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  late Box<Habit> _habitBox;
  final Uuid _uuid = const Uuid();
  DateTime _selectedDate = DateTime.now();

  List<Habit> get habits => _habitBox.values.toList();
  DateTime get selectedDate => _selectedDate;

  List<Habit> get morningHabits =>
      habits.where((h) => h.category == HabitCategory.morning).toList();

  List<Habit> get eveningHabits =>
      habits.where((h) => h.category == HabitCategory.evening).toList();

  List<Habit> get anytimeHabits =>
      habits.where((h) => h.category == HabitCategory.anytime).toList();

  int get completedTodayCount =>
      habits.where((h) => h.isCompletedOn(_selectedDate)).length;

  int get totalHabitsCount => habits.length;

  Future<void> init() async {
    _habitBox = await Hive.openBox<Habit>('habits');
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required String icon,
    required HabitCategory category,
    int targetMinutes = 0,
    String? scheduledTime,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      categoryIndex: category.index,
      targetMinutes: targetMinutes,
      scheduledTime: scheduledTime,
    );
    await _habitBox.put(habit.id, habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await habit.save();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    notifyListeners();
  }

  void toggleHabitCompletion(Habit habit) {
    habit.toggleCompletion(_selectedDate);
    notifyListeners();
  }

  bool isHabitCompleted(Habit habit) {
    return habit.isCompletedOn(_selectedDate);
  }
}
