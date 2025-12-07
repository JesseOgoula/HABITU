import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'auth/welcome_back_screen.dart';
import 'home_screen.dart';

/// Profile screen with user info and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final habitProvider = context.watch<HabitProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile card
            _buildProfileCard(context, isDark, authProvider),
            const SizedBox(height: 24),

            // Stats summary
            _buildStatsCard(isDark, habitProvider),
            const SizedBox(height: 24),

            // Settings section
            _buildSettingsSection(context, isDark),
            const SizedBox(height: 24),

            // Logout button
            _buildLogoutButton(context, isDark, authProvider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    bool isDark,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            backgroundImage: authProvider.avatarUrl != null
                ? NetworkImage(authProvider.avatarUrl!)
                : null,
            child: authProvider.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            authProvider.displayName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 4),

          // Email/ID
          Text(
            authProvider.user?.email ?? 'Utilisateur HABITU',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Member since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Membre depuis ${_getMemberSince()}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDark, HabitProvider habitProvider) {
    final habits = habitProvider.habits;
    final totalCompletions = habits.fold<int>(
      0,
      (sum, h) => sum + h.completedDates.length,
    );
    final currentStreak = _calculateStreak(habits);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ton Parcours',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  isDark,
                  '${habits.length}',
                  'Habitudes',
                  '📋',
                ),
              ),
              _buildDivider(isDark),
              Expanded(
                child: _buildStatItem(
                  isDark,
                  '$totalCompletions',
                  'Complétées',
                  '✅',
                ),
              ),
              _buildDivider(isDark),
              Expanded(
                child: _buildStatItem(isDark, '$currentStreak', 'Série', '🔥'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(bool isDark, String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            isDark,
            Icons.palette_outlined,
            'Apparence',
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return GestureDetector(
                  onTap: () => themeProvider.toggleTheme(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          size: 16,
                          color: isDark ? Colors.white : AppTheme.lightText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          themeProvider.isDarkMode ? 'Sombre' : 'Clair',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _divider(isDark),
          _buildSettingItem(
            context,
            isDark,
            Icons.notifications_outlined,
            'Notifications',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          _divider(isDark),
          _buildSettingItem(
            context,
            isDark,
            Icons.language_outlined,
            'Langue',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Français',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey[400]
                        : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
          _divider(isDark),
          _buildSettingItem(
            context,
            isDark,
            Icons.help_outline,
            'Aide & Support',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          _divider(isDark),
          _buildSettingItem(
            context,
            isDark,
            Icons.info_outline,
            'À propos',
            trailing: Text(
              'v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    bool isDark,
    AuthProvider authProvider,
  ) {
    return GestureDetector(
      onTap: () async {
        await authProvider.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => WelcomeBackScreen(nextScreen: const HomeScreen()),
            ),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20, color: Colors.red[400]),
            const SizedBox(width: 10),
            Text(
              'Déconnexion',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMemberSince() {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  int _calculateStreak(List habits) {
    if (habits.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final allCompleted = habits.every((h) => h.isCompletedOn(checkDate));
      if (allCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
