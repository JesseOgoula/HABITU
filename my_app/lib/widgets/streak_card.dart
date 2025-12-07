import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A card showing the user's streak (Imara status)
/// Imara means "Solid/Firm" in Swahili - represents consistency
class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final int todayCompleted;
  final int todayTotal;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.todayCompleted,
    required this.todayTotal,
  });

  String get _streakEmoji {
    if (currentStreak >= 30) return '🔥';
    if (currentStreak >= 14) return '⚡';
    if (currentStreak >= 7) return '✨';
    if (currentStreak >= 3) return '💪';
    return '🌱';
  }

  String get _imaraLevel {
    if (currentStreak >= 30) return 'Imara Suprême';
    if (currentStreak >= 14) return 'Imara Fort';
    if (currentStreak >= 7) return 'Imara';
    if (currentStreak >= 3) return 'En progression';
    return 'Débutant';
  }

  Color get _streakColor {
    if (currentStreak >= 30) return const Color(0xFFFF6B35);
    if (currentStreak >= 14) return const Color(0xFFFFD93D);
    if (currentStreak >= 7) return AppTheme.statusCompleted;
    return AppTheme.accentBlue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressPercent = todayTotal > 0 ? todayCompleted / todayTotal : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFF8F8F8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _streakColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: _streakColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Streak and Level
          Row(
            children: [
              // Streak circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _streakColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _streakColor, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_streakEmoji, style: const TextStyle(fontSize: 20)),
                      Text(
                        '$currentStreak',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _streakColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _imaraLevel,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStreak > 0
                          ? '$currentStreak jours consécutifs'
                          : 'Commence ta série !',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Best streak badge
              if (bestStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('🏆', style: const TextStyle(fontSize: 14)),
                      Text(
                        '$bestStreak',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar for today
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Aujourd\'hui', style: theme.textTheme.labelMedium),
                  Text(
                    '$todayCompleted/$todayTotal',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: progressPercent >= 1.0
                          ? AppTheme.statusCompleted
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressPercent >= 1.0
                        ? AppTheme.statusCompleted
                        : _streakColor,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
