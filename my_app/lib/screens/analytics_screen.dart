import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

/// Analytics dashboard showing overall statistics
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Semaine, 1: Mois, 2: Année

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
          'Tes Statistiques',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final stats = _calculateStats(habitProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'Suis ta progression, célèbre tes victoires.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Period tabs
                _buildPeriodTabs(isDark),
                const SizedBox(height: 20),

                // Summary cards
                Text(
                  'Résumé',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryCards(isDark, stats),
                const SizedBox(height: 24),

                // Activity chart
                _buildActivityChart(isDark, stats),
                const SizedBox(height: 24),

                // Habits performance
                _buildHabitsPerformance(isDark, habitProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodTabs(bool isDark) {
    final periods = ['Semaine', 'Mois', 'Année'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : AppTheme.lightText)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  periods[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppTheme.darkBackground : Colors.white)
                        : (isDark
                              ? Colors.grey[400]
                              : AppTheme.lightTextSecondary),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark, Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                isDark,
                '${stats['completedThisPeriod']}',
                'Habitudes Complétées',
                'cette ${_getPeriodLabel()}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                isDark,
                '${stats['activeDays']}',
                'Jours Actifs',
                '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStreakCard(isDark, stats['currentStreak'])),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                isDark,
                '${stats['successRate']}%',
                'Taux de Réussite',
                '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    bool isDark,
    String value,
    String title,
    String subtitle,
  ) {
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
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDark, int streak) {
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
            children: [
              Text(
                '$streak',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              const SizedBox(width: 4),
              const Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Jours de Série',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(bool isDark, Map<String, dynamic> stats) {
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
                'Taux d\'Activité',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats['successRate']}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildChartBars(
                isDark,
                stats['dailyRates'] as List<double>,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getDayLabels()
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars(bool isDark, List<double> rates) {
    return List.generate(rates.length, (index) {
      final rate = rates[index];
      final maxHeight = 100.0;
      final barHeight = (rate / 100 * maxHeight).clamp(4.0, maxHeight);

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : AppTheme.lightText,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHabitsPerformance(bool isDark, HabitProvider provider) {
    if (provider.habits.isEmpty) return const SizedBox();

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
            'Performance par Habitude',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...provider.habits.take(5).map((habit) {
            final completions = habit.completedDates.length;
            final rate = (completions / 30 * 100).clamp(0, 100).round();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate / 100,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : AppTheme.lightText,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$rate%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.lightText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(HabitProvider provider) {
    final habits = provider.habits;
    final now = DateTime.now();

    // Calculate current streak (simplified)
    int streak = 0;
    DateTime checkDate = now;
    for (int i = 0; i < 365; i++) {
      final allCompleted =
          habits.isNotEmpty && habits.every((h) => h.isCompletedOn(checkDate));
      if (allCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate completions this period
    int completedThisPeriod = 0;
    int activeDays = 0;
    final periodDays = _selectedPeriod == 0
        ? 7
        : (_selectedPeriod == 1 ? 30 : 365);

    Set<String> activeDatesSet = {};
    for (final habit in habits) {
      for (final dateStr in habit.completedDates) {
        activeDatesSet.add(dateStr);
        // Check if within period
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          if (now.difference(date).inDays <= periodDays) {
            completedThisPeriod++;
          }
        }
      }
    }
    activeDays = activeDatesSet.length.clamp(0, periodDays);

    // Calculate success rate
    final totalPossible = habits.length * periodDays;
    final successRate = totalPossible > 0
        ? (completedThisPeriod / totalPossible * 100).round()
        : 0;

    // Daily rates for chart
    List<double> dailyRates = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final completed = habits.where((h) => h.isCompletedOn(date)).length;
      return habits.isNotEmpty ? (completed / habits.length * 100) : 0.0;
    });

    return {
      'currentStreak': streak,
      'completedThisPeriod': completedThisPeriod,
      'activeDays': activeDays,
      'successRate': successRate,
      'dailyRates': dailyRates,
    };
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 0:
        return 'semaine';
      case 1:
        return 'mois';
      case 2:
        return 'année';
      default:
        return 'semaine';
    }
  }

  List<String> _getDayLabels() {
    final now = DateTime.now();
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return days[date.weekday % 7];
    });
  }
}
