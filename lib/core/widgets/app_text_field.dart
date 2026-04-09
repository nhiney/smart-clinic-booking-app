import 'package:flutter/material.dart';
import '../theme/radius/app_radius.dart';
import '../theme/typography/app_text_styles.dart';
import '../extensions/context_extension.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = true,
    this.textAlign = TextAlign.start,
    this.style,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyles.subtitle.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textAlign: textAlign,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: style ?? AppTextStyles.body.copyWith(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: context.colors.textHint),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: showCounter ? null : "",
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mRadius,
              borderSide: BorderSide(color: context.colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mRadius,
              borderSide: BorderSide(color: context.colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mRadius,
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mRadius,
              borderSide: BorderSide(color: context.colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mRadius,
              borderSide: BorderSide(color: context.colors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
