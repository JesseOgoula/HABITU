import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Baobab tree visualization that grows with habit completion
/// The tree has different stages based on user's progress
class BaobabTree extends StatelessWidget {
  final int level; // 1-10 representing tree growth
  final int totalCompletions;
  final double size;
  final bool showLabels;

  const BaobabTree({
    super.key,
    required this.level,
    required this.totalCompletions,
    this.size = 300,
    this.showLabels = true,
  });

  // Tree growth stages
  static const stages = [
    {'name': 'Graine', 'emoji': '🌱', 'minLevel': 1},
    {'name': 'Pousse', 'emoji': '🌿', 'minLevel': 2},
    {'name': 'Jeune Arbre', 'emoji': '🌳', 'minLevel': 3},
    {'name': 'Arbre', 'emoji': '🌲', 'minLevel': 5},
    {'name': 'Grand Arbre', 'emoji': '🌴', 'minLevel': 7},
    {'name': 'Baobab', 'emoji': '🏛️', 'minLevel': 10},
  ];

  Map<String, dynamic> get _currentStage {
    for (int i = stages.length - 1; i >= 0; i--) {
      if (level >= (stages[i]['minLevel'] as int)) {
        return stages[i];
      }
    }
    return stages[0];
  }

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
          // Background circle (ground)
          Positioned(
            bottom: size * 0.1,
            child: Container(
              width: size * 0.7,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D4A2D).withOpacity(0.3)
                    : const Color(0xFF8B7355).withOpacity(0.2),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Tree visualization
          CustomPaint(
            size: Size(size, size),
            painter: _BaobabPainter(level: level, isDark: isDark),
          ),
          // Leaves/fruits based on level
          ..._buildLeaves(isDark),
          // Stage emoji
          if (showLabels)
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  Text(
                    _currentStage['emoji'] as String,
                    style: TextStyle(fontSize: size * 0.12),
                  ),
                  Text(
                    _currentStage['name'] as String,
                    style: TextStyle(
                      fontSize: size * 0.04,
                      fontWeight: FontWeight.w600,
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

  List<Widget> _buildLeaves(bool isDark) {
    if (level < 3) return [];

    final leafCount = min(level * 3, 20);
    final random = Random(42); // Fixed seed for consistent positions

    return List.generate(leafCount, (index) {
      final angle = (index / leafCount) * 2 * pi;
      final radius = size * 0.25 + random.nextDouble() * size * 0.1;
      final x = size / 2 + cos(angle) * radius;
      final y = size * 0.35 + sin(angle) * radius * 0.5;

      return Positioned(
        left: x - 8,
        top: y - 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getLeafColor(index, isDark),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  Color _getLeafColor(int index, bool isDark) {
    final colors = isDark
        ? [
            const Color(0xFF4A7C59),
            const Color(0xFF6B9B7A),
            const Color(0xFF8BC49A),
          ]
        : [
            const Color(0xFF2E7D32),
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ];
    return colors[index % colors.length];
  }
}

class _BaobabPainter extends CustomPainter {
  final int level;
  final bool isDark;

  _BaobabPainter({required this.level, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = isDark ? const Color(0xFF5D4E37) : const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    final branchPaint = Paint()
      ..color = isDark ? const Color(0xFF4A3F2F) : const Color(0xFF6B5344)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2, level.toDouble());

    // Trunk height based on level
    final trunkHeight = size.height * (0.2 + level * 0.04);
    final trunkWidth = size.width * (0.08 + level * 0.015);
    final centerX = size.width / 2;
    final bottomY = size.height * 0.75;

    // Draw trunk
    final trunkPath = Path()
      ..moveTo(centerX - trunkWidth / 2, bottomY)
      ..lineTo(centerX - trunkWidth / 3, bottomY - trunkHeight)
      ..quadraticBezierTo(
        centerX,
        bottomY - trunkHeight - 10,
        centerX + trunkWidth / 3,
        bottomY - trunkHeight,
      )
      ..lineTo(centerX + trunkWidth / 2, bottomY)
      ..close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Draw branches if level >= 3
    if (level >= 3) {
      final branchCount = min(level, 6);
      for (int i = 0; i < branchCount; i++) {
        final angle = -pi / 2 + (i - branchCount / 2) * 0.4;
        final branchLength = size.height * 0.15 * (1 + level * 0.05);

        final startX = centerX + (i - branchCount / 2) * 5;
        final startY = bottomY - trunkHeight + 10;
        final endX = startX + cos(angle) * branchLength;
        final endY = startY + sin(angle) * branchLength;

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          branchPaint,
        );
      }
    }

    // Draw roots if level >= 5
    if (level >= 5) {
      final rootPaint = Paint()
        ..color = isDark ? const Color(0xFF4A3F2F) : const Color(0xFF6B5344)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 3; i++) {
        final angle = pi / 2 + (i - 1) * 0.3;
        final rootLength = size.height * 0.08;

        canvas.drawLine(
          Offset(centerX + (i - 1) * 5, bottomY),
          Offset(
            centerX + cos(angle) * rootLength + (i - 1) * 10,
            bottomY + sin(angle) * rootLength,
          ),
          rootPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BaobabPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.isDark != isDark;
  }
}
