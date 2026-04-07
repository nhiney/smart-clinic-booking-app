import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import '../widgets/role_selector_toggle.dart';
import '../widgets/patient_registration_form.dart';
import '../widgets/doctor_kyc_registration_form.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../../../core/theme/colors/app_colors.dart';
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
              backgroundColor: context.colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
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
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: BrandedAppBar(
            showLogo: true,
            leadingWidth: 120,
            leading: TextButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: context.colors.primary),
              label: Text(
                l10n.register_back,
                style: context.textStyles.bodyBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.l,
                vertical: context.spacing.m,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const ICareLogo(size: 60),
                        SizedBox(height: context.spacing.m),
                        Text(
                          l10n.register_title,
                          style: context.textStyles.heading2.copyWith(
                            color: context.colors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing.xl),

                  // Role Selector
                  const RoleSelectorToggle(),
                  SizedBox(height: context.spacing.xxl),

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
                  
                  SizedBox(height: context.spacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
