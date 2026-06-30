import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipOrGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);

    if (!mounted) return;

    final hasSeenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false;
    if (!hasSeenDisclaimer) {
      context.go('/disclaimer');
    } else {
      context.go('/home');
    }
  }

  Widget _dots(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 24 : 8,
          height: isActive ? 8 : 8,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.secondary : Colors.grey,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: _skipOrGetStarted,
                child: const Text('Skip'),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 16),
                _dots(theme.colorScheme),
                const SizedBox(height: 24),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _OnboardSlide(
                        icon: Icons.local_library,
                        title: '441 Clinical Articles',
                        description:
                            'Full references for every rotation — offline, always.',
                      ),
                      _OnboardSlide(
                        icon: Icons.flag,
                        title: 'Built for Ethiopian Medicine',
                        description:
                            'MoH protocols. EFDA drugs. Ethiopian clinical context.',
                      ),
                      _OnboardSlide(
                        icon: Icons.quiz,
                        title: 'EHPLE Exam Practice',
                        description:
                            '2,000+ MCQs with spaced repetition. Know what you know.',
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _skipOrGetStarted();
                        }
                      },
                      child: Text(
                        _currentPage < 2 ? 'Next' : 'Get Started',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: theme.colorScheme.secondary),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
