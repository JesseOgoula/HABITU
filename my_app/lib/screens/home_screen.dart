import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/circle_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/week_selector.dart';
import '../widgets/swipeable_habit_card.dart';
import '../widgets/streak_banner.dart';
import '../widgets/daily_progress_circle.dart';
import '../widgets/circle_progress_ring.dart';
import '../theme/app_theme.dart';
import 'add_habit_screen.dart';
import 'auth/welcome_back_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkSurface
          : Colors.white,
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
                color: Colors.grey[600],
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
                  Navigator.pop(bottomSheetContext);
                  await authProvider.signOut();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          WelcomeBackScreen(nextScreen: const HomeScreen()),
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

  // Calculate current streak
  int _calculateStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));

    // Start from yesterday to check confirmed days
    for (int i = 0; i < 365; i++) {
      final allCompleted = habits.every((h) => h.isCompletedOn(checkDate));
      if (allCompleted && habits.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Check if today is complete too
    if (habits.every((h) => h.isCompletedOn(DateTime.now()))) {
      streak++;
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final circleProvider = context.watch<CircleProvider>();

    return Scaffold(
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            final currentStreak = _calculateStreak(habitProvider.habits);
            final myCircles = authProvider.user != null
                ? circleProvider.getMyCircles(authProvider.user!.id)
                : [];

            return CustomScrollView(
              slivers: [
                // Header with greeting
                SliverToBoxAdapter(
                  child: GreetingHeader(
                    userName: authProvider.displayName,
                    habitsCount: habitProvider.totalHabitsCount,
                    tasksCount: habitProvider.completedTodayCount,
                    meetingsCount: myCircles.length,
                    avatarUrl: authProvider.avatarUrl,
                    onAvatarTap: () => _showProfileMenu(context),
                  ),
                ),

                // Week selector
                SliverToBoxAdapter(
                  child: WeekSelector(
                    selectedDate: habitProvider.selectedDate,
                    onDateSelected: habitProvider.setSelectedDate,
                  ),
                ),

                // Streak Banner
                SliverToBoxAdapter(
                  child: StreakBanner(
                    streak: currentStreak,
                    onTap: () {
                      // TODO: Navigate to stats
                    },
                  ),
                ),

                // Progress and Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Daily progress circle
                        DailyProgressCircle(
                          completed: habitProvider.completedTodayCount,
                          total: habitProvider.totalHabitsCount,
                          size: 120,
                        ),
                        const SizedBox(width: 20),
                        // Stats cards
                        Expanded(
                          child: Column(
                            children: [
                              _buildStatCard(
                                context,
                                'Habitudes',
                                '${habitProvider.totalHabitsCount}',
                                Icons.repeat,
                                AppTheme.accentBlue,
                              ),
                              const SizedBox(height: 8),
                              _buildStatCard(
                                context,
                                'Complétées',
                                '${habitProvider.completedTodayCount}',
                                Icons.check_circle_outline,
                                AppTheme.statusCompleted,
                              ),
                              const SizedBox(height: 8),
                              _buildStatCard(
                                context,
                                'Série',
                                '$currentStreak jours',
                                Icons.local_fire_department,
                                const Color(0xFFFF6B35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Circles Section
                if (myCircles.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mes Cercles',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: myCircles.length,
                        itemBuilder: (context, index) {
                          final circle = myCircles[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: CircleProgressRing(
                              progress: 0.7,
                              totalMembers: circle.memberCount,
                              completedMembers: (circle.memberCount * 0.7)
                                  .round(),
                              centerEmoji: circle.emoji ?? '🌍',
                              circleName: circle.name,
                              size: 100,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Create circle invitation
                if (myCircles.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildCreateCircleCard(context, isDark),
                  ),

                // Section header for habits
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suivi des Habitudes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return GestureDetector(
                              onTap: () => themeProvider.toggleTheme(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Habits list
                if (habitProvider.habits.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(context))
                else ...[
                  // Anytime habits
                  if (habitProvider.anytimeHabits.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'À tout moment',
                      Icons.schedule,
                    ),
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
                      'Matin',
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
                      'Soir',
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
        backgroundColor: AppTheme.accentBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCircleCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.15),
            AppTheme.accentBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crée ton Cercle',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Invite tes amis et progressez ensemble',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
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
        return SwipeableHabitCard(
          habit: habit,
          isCompleted: provider.isHabitCompleted(habit),
          onComplete: () => provider.toggleHabitCompletion(habit),
          onLongPress: () => _showDeleteDialog(context, habit, provider),
        );
      }, childCount: habits.length),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Aucune habitude',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuie sur + pour créer ta première habitude',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Accueil', true),
              _buildNavItem(context, Icons.bar_chart, 'Statistiques', false),
              const SizedBox(width: 50),
              _buildNavItem(context, Icons.people_outline, 'Cercles', false),
              _buildNavItem(context, Icons.person_outline, 'Profil', false),
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
              ? AppTheme.accentBlue
              : theme.textTheme.bodyMedium?.color,
          size: 22,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? AppTheme.accentBlue
                : theme.textTheme.bodyMedium?.color,
          ),
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
        title: const Text('Supprimer l\'habitude'),
        content: Text('Voulez-vous vraiment supprimer "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
