import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// A habit card that can be swiped to complete
/// Optimized for one-hand mobile usage (SF-02.1)
class SwipeableHabitCard extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback? onLongPress;

  const SwipeableHabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onComplete,
    this.onLongPress,
  });

  @override
  State<SwipeableHabitCard> createState() => _SwipeableHabitCardState();
}

class _SwipeableHabitCardState extends State<SwipeableHabitCard> {
  double _dragExtent = 0;

  // Threshold for completion (40% of card width)
  static const double _completionThreshold = 0.4;

  IconData get _categoryIcon {
    switch (widget.habit.category) {
      case HabitCategory.morning:
        return Icons.wb_sunny_outlined;
      case HabitCategory.evening:
        return Icons.nightlight_outlined;
      case HabitCategory.anytime:
        return Icons.schedule;
    }
  }

  String get _categoryLabel {
    switch (widget.habit.category) {
      case HabitCategory.morning:
        return 'Matin';
      case HabitCategory.evening:
        return 'Soir';
      case HabitCategory.anytime:
        return 'Anytime';
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.isCompleted) return;

    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.isCompleted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * _completionThreshold;

    if (_dragExtent >= threshold) {
      // Complete the habit
      HapticFeedback.mediumImpact();
      widget.onComplete();
    }

    // Animate back to original position
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate swipe progress (0.0 to 1.0)
    final swipeProgress = (_dragExtent / (screenWidth * _completionThreshold))
        .clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          // Background reveal (green completion indicator)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Color.lerp(
                  AppTheme.statusCompleted.withOpacity(0.3),
                  AppTheme.statusCompleted,
                  swipeProgress,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: swipeProgress > 0.2 ? 1.0 : 0.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28 + (8 * swipeProgress),
                        ),
                        if (swipeProgress > 0.6) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Validé !',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Card content (slides right on drag)
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: _buildCardContent(context, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? (widget.isCompleted ? Colors.grey[900] : AppTheme.darkCard)
            : (widget.isCompleted ? Colors.grey[100] : AppTheme.lightCard),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.habit.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _categoryIcon,
                      size: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(_categoryLabel, style: theme.textTheme.labelMedium),
                    if (!widget.isCompleted) ...[
                      const Spacer(),
                      Icon(
                        Icons.swipe_right_alt,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.habit.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: widget.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (widget.habit.targetMinutes > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${widget.habit.targetMinutes} minutes',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          // Status indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? AppTheme.statusCompleted
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isCompleted
                    ? AppTheme.statusCompleted
                    : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                width: 2,
              ),
            ),
            child: widget.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        ],
      ),
    );
  }
}
