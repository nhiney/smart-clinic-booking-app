import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import '../widgets/role_selector_toggle.dart';
import '../widgets/patient_registration_form.dart';
import '../widgets/doctor_kyc_registration_form.dart';
import '../widgets/auth_localizations.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.isSuccess) {
          if (state.isDoctor) {
            context.go('/kyc_upload'); 
          } else {
            context.go('/home');
          }
        }
      },
      builder: (context, state) {
        final l10n = AuthLocalizations(state.isEnglish);
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: BrandedAppBar(
            showLogo: true,
            leadingWidth: 120,
            leading: TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              label: const Text(
                "Quay lại",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: () => context.read<SignUpBloc>().add(ToggleLanguageEvent()),
                  icon: const Icon(
                    Icons.language,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    state.isEnglish ? "VN" : "EN",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          l10n.signUpTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Role Selector
                  const RoleSelectorToggle(),
                  const SizedBox(height: 40),

                  // Animated Switcher to toggle forms cleanly
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: state.isDoctor 
                        ? const DoctorKycRegistrationForm(key: ValueKey('DoctorForm'))
                        : const PatientRegistrationForm(key: ValueKey('PatientForm')),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
