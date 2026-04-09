import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../../../core/widgets/language_selector.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      (
        title: l10n.onboarding_title_1,
        desc: l10n.onboarding_desc_1,
        image: 'assets/images/doctor1.png',
      ),
      (
        title: l10n.onboarding_title_2,
        desc: l10n.onboarding_desc_2,
        image: 'assets/images/doctor2.png',
      ),
      (
        title: l10n.onboarding_title_3,
        desc: l10n.onboarding_desc_3,
        image: 'assets/images/doctor3.png',
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.m,
                vertical: context.spacing.s,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: context.radius.xlRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => LanguageSelector.show(context),
                      icon: Icon(Icons.language, color: context.colors.primary),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      l10n.skip,
                      style: context.textStyles.bodyBold.copyWith(
                        color: context.colors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ICare',
              style: context.textStyles.heading1.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontSize: 40,
              ),
            ),
            SizedBox(height: context.spacing.l),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            slide.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_hospital,
                              size: 150,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          style: context.textStyles.heading2.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.desc,
                          textAlign: TextAlign.center,
                          style: context.textStyles.body.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacing.l),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: context.radius.mRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: currentIndex == slides.length - 1
                        ? _goToLogin
                        : () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: context.radius.mRadius,
                      ),
                    ),
                    child: Text(
                      currentIndex == slides.length - 1 ? l10n.login_button : l10n.continue_button,
                      style: context.textStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacing.xl),
          ],
        ),
      ),
    );
  }
}
