import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Daily progress circle widget inspired by the provided designs
/// Shows percentage completion with circular progress indicator
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
              strokeWidth: 10,
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
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress >= 1.0
                    ? AppTheme.statusCompleted
                    : AppTheme.accentBlue,
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
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'Complété',
                style: GoogleFonts.inter(
                  fontSize: size * 0.1,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
