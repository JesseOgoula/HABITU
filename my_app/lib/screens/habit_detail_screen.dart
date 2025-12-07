import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Detailed view of a single habit with stats, graphs and calendar
class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  // Calculate stats
  int get _totalCompletions => habit.completedDates.length;

  int get _currentStreak {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      if (habit.isCompletedOn(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get _thisMonthCompletions {
    final now = DateTime.now();
    return habit.completedDates.where((dateStr) {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final year = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      return year == now.year && month == now.month;
    }).length;
  }

  double get _successRate {
    // Calculate based on days since first completion
    if (habit.completedDates.isEmpty) return 0;
    const daysSinceStart = 30; // Assume 30 days for now
    return (_totalCompletions / daysSinceStart * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail Habitude',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Edit habit
            },
            child: Text(
              'Modifier',
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : AppTheme.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit name and icon
            _buildHabitHeader(isDark),
            const SizedBox(height: 20),

            // Tags row
            _buildTagsRow(isDark),
            const SizedBox(height: 20),

            // Stats row
            _buildStatsRow(isDark),
            const SizedBox(height: 24),

            // Year progress chart
            _buildYearProgressSection(isDark),
            const SizedBox(height: 24),

            // Heatmap calendar
            _buildHeatmapSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(habit.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créée le ${_formatDate(DateTime.now().subtract(Duration(days: _totalCompletions)))}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(bool isDark) {
    return Row(
      children: [
        _buildTag(isDark, Icons.repeat, _getCategoryLabel()),
        const SizedBox(width: 12),
        _buildTag(
          isDark,
          Icons.notifications_outlined,
          habit.scheduledTime ?? 'Pas de rappel',
        ),
      ],
    );
  }

  Widget _buildTag(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(isDark, '$_currentStreak', 'Série'),
          _buildDivider(isDark),
          _buildStatItem(isDark, '$_totalCompletions', 'Total'),
          _buildDivider(isDark),
          _buildStatItem(isDark, '$_thisMonthCompletions', 'Ce mois'),
          _buildDivider(isDark),
          _buildStatItem(isDark, '${_successRate.round()}%', 'Taux'),
        ],
      ),
    );
  }

  Widget _buildStatItem(bool isDark, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildYearProgressSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression Annuelle',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final monthCompletions = _getMonthCompletions(index + 1);
                final maxHeight = 100.0;
                final barHeight = (monthCompletions / 20 * maxHeight).clamp(
                  4.0,
                  maxHeight,
                );

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : AppTheme.lightText,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMonthLabel(index + 1),
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Glisser pour voir plus',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHeatmapCalendar(isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem(isDark, true, 'Complété'),
              const SizedBox(width: 16),
              _buildLegendItem(isDark, false, 'Manqué'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCalendar(bool isDark) {
    final now = DateTime.now();
    final weeks = 12; // Show last 12 weeks

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Column(
            children: ['', 'Lun', '', 'Mer', '', 'Ven', '']
                .map(
                  (day) => SizedBox(
                    height: 16,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(width: 4),
          // Calendar grid
          Row(
            children: List.generate(weeks, (weekIndex) {
              final weekStart = now.subtract(
                Duration(days: (weeks - 1 - weekIndex) * 7),
              );

              return Column(
                children: List.generate(7, (dayIndex) {
                  final date = weekStart.add(
                    Duration(days: dayIndex - weekStart.weekday + 1),
                  );
                  final isCompleted = habit.isCompletedOn(date);
                  final isFuture = date.isAfter(now);

                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.transparent
                          : isCompleted
                          ? (isDark ? Colors.white : AppTheme.lightText)
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(3),
                      border: isFuture
                          ? Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                            )
                          : null,
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(bool isDark, bool isSuccess, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isSuccess
                ? (isDark ? Colors.white : AppTheme.lightText)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel() {
    switch (habit.category) {
      case HabitCategory.morning:
        return 'Tous les matins';
      case HabitCategory.evening:
        return 'Tous les soirs';
      case HabitCategory.anytime:
        return 'Quotidien';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthLabel(int month) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return labels[month - 1];
  }

  int _getMonthCompletions(int month) {
    final now = DateTime.now();
    return habit.completedDates.where((dateStr) {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final year = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return year == now.year && m == month;
    }).length;
  }
}
