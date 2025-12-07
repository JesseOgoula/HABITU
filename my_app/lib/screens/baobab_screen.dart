import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/baobab_tree.dart';
import '../theme/app_theme.dart';

/// Screen showing the Baobab tree progression visualization
class BaobabScreen extends StatelessWidget {
  const BaobabScreen({super.key});

  int _calculateLevel(int totalCompletions) {
    // Level thresholds
    if (totalCompletions >= 500) return 10;
    if (totalCompletions >= 300) return 9;
    if (totalCompletions >= 200) return 8;
    if (totalCompletions >= 150) return 7;
    if (totalCompletions >= 100) return 6;
    if (totalCompletions >= 70) return 5;
    if (totalCompletions >= 50) return 4;
    if (totalCompletions >= 30) return 3;
    if (totalCompletions >= 15) return 2;
    return 1;
  }

  int _getNextLevelThreshold(int currentLevel) {
    const thresholds = [0, 15, 30, 50, 70, 100, 150, 200, 300, 500, 1000];
    if (currentLevel >= thresholds.length - 1) return thresholds.last;
    return thresholds[currentLevel];
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
          'Mon Baobab',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final totalCompletions = habitProvider.habits.fold<int>(
            0,
            (sum, habit) => sum + habit.completedDates.length,
          );
          final level = _calculateLevel(totalCompletions);
          final nextThreshold = _getNextLevelThreshold(level);
          final progress = level < 10 ? totalCompletions / nextThreshold : 1.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Intro text
                Text(
                  'Ton Baobab grandit avec tes habitudes',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Baobab tree
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      BaobabTree(
                        level: level,
                        totalCompletions: totalCompletions,
                        size: 250,
                      ),
                      const SizedBox(height: 24),
                      // Level indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Niveau $level',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (level < 10)
                            Text(
                              '/ 10',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress to next level
                if (level < 10)
                  _buildProgressCard(
                    context,
                    isDark,
                    totalCompletions,
                    nextThreshold,
                    progress,
                  ),
                const SizedBox(height: 16),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        '$totalCompletions',
                        'Habitudes complétées',
                        '✅',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        '${habitProvider.habits.length}',
                        'Habitudes actives',
                        '📋',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Growth stages
                _buildStagesCard(context, isDark, level),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    bool isDark,
    int current,
    int target,
    double progress,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression vers le niveau suivant',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? Colors.grey[400]
                      : AppTheme.lightTextSecondary,
                ),
              ),
              Text(
                '$current / $target',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white : AppTheme.lightText,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${target - current} habitudes restantes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(bool isDark, String value, String label, String emoji) {
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStagesCard(BuildContext context, bool isDark, int currentLevel) {
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
            'Étapes de croissance',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...BaobabTree.stages.map((stage) {
            final minLevel = stage['minLevel'] as int;
            final isUnlocked = currentLevel >= minLevel;
            final isCurrent =
                currentLevel >= minLevel &&
                (BaobabTree.stages.indexOf(stage) ==
                        BaobabTree.stages.length - 1 ||
                    currentLevel <
                        (BaobabTree.stages[BaobabTree.stages.indexOf(stage) +
                                1]['minLevel']
                            as int));

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? (isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[100])
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(
                              color: isDark ? Colors.white : AppTheme.lightText,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        stage['emoji'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isUnlocked
                                ? null
                                : (isDark ? Colors.grey[600] : Colors.grey),
                          ),
                        ),
                        Text(
                          'Niveau $minLevel',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Icon(
                      Icons.check_circle,
                      color: isDark ? Colors.green[400] : Colors.green,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      size: 18,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
