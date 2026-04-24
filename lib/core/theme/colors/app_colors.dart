import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AppColors — Nguồn màu sắc duy nhất (Single Source of Truth)
//
// CẤU TRÚC 2 LỚP:
//   Lớp 1 — Raw Palette: màu nguyên thủy, đặt tên theo tông màu + số
//   Lớp 2 — Semantic Tokens: alias có ý nghĩa, dùng trong code (primary, error...)
//
// CÁCH DÙNG ĐÚNG:
//   • Trong widget có BuildContext  → context.colors.primary
//   • Ngoài widget / static context → AppColors.primary
//   • KHÔNG hardcode hex Color(0xFF...) trực tiếp trong widget
//
// ĐỂ THÊM MÀU MỚI:
//   1. Thêm vào Raw Palette bên dưới
//   2. Nếu cần dùng theo theme → thêm field vào AppColorTokens (app_color_scheme.dart)
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ─── BRAND (ICare Primary Blue) ───────────────────────────────────────────
  // Màu chủ đạo của ứng dụng — dùng cho button, header, icon, link
  static const Color brand      = Color(0xFF0D62A2);
  static const Color brandDark  = Color(0xFF0D47A1);
  static const Color brandDeep  = Color(0xFF003C5C);
  static const Color brandLight = Color(0xFFE3F2FD);
  static const Color brandFaint = Color(0xFFF0F7FF);

  // ─── BLUE SCALE (Tailwind Blue) ───────────────────────────────────────────
  static const Color blue50  = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // ─── LIGHT BLUE SCALE (Material LightBlue) ────────────────────────────────
  static const Color lightBlue50  = Color(0xFFE1F5FE);
  static const Color lightBlue100 = Color(0xFFB3E5FC);
  static const Color lightBlue700 = Color(0xFF0288D1);
  static const Color lightBlue900 = Color(0xFF01579B);

  // ─── SLATE SCALE (Tailwind Slate — dùng cho dark mode & neutral UI) ───────
  static const Color slate50  = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ─── BLUE GRAY SCALE (Material BlueGrey) ──────────────────────────────────
  static const Color blueGray50  = Color(0xFFECEFF1);
  static const Color blueGray100 = Color(0xFFCFD8DC);
  static const Color blueGray400 = Color(0xFF78909C);
  static const Color blueGray500 = Color(0xFF607D8B);
  static const Color blueGray600 = Color(0xFF546E7A);
  static const Color blueGray700 = Color(0xFF455A64);
  static const Color blueGray900 = Color(0xFF263238);

  // ─── GRAY SCALE (Tailwind Gray) ───────────────────────────────────────────
  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // ─── TEAL SCALE (Secondary / Calming) ─────────────────────────────────────
  static const Color teal50  = Color(0xFFF0FDFA);
  static const Color teal100 = Color(0xFFCCFBF1);
  static const Color teal200 = Color(0xFF99F6E4);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color teal700 = Color(0xFF0F766E);
  static const Color teal900 = Color(0xFF134E4A);

  // ─── GREEN / EMERALD (Success) ────────────────────────────────────────────
  static const Color green50  = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFD1FAE5);
  static const Color green500 = Color(0xFF10B981);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);
  static const Color green900 = Color(0xFF064E3B);

  // ─── RED (Error / Danger) ─────────────────────────────────────────────────
  static const Color red50  = Color(0xFFFFF1F2);
  static const Color red100 = Color(0xFFFFE4E6);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  // ─── ORANGE / AMBER (Warning) ─────────────────────────────────────────────
  static const Color amber50  = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  static const Color orange50  = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange500 = Color(0xFFF59E0B);

  // ─── PURPLE / VIOLET (Accent) ─────────────────────────────────────────────
  static const Color purple50  = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple700 = Color(0xFF6D28D9);

  // ─── PINK / ROSE (Special / Highlight) ────────────────────────────────────
  static const Color pink50  = Color(0xFFFDF2F8);
  static const Color pink100 = Color(0xFFFCE7F3);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color pink700 = Color(0xFFBE185D);

  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE91E63);

  // ─── TRANSPARENT & OVERLAY ────────────────────────────────────────────────
  static const Color black4   = Color(0x0A000000);  // shadow nhẹ
  static const Color black8   = Color(0x14000000);  // overlay card
  static const Color black12  = Color(0x1F000000);
  static const Color white0   = Color(0x00FFFFFF);
  static const Color white20  = Color(0x33FFFFFF);  // glass effect
  static const Color white50  = Color(0x80FFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC TOKENS — Alias có ngữ nghĩa
  // Đây là những gì code nên dùng trực tiếp (không phải raw palette trên)
  // ═══════════════════════════════════════════════════════════════════════════

  // --- Brand / Primary ---
  static const Color primary        = brand;
  static const Color primaryDark    = brandDark;
  static const Color primaryDeep    = brandDeep;
  static const Color primaryLight   = brandLight;
  static const Color primarySurface = brandFaint;

  // --- Secondary ---
  static const Color secondary     = teal500;
  static const Color secondaryDark = teal900;
  static const Color secondaryLight = teal100;

  // --- Accent (Purple) ---
  static const Color accent        = purple600;
  static const Color accentLight   = purple100;

  // --- Background & Surface ---
  static const Color background    = gray50;
  static const Color backgroundAlt = slate50;
  static const Color surface       = Colors.white;
  static const Color card          = Colors.white;

  // --- Text ---
  static const Color textPrimary   = gray900;
  static const Color textSecondary = gray500;
  static const Color textHint      = gray300;
  static const Color textDisabled  = gray400;
  static const Color textInverse   = Colors.white;
  static const Color textLink      = brand;

  // --- Border & Divider ---
  static const Color border        = gray200;
  static const Color divider       = gray200;
  static const Color borderFocus   = brand;

  // --- Status ---
  static const Color error         = red600;
  static const Color errorLight    = red100;
  static const Color errorSurface  = red50;

  static const Color success       = green600;
  static const Color successLight  = green200;
  static const Color successSurface = green50;

  static const Color warning       = amber600;
  static const Color warningLight  = amber100;
  static const Color warningSurface = amber50;

  static const Color info          = blue600;
  static const Color infoLight     = blue100;
  static const Color infoSurface   = blue50;

  // --- Navigation Bar ---
  static const Color navSelected   = brand;
  static const Color navUnselected = blueGray600;
  static const Color navBackground = Colors.white;

  // --- Chip / Tag ---
  static const Color chipPrimary   = brandFaint;
  static const Color chipSecondary = teal50;
  static const Color chipError     = red50;
  static const Color chipSuccess   = green50;
  static const Color chipWarning   = amber50;

  // --- Card / Shadow ---
  static const Color cardBackground = Colors.white;
  static const Color shadow         = black8;

  // --- Shimmer (loading skeleton) ---
  static const Color shimmerBase      = gray100;
  static const Color shimmerHighlight = gray50;

  // --- Appointment Status ---
  static const Color statusPending   = amber600;
  static const Color statusConfirmed = brand;
  static const Color statusCompleted = green600;
  static const Color statusCancelled = red600;

  // --- Medical Category Colors (dùng cho icon từng chuyên khoa) ---
  static const Color catCardiology   = Color(0xFFE53E3E);  // tim mạch - đỏ
  static const Color catNeurology    = Color(0xFF805AD5);  // thần kinh - tím
  static const Color catPediatrics   = Color(0xFF38A169);  // nhi khoa - xanh lá
  static const Color catOrthopedics  = Color(0xFFD69E2E);  // xương khớp - vàng
  static const Color catDermatology  = Color(0xFFED64A6);  // da liễu - hồng
  static const Color catOphthalmology = Color(0xFF3182CE); // mắt - xanh
  static const Color catDentistry    = Color(0xFF00B5D8);  // răng hàm mặt - cyan
  static const Color catGastro       = Color(0xFF48BB78);  // tiêu hóa - xanh lá nhạt
  static const Color catGeneral      = brand;              // đa khoa - brand

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brand, brandDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primarySoftGradient = LinearGradient(
    colors: [brand, Color(0xFF1565C0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [teal500, brand],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, gray100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [slate800, slate900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [white20, white0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS — Không phải màu, nhưng tiện dụng
  // ═══════════════════════════════════════════════════════════════════════════

  /// Trả về màu nền nhạt phù hợp với màu nền (dùng cho chip, badge)
  static Color surfaceOf(Color color) =>
      color.withValues(alpha: 0.08);

  /// Trả về màu border nhạt phù hợp với màu nền
  static Color borderOf(Color color) =>
      color.withValues(alpha: 0.2);

  // Giữ alias cũ để tương thích ngược với code đang có
  static const LinearGradient mainGradient = primaryGradient;
  
  // Legacy Aliases — Fix build errors in existing screens
  static const Color textOnPrimary = Colors.white;
}

