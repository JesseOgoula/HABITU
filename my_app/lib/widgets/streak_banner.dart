import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Streak banner - minimalist style
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Fire emoji with streak count
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  streak > 0 ? '🔥' : '🌱',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak > 0 ? '$streak jours de série' : 'Nouvelle série',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey[400]
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
