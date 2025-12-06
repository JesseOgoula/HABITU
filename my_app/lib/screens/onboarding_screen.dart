import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget nextScreen;

  const OnboardingScreen({super.key, required this.nextScreen});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Stop à\nl'individualisme.",
      description:
          "En Afrique, la discipline n'est pas une quête solitaire. L'optimisation de soi sans levier social mène toujours à l'abandon.",
      imagePath: 'assets/images/onboarding1_new.png',
    ),
    OnboardingPageData(
      title: "Le Pouvoir de l'Ubuntu\nau service de ta croissance.",
      description:
          "Nous fusionnons la discipline personnelle avec la force du collectif.",
      imagePath: 'assets/images/onboarding2_new.png',
    ),
    OnboardingPageData(
      title: "Crée ton Cercle\nde responsabilité.",
      description:
          "Arrête d'essayer seul. Sur HABITU, si tu t'arrêtes, tu brises le Cercle. La force du collectif est ta meilleure motivation pour réussir.",
      imagePath: 'assets/images/onboarding3_new.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final box = await Hive.openBox('settings');
    await box.put('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom section with indicators and buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.lightText
                              : AppTheme.lightText.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons row
                  Row(
                    mainAxisAlignment: isLastPage
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      // Passer button (hidden on last page)
                      if (!isLastPage)
                        TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Passer',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.lightTextSecondary,
                            ),
                          ),
                        ),

                      // Suivant / Commencer button
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightText,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lightText.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            isLastPage ? 'Commencer' : 'Suivant',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Spacer for alignment on non-last pages
                      if (!isLastPage) const SizedBox(width: 60),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(),

          // Illustration
          Container(
            height: 280,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(page.imagePath, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.lightText,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
