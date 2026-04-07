import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/extensions/context_extension.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
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
      final l10n = AppLocalizations.of(context)!;
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.must_accept_terms),
            backgroundColor: context.colors.warning,
            behavior: SnackBarBehavior.floating,
          ),
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
        final l10n = AppLocalizations.of(context)!;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name field
              AppTextField(
                controller: _nameController,
                enabled: !state.isLoading,
                labelText: l10n.full_name_label,
                hintText: l10n.full_name_hint,
                prefixIcon: Icon(Icons.person_outline, color: context.colors.textHint),
                validator: (value) => 
                  (value == null || value.isEmpty) ? l10n.required_field : null,
              ),
              SizedBox(height: context.spacing.m),

              // Phone number field
              AppTextField(
                controller: _phoneController,
                enabled: !state.isLoading,
                labelText: l10n.phone_label,
                hintText: l10n.phone_hint,
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone_outlined, color: context.colors.textHint),
                validator: (value) => 
                  (value == null || value.isEmpty) ? l10n.required_field : null,
              ),
              SizedBox(height: context.spacing.m),

              // Terms & Conditions
              TermsAndConditionsCheckbox(
                value: _termsAccepted,
                onChanged: (val) => setState(() => _termsAccepted = val ?? false),
              ),
              SizedBox(height: context.spacing.xl),

              // Final Submit Button
              AppButton(
                text: l10n.create_account_button,
                onPressed: _submit,
                isLoading: state.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
