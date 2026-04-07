import 'package:flutter/material.dart';
import '../theme/colors/app_colors.dart';

class ICareLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;
  final bool isLight;

  const ICareLogo({
    super.key,
    this.size = 60,
    this.showText = true,
    this.textColor,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? (isLight ? Colors.white : AppColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Using the user-provided PNG for perfect brand consistency
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'ICARE',
            style: TextStyle(
              fontSize: size / 2.5,
              fontWeight: FontWeight.w900,
              color: defaultTextColor,
              letterSpacing: 1.5,
              height: 1.0,
            ),
          ),
          Text(
            'Healthcare Excellence',
            style: TextStyle(
              fontSize: size / 8,
              fontWeight: FontWeight.w600,
              color: defaultTextColor.withOpacity(0.6),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ],
    );
  }
}
