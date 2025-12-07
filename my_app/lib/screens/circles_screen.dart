import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/circle.dart';
import '../providers/auth_provider.dart';
import '../providers/circle_provider.dart';
import '../widgets/circle_progress_ring.dart';
import '../theme/app_theme.dart';
import 'create_circle_screen.dart';
import 'circle_detail_screen.dart';

/// Main screen showing user's circles
class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final circleProvider = context.watch<CircleProvider>();

    final myCircles = authProvider.user != null
        ? circleProvider.getMyCircles(authProvider.user!.id)
        : <Circle>[];

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
          'Mes Cercles',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? Colors.white : AppTheme.lightText,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateCircleScreen()),
            ),
          ),
        ],
      ),
      body: myCircles.isEmpty
          ? _buildEmptyState(context, isDark)
          : _buildCirclesList(context, isDark, myCircles),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinDialog(context, isDark),
        backgroundColor: isDark ? Colors.white : AppTheme.lightText,
        foregroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        icon: const Icon(Icons.group_add),
        label: Text(
          'Rejoindre',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Aucun Cercle',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Les Cercles te permettent de progresser avec tes amis. Crée ou rejoins un Cercle pour commencer !',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  isDark,
                  'Créer',
                  Icons.add,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateCircleScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  isDark,
                  'Rejoindre',
                  Icons.group_add,
                  () => _showJoinDialog(context, isDark),
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? Colors.white : AppTheme.lightText)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? (isDark ? AppTheme.darkBackground : Colors.white)
                  : (isDark ? Colors.white : AppTheme.lightText),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? (isDark ? AppTheme.darkBackground : Colors.white)
                    : (isDark ? Colors.white : AppTheme.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirclesList(
    BuildContext context,
    bool isDark,
    List<Circle> circles,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: circles.length,
      itemBuilder: (context, index) {
        final circle = circles[index];
        return _buildCircleCard(context, isDark, circle);
      },
    );
  }

  Widget _buildCircleCard(BuildContext context, bool isDark, Circle circle) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CircleDetailScreen(circle: circle)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Progress ring
            CircleProgressRing(
              progress: 0.7, // TODO: Calculate real progress
              totalMembers: circle.memberCount,
              completedMembers: (circle.memberCount * 0.7).round(),
              centerEmoji: circle.emoji ?? '🌍',
              size: 70,
            ),
            const SizedBox(width: 16),
            // Circle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${circle.memberCount} membre${circle.memberCount > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[400]
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                  if (circle.description != null &&
                      circle.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      circle.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context, bool isDark) {
    final codeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rejoindre un Cercle',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre le code d\'invitation partagé par un membre du Cercle.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.inter(
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: GoogleFonts.inter(
                  fontSize: 20,
                  letterSpacing: 4,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final code = codeController.text.trim();
                  if (code.isEmpty) return;

                  final circleProvider = context.read<CircleProvider>();
                  final authProvider = context.read<AuthProvider>();

                  if (authProvider.user == null) return;

                  final success = await circleProvider.joinCircleByCode(
                    code,
                    authProvider.user!.id,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Tu as rejoint le Cercle !'
                              : 'Code invalide. Vérifie et réessaie.',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppTheme.lightText,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Rejoindre',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
