import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/habit_sync_service.dart';

/// Sync state for UI feedback
enum SyncState { idle, syncing, synced, error }

class HabitProvider extends ChangeNotifier {
  late Box<Habit> _habitBox;
  final Uuid _uuid = const Uuid();
  DateTime _selectedDate = DateTime.now();

  // Sync service integration
  final HabitSyncService _syncService = HabitSyncService();
  SyncState _syncState = SyncState.idle;
  String? _syncErrorMessage;

  List<Habit> get habits => _habitBox.values.toList();
  DateTime get selectedDate => _selectedDate;
  SyncState get syncState => _syncState;
  String? get syncErrorMessage => _syncErrorMessage;

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
    await _syncService.init();

    // Pull data from cloud on startup
    await _syncService.pullFromCloud();

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

    // Save locally first (instant)
    await _habitBox.put(habit.id, habit);
    notifyListeners();

    // Queue for background sync
    await _syncService.saveHabitLocally(habit);
    _triggerBackgroundSync();
  }

  Future<void> updateHabit(Habit habit) async {
    await habit.save();
    notifyListeners();

    await _syncService.saveHabitLocally(habit);
    _triggerBackgroundSync();
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    notifyListeners();

    await _syncService.deleteHabit(id);
  }

  void toggleHabitCompletion(Habit habit) {
    habit.toggleCompletion(_selectedDate);
    notifyListeners();

    // Queue completion for sync
    _syncService.completeHabitLocally(habit.id, _selectedDate);
    _triggerBackgroundSync();
  }

  bool isHabitCompleted(Habit habit) {
    return habit.isCompletedOn(_selectedDate);
  }

  /// Trigger background sync (debounced)
  Future<void> _triggerBackgroundSync() async {
    // Don't sync if already syncing
    if (_syncState == SyncState.syncing) return;

    // Wait a bit to batch multiple changes
    await Future.delayed(const Duration(seconds: 2));

    await syncNow();
  }

  /// Force immediate sync
  Future<void> syncNow() async {
    _syncState = SyncState.syncing;
    _syncErrorMessage = null;
    notifyListeners();

    final result = await _syncService.syncToCloud();

    if (result.success) {
      _syncState = SyncState.synced;
    } else {
      _syncState = SyncState.error;
      _syncErrorMessage = result.message;
    }
    notifyListeners();

    // Reset to idle after a delay
    await Future.delayed(const Duration(seconds: 3));
    if (_syncState == SyncState.synced) {
      _syncState = SyncState.idle;
      notifyListeners();
    }
  }

  /// Sync from cloud (called externally)
  Future<void> syncFromCloud(String userId) async {
    if (_syncState == SyncState.syncing) return;

    _syncState = SyncState.syncing;
    notifyListeners();

    try {
      await _syncService.pullFromCloud();
      _syncState = SyncState.synced;
    } catch (e) {
      _syncState = SyncState.error;
      _syncErrorMessage = e.toString();
    }
    notifyListeners();
  }
}
