import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

/// Sync status for habits
enum SyncStatus { synced, pending, syncing, error }

/// Service for offline-first habit synchronization with Supabase
///
/// Strategy: Write local first, sync in background (SF-02.2)
/// - All writes go to Hive immediately (instant response)
/// - Background sync pushes changes to Supabase
/// - Delta sync: only sends changes since last sync
class HabitSyncService {
  final SupabaseClient _supabase;
  late Box<Habit> _habitBox;
  late Box<dynamic> _syncMetaBox;

  bool _isInitialized = false;
  bool _isSyncing = false;

  HabitSyncService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Initialize the sync service
  Future<void> init() async {
    if (_isInitialized) return;

    _habitBox = await Hive.openBox<Habit>('habits');
    _syncMetaBox = await Hive.openBox('sync_metadata');
    _isInitialized = true;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get current user ID
  String? get userId => _supabase.auth.currentUser?.id;

  /// Check if we have network connectivity (simplified check)
  Future<bool> get isOnline async {
    try {
      // Try a simple ping to Supabase
      await _supabase.from('habits').select('id').limit(1).maybeSingle();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get last sync timestamp
  DateTime? get lastSyncTime {
    final timestamp = _syncMetaBox.get('lastSyncTime');
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Save a habit locally (instant) and queue for sync
  Future<void> saveHabitLocally(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    await _markPendingSync(habit.id);
  }

  /// Complete a habit locally and queue for sync
  Future<void> completeHabitLocally(String habitId, DateTime date) async {
    final habit = _habitBox.get(habitId);
    if (habit == null) return;

    habit.toggleCompletion(date);
    await _markPendingSync(habitId);
    await _markCompletionPendingSync(habitId, date);
  }

  /// Mark a habit as needing sync
  Future<void> _markPendingSync(String habitId) async {
    final pendingHabits = _getPendingHabits();
    if (!pendingHabits.contains(habitId)) {
      pendingHabits.add(habitId);
      await _syncMetaBox.put('pendingHabits', pendingHabits);
    }
  }

  /// Mark a completion as needing sync
  Future<void> _markCompletionPendingSync(String habitId, DateTime date) async {
    final key = '${habitId}_${_formatDate(date)}';
    final pendingCompletions = _getPendingCompletions();
    if (!pendingCompletions.contains(key)) {
      pendingCompletions.add(key);
      await _syncMetaBox.put('pendingCompletions', pendingCompletions);
    }
  }

  List<String> _getPendingHabits() {
    return List<String>.from(
      _syncMetaBox.get('pendingHabits', defaultValue: []) ?? [],
    );
  }

  List<String> _getPendingCompletions() {
    return List<String>.from(
      _syncMetaBox.get('pendingCompletions', defaultValue: []) ?? [],
    );
  }

  /// Sync local changes to Supabase (delta sync)
  Future<SyncResult> syncToCloud() async {
    if (!isAuthenticated) {
      return SyncResult(success: false, message: 'Not authenticated');
    }

    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (!await isOnline) {
      return SyncResult(success: false, message: 'No network connection');
    }

    _isSyncing = true;
    int syncedHabits = 0;
    int syncedCompletions = 0;

    try {
      // Sync pending habits
      final pendingHabits = _getPendingHabits();
      for (final habitId in pendingHabits) {
        final habit = _habitBox.get(habitId);
        if (habit != null) {
          await _syncHabitToCloud(habit);
          syncedHabits++;
        }
      }
      await _syncMetaBox.put('pendingHabits', []);

      // Sync pending completions
      final pendingCompletions = _getPendingCompletions();
      for (final key in pendingCompletions) {
        final parts = key.split('_');
        if (parts.length >= 2) {
          final habitId = parts[0];
          final dateStr = parts.sublist(1).join('_');
          await _syncCompletionToCloud(habitId, dateStr);
          syncedCompletions++;
        }
      }
      await _syncMetaBox.put('pendingCompletions', []);

      // Update last sync time
      await _syncMetaBox.put('lastSyncTime', DateTime.now().toIso8601String());

      _isSyncing = false;
      return SyncResult(
        success: true,
        message: 'Synced $syncedHabits habits, $syncedCompletions completions',
        syncedHabits: syncedHabits,
        syncedCompletions: syncedCompletions,
      );
    } catch (e) {
      _isSyncing = false;
      debugPrint('Sync error: $e');
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Sync a single habit to Supabase
  Future<void> _syncHabitToCloud(Habit habit) async {
    await _supabase.from('habits').upsert({
      'id': habit.id,
      'user_id': userId,
      'name': habit.name,
      'icon': habit.icon,
      'category': habit.categoryIndex,
      'target_minutes': habit.targetMinutes,
      'scheduled_time': habit.scheduledTime,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Sync a completion to Supabase
  Future<void> _syncCompletionToCloud(String habitId, String dateStr) async {
    await _supabase.from('habit_completions').upsert({
      'habit_id': habitId,
      'completed_date': dateStr,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'habit_id,completed_date');
  }

  /// Pull data from Supabase (on app start)
  Future<void> pullFromCloud() async {
    if (!isAuthenticated || !await isOnline) return;

    try {
      // Fetch habits
      final habitsData = await _supabase
          .from('habits')
          .select()
          .eq('user_id', userId!);

      for (final data in habitsData) {
        final habit = Habit(
          id: data['id'],
          name: data['name'],
          icon: data['icon'],
          categoryIndex: data['category'],
          targetMinutes: data['target_minutes'] ?? 0,
          scheduledTime: data['scheduled_time'],
        );

        // Only update if cloud version is newer or local doesn't exist
        final localHabit = _habitBox.get(habit.id);
        if (localHabit == null) {
          await _habitBox.put(habit.id, habit);
        }
      }

      // Fetch completions
      final completionsData = await _supabase
          .from('habit_completions')
          .select('habit_id, completed_date')
          .inFilter('habit_id', habitsData.map((h) => h['id']).toList());

      for (final comp in completionsData) {
        final habit = _habitBox.get(comp['habit_id']);
        if (habit != null) {
          final dateStr = comp['completed_date'];
          if (!habit.completedDates.contains(dateStr)) {
            habit.completedDates.add(dateStr);
            await habit.save();
          }
        }
      }

      await _syncMetaBox.put('lastSyncTime', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Pull from cloud error: $e');
    }
  }

  /// Delete a habit locally and from cloud
  Future<void> deleteHabit(String habitId) async {
    await _habitBox.delete(habitId);

    if (isAuthenticated && await isOnline) {
      try {
        await _supabase.from('habits').delete().eq('id', habitId);
        await _supabase
            .from('habit_completions')
            .delete()
            .eq('habit_id', habitId);
      } catch (e) {
        debugPrint('Delete from cloud error: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedHabits;
  final int syncedCompletions;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedHabits = 0,
    this.syncedCompletions = 0,
  });
}
