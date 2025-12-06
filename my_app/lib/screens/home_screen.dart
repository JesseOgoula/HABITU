import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/week_selector.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // User info
            CircleAvatar(
              radius: 40,
              backgroundImage: authProvider.avatarUrl != null
                  ? NetworkImage(authProvider.avatarUrl!)
                  : null,
              child: authProvider.avatarUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              authProvider.displayName,
              style: Theme.of(bottomSheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(bottomSheetContext); // Close bottom sheet first
                  await authProvider.signOut();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          AuthScreen(nextScreen: const HomeScreen()),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            return CustomScrollView(
              slivers: [
                // Header with greeting
                SliverToBoxAdapter(
                  child: GreetingHeader(
                    userName: authProvider.displayName,
                    habitsCount: habitProvider.totalHabitsCount,
                    tasksCount: 0,
                    meetingsCount: 0,
                    avatarUrl: authProvider.avatarUrl,
                    onAvatarTap: () => _showProfileMenu(context),
                  ),
                ),

                // Tabs (All / Habits)
                SliverToBoxAdapter(child: _buildTabBar(context, isDark)),

                // Week selector
                SliverToBoxAdapter(
                  child: WeekSelector(
                    selectedDate: habitProvider.selectedDate,
                    onDateSelected: habitProvider.setSelectedDate,
                  ),
                ),

                // Habits list
                if (habitProvider.habits.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(context))
                else ...[
                  // Anytime habits
                  if (habitProvider.anytimeHabits.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Anytime', Icons.schedule),
                    _buildHabitsList(
                      context,
                      habitProvider.anytimeHabits,
                      habitProvider,
                    ),
                  ],

                  // Morning habits
                  if (habitProvider.morningHabits.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'Morning',
                      Icons.wb_sunny_outlined,
                    ),
                    _buildHabitsList(
                      context,
                      habitProvider.morningHabits,
                      habitProvider,
                    ),
                  ],

                  // Evening habits
                  if (habitProvider.eveningHabits.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'Evening',
                      Icons.nightlight_outlined,
                    ),
                    _buildHabitsList(
                      context,
                      habitProvider.eveningHabits,
                      habitProvider,
                    ),
                  ],
                ],

                // Bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text('All', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 8),
                const Text('🏃💪📖'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text('Habits', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 4),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return GestureDetector(
                      onTap: () => themeProvider.toggleTheme(),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        size: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  SliverList _buildHabitsList(
    BuildContext context,
    List<Habit> habits,
    HabitProvider provider,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final habit = habits[index];
        return HabitCard(
          habit: habit,
          isCompleted: provider.isHabitCompleted(habit),
          onTap: () => provider.toggleHabitCompletion(habit),
          onLongPress: () => _showDeleteDialog(context, habit, provider),
        );
      }, childCount: habits.length),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 64,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text('No habits yet', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first habit',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.calendar_today, 'Today', true),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(
                context,
                Icons.check_circle_outline,
                'Completion',
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? theme.textTheme.bodyLarge?.color
              : theme.textTheme.bodyMedium?.color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: isActive
              ? theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                )
              : theme.textTheme.labelMedium,
        ),
      ],
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Habit habit,
    HabitProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
