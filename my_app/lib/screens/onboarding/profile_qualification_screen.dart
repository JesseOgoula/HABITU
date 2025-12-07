import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/qualification_service.dart';
import '../../theme/app_theme.dart';
import 'ai_recommendations_screen.dart';

/// Profile qualification screen - Collects user data for AI recommendations
class ProfileQualificationScreen extends StatefulWidget {
  final Widget nextScreen;

  const ProfileQualificationScreen({super.key, required this.nextScreen});

  @override
  State<ProfileQualificationScreen> createState() =>
      _ProfileQualificationScreenState();
}

class _ProfileQualificationScreenState
    extends State<ProfileQualificationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Country codes for Africa
  static const List<Map<String, String>> countryCodes = [
    {'code': '+221', 'country': '🇸🇳 Sénégal', 'flag': '🇸🇳'},
    {'code': '+234', 'country': '🇳🇬 Nigeria', 'flag': '🇳🇬'},
    {'code': '+254', 'country': '🇰🇪 Kenya', 'flag': '🇰🇪'},
    {'code': '+241', 'country': '🇬🇦 Gabon', 'flag': '🇬🇦'},
    {'code': '+225', 'country': '🇨🇮 Côte d\'Ivoire', 'flag': '🇨🇮'},
    {'code': '+237', 'country': '🇨🇲 Cameroun', 'flag': '🇨🇲'},
    {'code': '+212', 'country': '🇲🇦 Maroc', 'flag': '🇲🇦'},
    {'code': '+213', 'country': '🇩🇿 Algérie', 'flag': '🇩🇿'},
    {'code': '+216', 'country': '🇹🇳 Tunisie', 'flag': '🇹🇳'},
    {'code': '+20', 'country': '🇪🇬 Égypte', 'flag': '🇪🇬'},
    {'code': '+233', 'country': '🇬🇭 Ghana', 'flag': '🇬🇭'},
    {'code': '+27', 'country': '🇿🇦 Afrique du Sud', 'flag': '🇿🇦'},
    {'code': '+255', 'country': '🇹🇿 Tanzanie', 'flag': '🇹🇿'},
    {'code': '+256', 'country': '🇺🇬 Ouganda', 'flag': '🇺🇬'},
    {'code': '+250', 'country': '🇷🇼 Rwanda', 'flag': '🇷🇼'},
    {'code': '+243', 'country': '🇨🇩 RD Congo', 'flag': '🇨🇩'},
    {'code': '+242', 'country': '🇨🇬 Congo', 'flag': '🇨🇬'},
    {'code': '+226', 'country': '🇧🇫 Burkina Faso', 'flag': '🇧🇫'},
    {'code': '+223', 'country': '🇲🇱 Mali', 'flag': '🇲🇱'},
    {'code': '+227', 'country': '🇳🇪 Niger', 'flag': '🇳🇪'},
    {'code': '+229', 'country': '🇧🇯 Bénin', 'flag': '🇧🇯'},
    {'code': '+228', 'country': '🇹🇬 Togo', 'flag': '🇹🇬'},
    {'code': '+244', 'country': '🇦🇴 Angola', 'flag': '🇦🇴'},
    {'code': '+258', 'country': '🇲🇿 Mozambique', 'flag': '🇲🇿'},
    {'code': '+251', 'country': '🇪🇹 Éthiopie', 'flag': '🇪🇹'},
  ];

  // African cities (capitals and economic capitals)
  static const List<String> africanCities = [
    'Dakar, Sénégal',
    'Abidjan, Côte d\'Ivoire',
    'Lagos, Nigeria',
    'Abuja, Nigeria',
    'Nairobi, Kenya',
    'Mombasa, Kenya',
    'Libreville, Gabon',
    'Port-Gentil, Gabon',
    'Yaoundé, Cameroun',
    'Douala, Cameroun',
    'Casablanca, Maroc',
    'Rabat, Maroc',
    'Alger, Algérie',
    'Oran, Algérie',
    'Tunis, Tunisie',
    'Le Caire, Égypte',
    'Alexandrie, Égypte',
    'Accra, Ghana',
    'Johannesburg, Afrique du Sud',
    'Le Cap, Afrique du Sud',
    'Pretoria, Afrique du Sud',
    'Dar es Salaam, Tanzanie',
    'Kampala, Ouganda',
    'Kigali, Rwanda',
    'Kinshasa, RD Congo',
    'Lubumbashi, RD Congo',
    'Brazzaville, Congo',
    'Pointe-Noire, Congo',
    'Ouagadougou, Burkina Faso',
    'Bamako, Mali',
    'Niamey, Niger',
    'Cotonou, Bénin',
    'Lomé, Togo',
    'Luanda, Angola',
    'Maputo, Mozambique',
    'Addis-Abeba, Éthiopie',
    'Conakry, Guinée',
    'Antananarivo, Madagascar',
    'Nouakchott, Mauritanie',
  ];

  // Form data
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+241'; // Default Gabon
  String? _selectedCity;
  String _selectedGender = '';
  String _selectedObjective = '';
  String _selectedFriction = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitQualification();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedPage1() {
    return _selectedGender.isNotEmpty;
  }

  bool _canProceedPage2() {
    return _selectedObjective.isNotEmpty && _selectedFriction.isNotEmpty;
  }

  String get _fullPhoneNumber {
    if (_phoneController.text.isEmpty) return '';
    return '$_selectedCountryCode${_phoneController.text}';
  }

  Future<void> _submitQualification() async {
    if (!_canProceedPage2()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
        );
        return;
      }

      final qualificationData = QualificationData(
        phoneNumber: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : null,
        city: _selectedCity,
        gender: _selectedGender,
        urgentObjective: _selectedObjective,
        mainFriction: _selectedFriction,
      );

      // Navigate to AI recommendations screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AIRecommendationsScreen(
                qualificationData: qualificationData,
                nextScreen: widget.nextScreen,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Sélectionner un pays',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: countryCodes.length,
                itemBuilder: (context, index) {
                  final country = countryCodes[index];
                  final isSelected = _selectedCountryCode == country['code'];
                  return ListTile(
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country['country']!.replaceFirst(
                        country['flag']! + ' ',
                        '',
                      ),
                      style: GoogleFonts.inter(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppTheme.lightText,
                      ),
                    ),
                    trailing: Text(
                      country['code']!,
                      style: GoogleFonts.inter(
                        color: AppTheme.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(
                      0xFF12172A,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      setState(() => _selectedCountryCode = country['code']!);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Sélectionner une ville',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: africanCities.length,
                itemBuilder: (context, index) {
                  final city = africanCities[index];
                  final isSelected = _selectedCity == city;
                  return ListTile(
                    leading: const Icon(
                      Icons.location_city,
                      color: Color(0xFF12172A),
                    ),
                    title: Text(
                      city,
                      style: GoogleFonts.inter(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppTheme.lightText,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(
                      0xFF12172A,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      setState(() => _selectedCity = city);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.lightText),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          'Personnalisation',
          style: GoogleFonts.inter(
            color: AppTheme.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildProgressDot(0),
                  Expanded(child: _buildProgressLine(0)),
                  _buildProgressDot(1),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [_buildPage1(), _buildPage2()],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentPage == 0
                            ? (_canProceedPage1() ? _nextPage : null)
                            : (_canProceedPage2() ? _nextPage : null)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _currentPage == 1
                              ? 'Voir mes recommandations'
                              : 'Continuer',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildProgressDot(int index) {
    final isActive = _currentPage >= index;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF12172A) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildProgressLine(int index) {
    final isComplete = _currentPage > index;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isComplete ? const Color(0xFF12172A) : Colors.grey.shade300,
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parle-nous de toi',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces informations nous aident à personnaliser ton expérience.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Phone number with country code dropdown
          Text(
            'Numéro de téléphone (optionnel)',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Country code dropdown
              GestureDetector(
                onTap: _showCountryCodePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        countryCodes.firstWhere(
                          (c) => c['code'] == _selectedCountryCode,
                          orElse: () => countryCodes.first,
                        )['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountryCode,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: '66 123 45 67',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pour recevoir des rappels WhatsApp de ton Cercle',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // City dropdown
          Text(
            'Ville de résidence (optionnel)',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showCityPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCity ?? 'Sélectionner une ville',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: _selectedCity != null
                            ? AppTheme.lightText
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Gender (required)
          Text(
            'Genre *',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...QualificationService.genderOptions.map((option) {
            final isSelected = _selectedGender == option['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = option['id']!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF12172A).withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF12172A)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFF12172A)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        option['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: AppTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tes objectifs',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notre IA va te créer des habitudes personnalisées.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Urgent objective
          Text(
            'Quel est ton objectif le plus urgent ? *',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...QualificationService.objectiveOptions.map((option) {
            final isSelected = _selectedObjective == option['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedObjective = option['id']!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF12172A).withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF12172A)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppTheme.lightText,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF12172A),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Main friction
          Text(
            'Qu\'est-ce qui te freine le plus ? *',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...QualificationService.frictionOptions.map((option) {
            final isSelected = _selectedFriction == option['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFriction = option['id']!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF12172A).withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF12172A)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppTheme.lightText,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF12172A),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
