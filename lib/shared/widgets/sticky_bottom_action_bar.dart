import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';

class StickyBottomActionBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;
  final bool isBusy;

  const StickyBottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.spacing.l,
          context.spacing.m,
          context.spacing.l,
          context.spacing.l,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.border)),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (secondaryLabel != null && onSecondaryTap != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : onSecondaryTap,
                  child: Text(secondaryLabel!),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: isBusy ? null : onPrimaryTap,
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
