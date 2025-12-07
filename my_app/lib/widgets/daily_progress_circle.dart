import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Daily progress circle widget - minimalist style
class DailyProgressCircle extends StatelessWidget {
  final int completed;
  final int total;
  final double size;

  const DailyProgressCircle({
    super.key,
    required this.completed,
    required this.total,
    this.size = 140,
  });

  double get _progress => total > 0 ? completed / total : 0;
  int get _percentage => (_progress * 100).round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white : AppTheme.lightText,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_percentage%',
                style: GoogleFonts.inter(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              Text(
                'Complété',
                style: GoogleFonts.inter(
                  fontSize: size * 0.09,
                  color: isDark
                      ? Colors.grey[400]
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
