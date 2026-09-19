import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafeCoreColors extends ThemeExtension<SafeCoreColors> {
  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgMuted;
  final Color borderSoft;
  final Color borderMain;
  final Color fg0;
  final Color fg1;
  final Color fg2;
  final Color fg3;
  final Color accent;
  final Color accentHover;
  final Color statusGreenBg, statusGreenFg;
  final Color statusYellowBg, statusYellowFg;
  final Color statusRedBg, statusRedFg;
  final Color statusBlueBg, statusBlueFg;
  final Color statusIndigoBg, statusIndigoFg;
  final Color statusPurpleBg, statusPurpleFg;
  final Color statusOrangeBg, statusOrangeFg;
  final Color sevBaixo;
  final Color sevMedio;
  final Color sevAlto;
  final Color sevCritico;

  const SafeCoreColors({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgMuted,
    required this.borderSoft,
    required this.borderMain,
    required this.fg0,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.accent,
    required this.accentHover,
    required this.statusGreenBg,
    required this.statusGreenFg,
    required this.statusYellowBg,
    required this.statusYellowFg,
    required this.statusRedBg,
    required this.statusRedFg,
    required this.statusBlueBg,
    required this.statusBlueFg,
    required this.statusIndigoBg,
    required this.statusIndigoFg,
    required this.statusPurpleBg,
    required this.statusPurpleFg,
    required this.statusOrangeBg,
    required this.statusOrangeFg,
    required this.sevBaixo,
    required this.sevMedio,
    required this.sevAlto,
    required this.sevCritico,
  });

  static const light = SafeCoreColors(
    bgBase: Color(0xFFF1F5F9),
    bgSurface: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFF8FAFC),
    bgMuted: Color(0xFFF1F5F9),
    borderSoft: Color(0xFFE2E8F0),
    borderMain: Color(0xFFCBD5E1),
    fg0: Color(0xFF0F172A),
    fg1: Color(0xFF1E293B),
    fg2: Color(0xFF475569),
    fg3: Color(0xFF94A3B8),
    accent: Color(0xFF3B82F6),
    accentHover: Color(0xFF2563EB),
    statusGreenBg: Color(0xFFD1FAE5),
    statusGreenFg: Color(0xFF15803D),
    statusYellowBg: Color(0xFFFEF3C7),
    // Darkened from #A16207 (4.42:1, under the 4.5:1 text floor) to clear it in every theme.
    statusYellowFg: Color(0xFF9C5F07),
    statusRedBg: Color(0xFFFEE2E2),
    statusRedFg: Color(0xFFB91C1C),
    statusBlueBg: Color(0xFFDBEAFE),
    statusBlueFg: Color(0xFF1D4ED8),
    statusIndigoBg: Color(0xFFE0E7FF),
    statusIndigoFg: Color(0xFF4338CA),
    statusPurpleBg: Color(0xFFF3E8FF),
    statusPurpleFg: Color(0xFF7E22CE),
    statusOrangeBg: Color(0xFFFFEDD5),
    statusOrangeFg: Color(0xFFC2410C),
    sevBaixo: Color(0xFF3FB950),
    sevMedio: Color(0xFFD29922),
    sevAlto: Color(0xFFF97316),
    sevCritico: Color(0xFFF85149),
  );

  static const dark = SafeCoreColors(
    bgBase: Color(0xFF0B1118),        // ProtoColors.bg
    bgSurface: Color(0xFF151A21),     // ProtoColors.surface
    bgElevated: Color(0xFF1A2028),    // ProtoColors.surface2
    bgMuted: Color(0xFF1A2534),       // ProtoColors.hero
    borderSoft: Color(0xFF26303B),    // ProtoColors.border
    borderMain: Color(0xFF748195),    // ProtoColors.borderStrong
    fg0: Color(0xFFF8FBFF),           // ProtoColors.text
    fg1: Color(0xFFBCC5D0),
    // Lightened from #566170 (2.6-3.0:1 on the app's surfaces) to clear 4.5:1 — this
    // color is used for real secondary copy, not just decoration.
    fg2: Color(0xFF7D899B),
    fg3: Color(0xFF3F4A57),
    accent: Color(0xFF58A6FF),        // ProtoColors.blue
    accentHover: Color(0xFF88BFFF),
    statusGreenBg: Color(0xFF0B3A1C),
    statusGreenFg: Color(0xFF3FB950), // ProtoColors.green
    statusYellowBg: Color(0xFF4A390A),
    // Lightened from #D29922 (4.42:1, under the 4.5:1 text floor) to clear it.
    statusYellowFg: Color(0xFFD69C23),
    statusRedBg: Color(0xFF4A1017),
    statusRedFg: Color(0xFFFF4D4D),   // ProtoColors.red
    statusBlueBg: Color(0xFF0B2A3A),
    statusBlueFg: Color(0xFF58A6FF),
    statusIndigoBg: Color(0xFF2A164A),
    // Lightened from #5F3FF2 (2.65:1 on its own pill background) to clear 4.5:1.
    statusIndigoFg: Color(0xFF8F78F6),
    statusPurpleBg: Color(0xFF1F1040),
    // Lightened from #5F3FF2 (2.88:1 on its own pill background) to clear 4.5:1.
    statusPurpleFg: Color(0xFF876FF5),
    statusOrangeBg: Color(0xFF2B1800),
    statusOrangeFg: Color(0xFFFF7A1A), // ProtoColors.orange
    sevBaixo: Color(0xFF3FB950),
    sevMedio: Color(0xFFD29922),
    sevAlto: Color(0xFFF97316),
    sevCritico: Color(0xFFFF4D4D),
  );

  @override
  SafeCoreColors copyWith() => this;

  @override
  SafeCoreColors lerp(ThemeExtension<SafeCoreColors>? other, double t) =>
      t < .5 ? this : other as SafeCoreColors;
}

class SafeCoreRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

class SafeCoreShadows {
  static const sm = [
    BoxShadow(color: Color(0x12000000), offset: Offset(0, 1), blurRadius: 3),
  ];
  static const md = [
    BoxShadow(color: Color(0x12000000), offset: Offset(0, 4), blurRadius: 8),
  ];
  static const lg = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 10), blurRadius: 30),
  ];
}

/// Named type scale, extracted from the most-repeated fontSize/fontWeight pairs
/// across the app (see the SafeCore design system's tokens.json for the full audit).
/// `bodyMedium` and `bodyRegular` are new: the source jumps straight from an
/// unset 400 default to 700+ with nothing between, which read as inconsistent
/// rather than as a deliberate hierarchy — these two fill that gap.
class SafeCoreType {
  static const micro = TextStyle(fontSize: 10, height: 1.4, fontWeight: FontWeight.w700);
  static const label = TextStyle(fontSize: 11, height: 1.27, fontWeight: FontWeight.w900, letterSpacing: .2);
  static const bodyRegular = TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w700);
  static const bodyMedium = TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w600);
  static const bodyStrong = TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w800);
  static const subtitle = TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w800);
  static const title = TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w800);
  static const headline = TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w900);
  static const display = TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w900);
}

extension SafeCoreTheme on BuildContext {
  SafeCoreColors get c => Theme.of(this).extension<SafeCoreColors>()!;
}

ThemeData safeCoreThemeLight() => _theme(SafeCoreColors.light, Brightness.light);
ThemeData safeCoreThemeDark() => _theme(SafeCoreColors.dark, Brightness.dark);

class SafeCoreMotion {
  static const fast = Duration(milliseconds: 180);
  static const base = Duration(milliseconds: 240);
  static const standard = Duration(milliseconds: 300);
  static const curve = Curves.easeOutCubic;
}

ThemeData _theme(SafeCoreColors c, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  // Manrope was named everywhere via a bare fontFamily string but never actually
  // bundled or fetched — google_fonts (already a dependency) now loads and caches
  // it lazily on first use, so the family the app has always asked for finally renders.
  final manropeFamily = GoogleFonts.manrope().fontFamily;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.bgBase,
    fontFamily: manropeFamily,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: c.fg0,
            onPrimary: c.bgBase,
            secondary: c.accent,
            surface: c.bgSurface,
            onSurface: c.fg0,
            error: c.statusRedFg,
          )
        : ColorScheme.light(
            primary: c.fg0,
            onPrimary: Colors.white,
            secondary: c.accent,
            surface: c.bgSurface,
            onSurface: c.fg0,
            error: c.statusRedFg,
          ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SafeCoreRadius.sm),
        borderSide: BorderSide(color: c.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SafeCoreRadius.sm),
        borderSide: BorderSide(color: c.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SafeCoreRadius.sm),
        borderSide: BorderSide(color: c.accent, width: 1.6),
      ),
    ),
    extensions: [c],
  );
}
