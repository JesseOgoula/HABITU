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
import 'habit_detail_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              backgroundImage: authProvider.avatarUrl != null
                  ? NetworkImage(authProvider.avatarUrl!)
                  : null,
              child: authProvider.avatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: isDark ? Colors.white : Colors.grey[600],
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              authProvider.displayName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Déconnexion',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
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

  int _calculateStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));

    for (int i = 0; i < 365; i++) {
      final allCompleted = habits.every((h) => h.isCompletedOn(checkDate));
      if (allCompleted && habits.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

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
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            final currentStreak = _calculateStreak(habitProvider.habits);
            final myCircles = authProvider.user != null
                ? circleProvider.getMyCircles(authProvider.user!.id)
                : [];

            return CustomScrollView(
              slivers: [
                // Header
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
                SliverToBoxAdapter(child: StreakBanner(streak: currentStreak)),

                // Progress and Stats Row
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        DailyProgressCircle(
                          completed: habitProvider.completedTodayCount,
                          total: habitProvider.totalHabitsCount,
                          size: 100,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatRow(
                                context,
                                'Habitudes',
                                '${habitProvider.totalHabitsCount}',
                              ),
                              const SizedBox(height: 10),
                              _buildStatRow(
                                context,
                                'Complétées',
                                '${habitProvider.completedTodayCount}',
                              ),
                              const SizedBox(height: 10),
                              _buildStatRow(
                                context,
                                'Série',
                                '$currentStreak jours',
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
                          Text(
                            'Voir tout',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
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
                              size: 90,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Create circle card
                if (myCircles.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildCreateCircleCard(context, isDark),
                  ),

                // Habits section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.lightText,
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
                  SliverFillRemaining(child: _buildEmptyState(context, isDark))
                else ...[
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

                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        backgroundColor: isDark ? Colors.white : AppTheme.lightText,
        foregroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateCircleCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
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
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
            ),
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
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
          ),
          child: SwipeableHabitCard(
            habit: habit,
            isCompleted: provider.isHabitCompleted(habit),
            onComplete: () => provider.toggleHabitCompletion(habit),
            onLongPress: () => _showDeleteDialog(context, habit, provider),
          ),
        );
      }, childCount: habits.length),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
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
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Accueil', true, isDark, null),
              _buildNavItem(
                context,
                Icons.bar_chart_rounded,
                'Stats',
                false,
                isDark,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                ),
              ),
              const SizedBox(width: 50),
              _buildNavItem(
                context,
                Icons.people_outline,
                'Cercles',
                false,
                isDark,
                null, // TODO: CirclesScreen
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                'Profil',
                false,
                isDark,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
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
    bool isDark,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? (isDark ? Colors.white : AppTheme.lightText)
                : (isDark ? Colors.grey[600] : Colors.grey[400]),
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive
                  ? (isDark ? Colors.white : AppTheme.lightText)
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Habit habit,
    HabitProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer l\'habitude',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text('Voulez-vous vraiment supprimer "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
