import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
      backgroundColor: backgroundColor ?? AppColors.background,
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          else
            const Text(
              "ICARE",
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 20,
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
