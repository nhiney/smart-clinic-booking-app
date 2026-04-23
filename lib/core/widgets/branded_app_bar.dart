import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final bool? showBackButton;

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
    this.showBackButton,
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

    final bool canPop = Navigator.canPop(context);
    // Determine if we should show a back button even if we can't pop (e.g. for tabs or deep links)
    // We avoid showing it on the root home screen tab (index 0)
    final bool showBack = leading != null || (showBackButton ?? canPop) || onSkip != null;

    return AppBar(
      backgroundColor: backgroundColor ?? context.colors.background,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : 0,
      leadingWidth: leadingWidth ?? 120,
      leading: leading ?? (showBack ? InkWell(
        onTap: () {
          if (canPop) {
            Navigator.maybePop(context);
          } else {
            // If we can't pop, we likely came from a tab or deep link, go to home
            context.go('/');
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.primary, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.back_button_text,
                  style: context.textStyles.bodyBold.copyWith(
                    color: context.colors.primary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
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
