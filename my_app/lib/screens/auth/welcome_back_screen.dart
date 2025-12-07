import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

/// Welcome back screen shown to users who have logged out
/// Invites them to reconnect to the app
class WelcomeBackScreen extends StatelessWidget {
  final Widget nextScreen;

  const WelcomeBackScreen({super.key, required this.nextScreen});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final success = await authProvider.signInWithGoogle();

    if (success) {
      navigator.pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Welcome back illustration/icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.waving_hand,
                        size: 60,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Bon retour !',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.lightText,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Nous sommes ravis de vous revoir.\nReconnectez-vous pour continuer à suivre vos habitudes.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Error message
                  if (authProvider.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: authProvider.clearError,
                            child: Icon(
                              Icons.close,
                              color: Colors.red.shade700,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Google Sign-In Button
                  GestureDetector(
                    onTap: authProvider.isLoading
                        ? null
                        : () => _signInWithGoogle(context),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF7)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C5CE7,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: authProvider.isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://developers.google.com/identity/images/g-logo.png',
                                  height: 24,
                                  width: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.g_mobiledata,
                                      size: 24,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Se reconnecter avec Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats reminder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Color(0xFF00B894),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vos habitudes vous attendent',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.lightText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Continuez votre progression !',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
