import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'otp_verification_screen.dart';

/// Main authentication screen with Google Sign-In and Phone options
class AuthScreen extends StatefulWidget {
  final Widget nextScreen;

  const AuthScreen({super.key, required this.nextScreen});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+225'; // Côte d'Ivoire par défaut

  final List<Map<String, String>> _countryCodes = [
    {'code': '+225', 'country': '🇨🇮 Côte d\'Ivoire'},
    {'code': '+33', 'country': '🇫🇷 France'},
    {'code': '+1', 'country': '🇺🇸 USA'},
    {'code': '+44', 'country': '🇬🇧 UK'},
    {'code': '+237', 'country': '🇨🇲 Cameroun'},
    {'code': '+221', 'country': '🇸🇳 Sénégal'},
    {'code': '+223', 'country': '🇲🇱 Mali'},
    {'code': '+226', 'country': '🇧🇫 Burkina Faso'},
    {'code': '+228', 'country': '🇹🇬 Togo'},
    {'code': '+229', 'country': '🇧🇯 Bénin'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      _navigateToNextScreen();
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendOtp(phoneNumber);

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phoneNumber,
            nextScreen: widget.nextScreen,
          ),
        ),
      );
    }
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/icons/logohabitu.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Bienvenue sur\nHABITU',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.lightText,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Connectez-vous pour synchroniser vos habitudes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.lightTextSecondary,
                      ),
                    ),

                    const SizedBox(height: 48),

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
                    _buildGoogleButton(authProvider.isLoading),

                    const SizedBox(height: 24),

                    // Divider with "ou"
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.lightTextSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ou',
                            style: GoogleFonts.inter(
                              color: AppTheme.lightTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.lightTextSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Phone number section
                    Text(
                      'Connexion par téléphone',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Country code + Phone input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              items: _countryCodes.map((country) {
                                return DropdownMenuItem(
                                  value: country['code'],
                                  child: Text(
                                    country['code']!,
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCountryCode = value);
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Phone number input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Numéro de téléphone',
                              hintStyle: GoogleFonts.inter(
                                color: AppTheme.lightTextSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.lightText,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Entrez votre numéro';
                              }
                              if (value.trim().length < 8) {
                                return 'Numéro trop court';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Send OTP Button
                    _buildPhoneButton(authProvider.isLoading),

                    const SizedBox(height: 48),

                    // Terms and conditions
                    Text(
                      'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.lightTextSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _signInWithGoogle,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://developers.google.com/identity/images/g-logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Continuer avec Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _sendOtp,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey : AppTheme.lightText,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightText.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sms_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Envoyer le code',
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
    );
  }
}
