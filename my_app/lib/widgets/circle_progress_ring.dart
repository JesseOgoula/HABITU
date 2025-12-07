import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Circle progress ring - minimalist style
class CircleProgressRing extends StatelessWidget {
  final double progress;
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
                strokeWidth: 6,
              ),
            ),
            // Progress ring
            CustomPaint(
              size: Size(size, size),
              painter: _CircleRingPainter(
                progress: progress,
                color: isDark ? Colors.white : AppTheme.lightText,
                strokeWidth: 6,
              ),
            ),
            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (centerEmoji != null)
                  Text(centerEmoji!, style: TextStyle(fontSize: size * 0.22)),
                if (circleName != null) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: size * 0.7,
                    child: Text(
                      circleName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '$completedMembers/$totalMembers',
                  style: TextStyle(
                    fontSize: size * 0.09,
                    color: isDark
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
            // Complete badge
            if (isComplete)
              Positioned(
                bottom: 0,
                right: size * 0.18,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppTheme.lightText,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: isDark ? AppTheme.darkBackground : Colors.white,
                    size: 10,
                  ),
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

  _CircleRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
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

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
