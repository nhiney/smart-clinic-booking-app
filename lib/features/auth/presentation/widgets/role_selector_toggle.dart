import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import 'auth_localizations.dart';

class RoleSelectorToggle extends StatelessWidget {
  const RoleSelectorToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => 
          previous.isDoctor != current.isDoctor || 
          previous.isEnglish != current.isEnglish,
      builder: (context, state) {
        final l10n = AuthLocalizations(state.isEnglish);

        return Column(
          children: [
            Text(
              l10n.roleSelectionLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRoleTab(
                        context: context,
                        label: l10n.patientRole,
                        icon: Icons.person_outline,
                        isSelected: !state.isDoctor,
                        onTap: () {
                          if (state.isDoctor) context.read<SignUpBloc>().add(ToggleRoleEvent());
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildRoleTab(
                        context: context,
                        label: l10n.doctorRole,
                        icon: Icons.medical_services_outlined,
                        isSelected: state.isDoctor,
                        onTap: () {
                          if (!state.isDoctor) context.read<SignUpBloc>().add(ToggleRoleEvent());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
