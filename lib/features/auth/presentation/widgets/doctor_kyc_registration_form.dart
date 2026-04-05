import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import 'auth_localizations.dart';
import 'terms_and_conditions_checkbox.dart';

class DoctorKycRegistrationForm extends StatefulWidget {
  const DoctorKycRegistrationForm({super.key});

  @override
  State<DoctorKycRegistrationForm> createState() => _DoctorKycRegistrationFormState();
}

class _DoctorKycRegistrationFormState extends State<DoctorKycRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedHospital;
  bool _termsAccepted = false;

  final List<String> _hospitals = [
    'General City Hospital',
    'Mercy Clinic Center',
    'Sunrise Healthcare Partners',
    'Hoan My International'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedHospital == null) {
        final state = context.read<SignUpBloc>().state;
        final l10n = AuthLocalizations(state.isEnglish);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.requiredField)),
        );
        return;
      }
      
      if (!_termsAccepted) {
        final state = context.read<SignUpBloc>().state;
        final l10n = AuthLocalizations(state.isEnglish);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mustAcceptTerms)),
        );
        return;
      }

      context.read<SignUpBloc>().add(
        SubmitDoctorRegistration(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          targetHospitalId: _selectedHospital!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        final l10n = AuthLocalizations(state.isEnglish);
        final theme = Theme.of(context);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Info
              _buildLabel(l10n.fullNameLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  hintText: l10n.fullNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 20),

              _buildLabel(l10n.emailLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                enabled: !state.isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (v) => (v!.isEmpty || !v.contains('@')) ? l10n.invalidEmail : null,
              ),
              const SizedBox(height: 20),

              _buildLabel(l10n.passwordLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                enabled: !state.isLoading,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v!.length < 6 ? l10n.passwordShort : null,
              ),
              const SizedBox(height: 24),

              // B2B KYC Fields
              _buildLabel(l10n.hospitalLabel),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedHospital,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                items: _hospitals.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: state.isLoading ? null : (val) => setState(() => _selectedHospital = val),
                 validator: (v) => v == null ? l10n.requiredField : null,
              ),
              const SizedBox(height: 24),

              // Certification Uploads (Mock buttons)
              _buildKycUploadButton(l10n.idUploadLabel, Icons.badge_outlined, state.isLoading),
              const SizedBox(height: 12),
              _buildKycUploadButton(l10n.degreeUploadLabel, Icons.school_outlined, state.isLoading),
              const SizedBox(height: 24),

              // Terms & Conditions
              TermsAndConditionsCheckbox(
                value: _termsAccepted,
                onChanged: (val) => setState(() => _termsAccepted = val ?? false),
              ),
              const SizedBox(height: 32),

              // Final Submit Button
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10n.submitButton,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildKycUploadButton(String label, IconData icon, bool isLoading) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () {}, // Mock upload logic
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
