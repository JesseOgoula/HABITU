import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A circular progress indicator showing collective completion of a Circle
/// The ring closes when all members complete their habits
/// A break in the ring shows who hasn't completed yet
class CircleProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int totalMembers;
  final int completedMembers;
  final double size;
  final String? centerEmoji;
  final String? circleName;
  final VoidCallback? onTap;

  const CircleProgressRing({
    super.key,
    required this.progress,
    required this.totalMembers,
    required this.completedMembers,
    this.size = 120,
    this.centerEmoji,
    this.circleName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            CustomPaint(
              size: Size(size, size),
              painter: _CircleRingPainter(
                progress: 1.0,
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                strokeWidth: 8,
              ),
            ),
            // Progress ring
            CustomPaint(
              size: Size(size, size),
              painter: _CircleRingPainter(
                progress: progress,
                color: isComplete
                    ? AppTheme.statusCompleted
                    : AppTheme.accentBlue,
                strokeWidth: 8,
                showBreak: !isComplete && progress > 0,
              ),
            ),
            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (centerEmoji != null)
                  Text(centerEmoji!, style: TextStyle(fontSize: size * 0.25)),
                if (circleName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    circleName!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '$completedMembers/$totalMembers',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isComplete ? AppTheme.statusCompleted : null,
                    fontWeight: isComplete ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            // Complete badge
            if (isComplete)
              Positioned(
                bottom: 0,
                right: size * 0.15,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.statusCompleted,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool showBreak;

  _CircleRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.showBreak = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees)
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw break indicator (red dash) if not complete
    if (showBreak && progress < 1.0) {
      final breakPaint = Paint()
        ..color = AppTheme.statusMissed
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final breakStart = startAngle + sweepAngle;
      final breakSweep = (2 * pi * 0.05); // Small gap

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        breakStart + 0.05,
        breakSweep,
        false,
        breakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
