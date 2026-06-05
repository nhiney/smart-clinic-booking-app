import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ICare Design Tokens — Single Source of Truth for all UI screens
// ═══════════════════════════════════════════════════════════════════════════

class IColors {
  IColors._();

  // Primary — Clinical Blue
  static const Color primary500  = Color(0xFF0056D2);
  static const Color primary700  = Color(0xFF003E96);
  static const Color primary100  = Color(0xFFDBE5FB);
  static const Color primary50   = Color(0xFFEEF3FE);

  // Slate Ink — Text hierarchy
  static const Color ink         = Color(0xFF0A1426);
  static const Color ink2        = Color(0xFF4B5773);
  static const Color ink3        = Color(0xFF94A0B6);
  static const Color ink200      = Color(0xFFCDD5E2);

  // Backgrounds & Borders
  static const Color line        = Color(0xFFECEFF5);
  static const Color line2       = Color(0xFFF4F6FA);
  static const Color bg          = Color(0xFFF5F7FB);
  static const Color surface     = Color(0xFFFFFFFF);

  // Semantic
  static const Color success     = Color(0xFF128864);
  static const Color successBg   = Color(0xFFE8F7F2);
  static const Color warning     = Color(0xFFB47800);
  static const Color warningBg   = Color(0xFFFFF8E6);
  static const Color danger      = Color(0xFFC8323F);
  static const Color dangerBg    = Color(0xFFFFF0F0);
  static const Color violet      = Color(0xFF5B47D6);
  static const Color violetBg    = Color(0xFFF0EEFF);
  static const Color mint        = Color(0xFF0AA493);
  static const Color mintBg      = Color(0xFFE6F8F7);
  static const Color amber       = Color(0xFFC97B00);
  static const Color amberBg     = Color(0xFFFFF9E6);
  static const Color rose        = Color(0xFFD43F75);
  static const Color roseBg      = Color(0xFFFFF0F5);

  // Navy dark gradient
  static const Color navy        = Color(0xFF0A1A47);
  static const Color navyMid     = Color(0xFF003E96);

  // Shadows
  static const BoxShadow shadow1 = BoxShadow(
    color: Color(0x0A0A1426),
    blurRadius: 2,
    offset: Offset(0, 1),
  );
  static const BoxShadow shadow2 = BoxShadow(
    color: Color(0x1A0A1426),
    blurRadius: 24,
    spreadRadius: -10,
    offset: Offset(0, 8),
  );

  static List<BoxShadow> get cardShadow => [shadow1, shadow2];

  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(color: Color(0x180A1426), blurRadius: 4, offset: Offset(0, 2)),
    const BoxShadow(color: Color(0x250A1426), blurRadius: 32, spreadRadius: -8, offset: Offset(0, 12)),
  ];
}

class IFont {
  IFont._();
  static const String interTight = 'InterTight';
  static const String inter      = 'Inter';
  static const String mono       = 'JetBrainsMono';
}

class IText {
  IText._();

  // Display — Headlines (Inter Tight 800)
  static TextStyle display({double size = 30, Color color = IColors.ink}) => TextStyle(
    fontFamily: IFont.interTight,
    fontSize: size,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.025 * size,
    color: color,
    height: 1.05,
  );

  // Section Title
  static TextStyle sectionTitle({Color color = IColors.ink}) => TextStyle(
    fontFamily: IFont.interTight,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  // Body
  static TextStyle body({double size = 13.5, FontWeight weight = FontWeight.w400, Color color = IColors.ink2}) => TextStyle(
    fontFamily: IFont.inter,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.45,
  );

  // Caption / Label all-caps
  static TextStyle label({double size = 11, Color color = IColors.ink3}) => TextStyle(
    fontFamily: IFont.inter,
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: color,
  );

  // Tabular numbers — for stats, prices, times
  static TextStyle num({double size = 14, FontWeight weight = FontWeight.w700, Color color = IColors.ink}) => TextStyle(
    fontFamily: IFont.interTight,
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Mono — for codes, QR
  static TextStyle mono({double size = 13, Color color = IColors.ink3}) => TextStyle(
    fontFamily: IFont.mono,
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color,
    letterSpacing: 0.5,
  );
}

class ISpacing {
  ISpacing._();
  static const double pagePad  = 24.0;
  static const double cardGap  = 10.0;
  static const double secGap   = 24.0;
  static const double cardR    = 16.0;
}

// Pill / Badge widget factory
class IPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final double? fontSize;
  final IconData? icon;
  final bool dot;

  const IPill({
    super.key,
    required this.label,
    this.bg = IColors.primary50,
    this.fg = IColors.primary500,
    this.fontSize,
    this.icon,
    this.dot = false,
  });

  const IPill.success(String label, {super.key, IconData? icon})
      : label = label, bg = IColors.successBg, fg = IColors.success, fontSize = null, icon = icon, dot = false;

  const IPill.warning(String label, {super.key, IconData? icon})
      : label = label, bg = IColors.warningBg, fg = IColors.warning, fontSize = null, icon = icon, dot = false;

  const IPill.danger(String label, {super.key, IconData? icon})
      : label = label, bg = IColors.dangerBg, fg = IColors.danger, fontSize = null, icon = icon, dot = false;

  const IPill.violet(String label, {super.key, IconData? icon})
      : label = label, bg = IColors.violetBg, fg = IColors.violet, fontSize = null, icon = icon, dot = false;

  const IPill.ink(String label, {super.key, IconData? icon})
      : label = label, bg = IColors.ink, fg = IColors.surface, fontSize = null, icon = icon, dot = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: IFont.inter,
              fontSize: fontSize ?? 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Section header widget
class ISectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const ISectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title.toUpperCase(), style: IText.label()),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: IText.body(size: 12, color: IColors.primary500, weight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// Doctor avatar widget
class IDoctorAvatar extends StatelessWidget {
  final double size;
  final String initials;
  final bool verified;
  final Color? color;

  const IDoctorAvatar({
    super.key,
    this.size = 48,
    required this.initials,
    this.verified = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? IColors.primary500;
    return SizedBox(
      width: size + (verified ? 10 : 0),
      height: size + (verified ? 10 : 0),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [bg.withValues(alpha: 0.85), bg],
                center: Alignment.topLeft,
                radius: 1.2,
              ),
              boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(initials, style: TextStyle(
                fontFamily: IFont.interTight,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              )),
            ),
          ),
          if (verified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: IColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(Icons.check, color: Colors.white, size: size * 0.16),
              ),
            ),
        ],
      ),
    );
  }
}
