import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final int meetingsCount;
  final int tasksCount;
  final int habitsCount;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.meetingsCount = 0,
    this.tasksCount = 0,
    this.habitsCount = 0,
    this.avatarUrl,
    this.onAvatarTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String get _todayDate {
    final now = DateTime.now();
    return 'Today · ${DateFormat('EEE, MMM d').format(now)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_todayDate, style: theme.textTheme.bodyMedium),
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person,
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _greeting,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            userName,
            style: theme.textTheme.displayMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummary(context),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          const TextSpan(text: "What's ahead today: "),
          _buildBadge(
            '📅 $meetingsCount meeting${meetingsCount != 1 ? 's' : ''}',
            context,
          ),
          const TextSpan(text: ', '),
          _buildBadge(
            '⏱ $tasksCount task${tasksCount != 1 ? 's' : ''}',
            context,
          ),
          const TextSpan(text: ' and\n'),
          _buildBadge(
            '✓ $habitsCount habit${habitsCount != 1 ? 's' : ''}',
            context,
          ),
          const TextSpan(text: '. '),
          TextSpan(
            text: 'Clear after 10 pm.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  InlineSpan _buildBadge(String text, BuildContext context) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
