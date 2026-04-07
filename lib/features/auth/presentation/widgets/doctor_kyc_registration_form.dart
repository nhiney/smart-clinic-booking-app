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
      final l10n = AppLocalizations.of(context)!;
      if (_selectedHospital == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.required_field),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }
      
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.must_accept_terms),
            backgroundColor: context.colors.warning,
          ),
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
        final l10n = AppLocalizations.of(context)!;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Info
              AppTextField(
                controller: _nameController,
                enabled: !state.isLoading,
                labelText: l10n.full_name_label,
                hintText: l10n.full_name_hint,
                prefixIcon: Icon(Icons.person_outline, color: context.colors.textHint),
                validator: (v) => v!.isEmpty ? l10n.required_field : null,
              ),
              SizedBox(height: context.spacing.m),

              AppTextField(
                controller: _emailController,
                enabled: !state.isLoading,
                labelText: l10n.email_label,
                hintText: l10n.email_hint,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email_outlined, color: context.colors.textHint),
                validator: (v) => (v!.isEmpty || !v.contains('@')) ? l10n.invalid_email : null,
              ),
              SizedBox(height: context.spacing.m),

              AppTextField(
                controller: _passwordController,
                enabled: !state.isLoading,
                labelText: l10n.password_label,
                hintText: l10n.password_hint,
                obscureText: true,
                prefixIcon: Icon(Icons.lock_outline, color: context.colors.textHint),
                validator: (v) => v!.length < 6 ? l10n.password_too_short : null,
              ),
              SizedBox(height: context.spacing.l),

              // B2B KYC Fields
              Text(
                l10n.hospital_label,
                style: context.textStyles.subtitle.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedHospital,
                decoration: InputDecoration(
                  hintText: l10n.hospital_hint,
                  prefixIcon: Icon(Icons.local_hospital_outlined, color: context.colors.textHint),
                ),
                items: _hospitals.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: state.isLoading ? null : (val) => setState(() => _selectedHospital = val),
                 validator: (v) => v == null ? l10n.required_field : null,
              ),
              SizedBox(height: context.spacing.l),

              // Certification Uploads (Mock buttons)
              _buildKycUploadButton(l10n.upload_id_card, Icons.badge_outlined, state.isLoading),
              SizedBox(height: context.spacing.s),
              _buildKycUploadButton(l10n.upload_medical_cert, Icons.school_outlined, state.isLoading),
              SizedBox(height: context.spacing.l),

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

  Widget _buildKycUploadButton(String label, IconData icon, bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () {}, // Mock upload logic
      icon: Icon(icon, size: 20, color: context.colors.primary),
      label: Text(
        label,
        style: context.textStyles.body.copyWith(color: context.colors.primary),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: context.colors.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
      ),
    );
  }
}
