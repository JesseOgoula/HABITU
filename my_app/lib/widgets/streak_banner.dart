import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Streak banner inspired by the provided designs
/// Shows current streak with fire emoji and motivational message
class StreakBanner extends StatelessWidget {
  final int streak;
  final VoidCallback? onTap;

  const StreakBanner({super.key, required this.streak, this.onTap});

  String get _message {
    if (streak >= 30) return 'Tu es en feu ! Continue comme ça !';
    if (streak >= 14) return 'Excellente série ! Tu es Imara !';
    if (streak >= 7) return 'Belle semaine ! Continue !';
    if (streak >= 3) return 'Super début ! Ne lâche pas !';
    if (streak >= 1) return 'C\'est parti ! Garde le rythme !';
    return 'Commence ta série aujourd\'hui !';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: streak > 0
                ? [const Color(0xFF1E3A5F), const Color(0xFF2A4A6F)]
                : [
                    isDark ? Colors.grey[850]! : Colors.grey[100]!,
                    isDark ? Colors.grey[800]! : Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: streak > 0
              ? Border.all(color: AppTheme.accentBlue.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            // Fire emoji with streak count
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: streak > 0
                    ? AppTheme.accentBlue.withOpacity(0.2)
                    : (isDark ? Colors.grey[700] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    streak > 0 ? '🔥' : '💤',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: streak > 0
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                streak > 0 ? '$streak jours de série. $_message' : _message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: streak > 0
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            // Details button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: streak > 0
                    ? AppTheme.accentBlue
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Détails',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: streak > 0
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
