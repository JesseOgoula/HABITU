import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/circle.dart';
import '../providers/auth_provider.dart';
import '../providers/circle_provider.dart';
import '../widgets/circle_progress_ring.dart';
import '../theme/app_theme.dart';

/// Detail screen for a single Circle
class CircleDetailScreen extends StatelessWidget {
  final Circle circle;

  const CircleDetailScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final isCreator = authProvider.user?.id == circle.creatorId;

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
          circle.name,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
        actions: [
          if (isCreator)
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: isDark ? Colors.white : AppTheme.lightText,
              ),
              onPressed: () {
                // TODO: Circle settings
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle header with progress
            _buildHeader(context, isDark),
            const SizedBox(height: 24),

            // Invite code card
            _buildInviteCard(context, isDark),
            const SizedBox(height: 24),

            // Members section
            _buildMembersSection(context, isDark),
            const SizedBox(height: 24),

            // Actions
            if (!isCreator) _buildLeaveButton(context, isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sendWhatsAppNudge(context),
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        icon: const Icon(Icons.message, color: Colors.white),
        label: Text(
          'Nudge',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
          CircleProgressRing(
            progress: 0.7, // TODO: Calculate real progress
            totalMembers: circle.memberCount,
            completedMembers: (circle.memberCount * 0.7).round(),
            centerEmoji: circle.emoji ?? '🌍',
            size: 120,
          ),
          const SizedBox(height: 20),
          Text(
            circle.name,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          if (circle.description != null && circle.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              circle.description!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatBadge(isDark, '${circle.memberCount}', 'Membres'),
              const SizedBox(width: 24),
              _buildStatBadge(isDark, '70%', 'Aujourd\'hui'), // TODO: Real calc
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(bool isDark, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
        ),
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

  Widget _buildInviteCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                Icons.link,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Code d\'invitation',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.grey[400]
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    circle.inviteCode,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: circle.inviteCode));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Code copié !')));
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.copy,
                    size: 22,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _shareInvite(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppTheme.lightText,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.share,
                    size: 22,
                    color: isDark ? AppTheme.darkBackground : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, bool isDark) {
    // Simulated members for now
    final members = [
      {'name': 'Toi', 'isCreator': true, 'completed': true},
      ...List.generate(
        circle.memberCount - 1,
        (i) => {
          'name': 'Membre ${i + 1}',
          'isCreator': false,
          'completed': i % 2 == 0,
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Membres',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${circle.memberCount} membre${circle.memberCount > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? Colors.grey[400]
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...members.map(
            (member) => _buildMemberItem(
              context,
              isDark,
              member['name'] as String,
              member['isCreator'] as bool,
              member['completed'] as bool,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    bool isDark,
    String name,
    bool isCreator,
    bool completed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Créateur',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  completed
                      ? 'A complété aujourd\'hui ✓'
                      : 'N\'a pas encore validé',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: completed
                        ? (isDark ? Colors.green[400] : Colors.green[600])
                        : (isDark ? Colors.grey[500] : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            Icon(
              Icons.radio_button_unchecked,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showLeaveDialog(context, isDark),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Quitter le Cercle',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red[400],
          ),
        ),
      ),
    );
  }

  void _shareInvite(BuildContext context) {
    final message =
        'Rejoins mon Cercle "${circle.name}" sur HABITU ! '
        'Utilise le code: ${circle.inviteCode}';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message d\'invitation copié !')),
    );
  }

  void _sendWhatsAppNudge(BuildContext context) async {
    final message = Uri.encodeComponent(
      '🔔 Rappel du Cercle "${circle.name}" !\n\n'
      'N\'oublie pas de valider tes habitudes aujourd\'hui. '
      'Le Cercle compte sur toi ! 💪\n\n'
      '- Envoyé depuis HABITU',
    );

    final url = 'https://wa.me/?text=$message';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    }
  }

  void _showLeaveDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quitter le Cercle',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Es-tu sûr de vouloir quitter "${circle.name}" ? '
          'Tu ne pourras plus voir la progression du groupe.',
        ),
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
            onPressed: () async {
              final circleProvider = context.read<CircleProvider>();
              final authProvider = context.read<AuthProvider>();

              if (authProvider.user != null) {
                await circleProvider.leaveCircle(
                  circle.id,
                  authProvider.user!.id,
                );
              }

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to circles list
              }
            },
            child: Text('Quitter', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
