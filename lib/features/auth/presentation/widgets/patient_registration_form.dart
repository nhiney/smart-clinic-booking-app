import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import 'auth_localizations.dart';
import 'terms_and_conditions_checkbox.dart';

class PatientRegistrationForm extends StatefulWidget {
  const PatientRegistrationForm({super.key});

  @override
  State<PatientRegistrationForm> createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        final state = context.read<SignUpBloc>().state;
        final l10n = AuthLocalizations(state.isEnglish);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mustAcceptTerms)),
        );
        return;
      }

      context.read<SignUpBloc>().add(
        SubmitPatientRegistration(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
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
              // Full Name field
              _buildLabel(l10n.fullNameLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  hintText: l10n.fullNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => 
                  (value == null || value.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 20),

              // Phone number field
              _buildLabel(l10n.phoneLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                enabled: !state.isLoading,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: l10n.phoneHint,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (value) => 
                  (value == null || value.isEmpty) ? l10n.requiredField : null,
              ),
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
}
