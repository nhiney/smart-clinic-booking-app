import 'package:flutter/material.dart';
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

  const BrandedAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.leadingWidth,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? context.colors.background,
      elevation: elevation,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth ?? (leading != null ? 100 : 56),
      leading: leading,
      bottom: bottom,
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
                color: context.colors.textPrimary,
              ),
            )
          else
            Text(
              "ICARE",
              style: context.textStyles.heading2.copyWith(
                color: context.colors.primaryDark,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
