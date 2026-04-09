import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../extensions/context_extension.dart';
import 'icare_logo.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final double? leadingWidth;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onSkip;

  const BrandedAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = false,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.leadingWidth,
    this.leading,
    this.bottom,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final finalActions = <Widget>[...?actions];
    if (onSkip != null) {
      finalActions.add(
        TextButton(
          onPressed: onSkip,
          child: Text(
            l10n.skip,
            style: context.textStyles.bodyBold.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? context.colors.background,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : 0,
      leadingWidth: leadingWidth ?? (leading != null ? 120 : 120),
      leading: leading ?? (Navigator.canPop(context) ? InkWell(
        onTap: () => Navigator.maybePop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Icon(Icons.arrow_back, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(
              l10n.back_button_text,
              style: context.textStyles.bodyBold.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ) : null),
      bottom: bottom,
      title: (title != null || showLogo) ? Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (showLogo) ...[
            const ICareLogo(
              size: 32,
              showText: false,
            ),
            const SizedBox(width: 10),
          ],
          if (title != null)
            Text(
              title!,
              style: context.textStyles.heading3.copyWith(
                color: context.colors.primaryDark,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
        ],
      ) : const SizedBox.shrink(),
      actions: finalActions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
