import 'package:flutter/material.dart';
import '../theme/radius/app_radius.dart';
import '../extensions/context_extension.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(context.spacing.m),
      decoration: BoxDecoration(
        color: color ?? context.colors.surface,
        borderRadius: borderRadius ?? AppRadius.mRadius,
        border: border ?? Border.all(color: context.colors.divider.withOpacity(0.5)),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
