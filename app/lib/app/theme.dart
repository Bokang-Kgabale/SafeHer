import 'package:flutter/material.dart';

/// SafeHer's visual language, lifted from the public-awareness stat sheet
/// this app is built around (deep violet + magenta on white, bold rounded
/// headlines, high-contrast stat cards). Every hand-picked color used
/// outside of `ThemeData` itself (banners, badges, markers) should come from
/// here rather than a bare `Colors.foo.shadeNNN`, so the whole app reads as
/// one system instead of a grab-bag of Material defaults.
abstract final class SafeHerColors {
  /// Primary brand violet — app bar, primary buttons, selected states.
  static const violet = Color(0xFF6A1B9A);
  static const violetDark = Color(0xFF4A0E70);
  static const violetLight = Color(0xFFB388D9);

  /// Secondary brand magenta — accents, active toggles, the "safe route"
  /// affordance.
  static const magenta = Color(0xFFD6247A);
  static const magentaLight = Color(0xFFF48FC0);

  /// Tinted surface used behind grouped controls (quick-actions bar, sheets)
  /// instead of Material's neutral grey, so chrome still reads as "SafeHer"
  /// even where there's no saturated color.
  static const surfaceTint = Color(0xFFF6EEFB);
  static const surfaceTintDark = Color(0xFF241129);

  /// Status semantics used consistently across banners, route lines, and
  /// hotspot markers — never re-picked ad hoc per widget.
  static const danger = Color(0xFFD6247A); // flagged area / panic-adjacent
  static const warning = Color(0xFFE8792A); // caution, degraded state
  static const safe = Color(0xFF2E9E6B); // clear route / resolved
  static const info = Color(0xFF6A1B9A); // neutral guidance
  static const panic = Color(0xFFC62841); // reserved for the panic button only
}

ThemeData buildSafeHerTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: SafeHerColors.violet,
    primary: SafeHerColors.violet,
    secondary: SafeHerColors.magenta,
    error: SafeHerColors.danger,
  );

  const headlineWeight = FontWeight.w800;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFFCFAFE),
    appBarTheme: AppBarTheme(
      backgroundColor: SafeHerColors.violet,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: headlineWeight,
        letterSpacing: 0.2,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: headlineWeight),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      titleSmall: TextStyle(fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SafeHerColors.violet,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SafeHerColors.violet,
        side: const BorderSide(color: SafeHerColors.violet, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: SafeHerColors.violet,
      backgroundColor: SafeHerColors.surfaceTint,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: SafeHerColors.violet.withValues(alpha: 0.08)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    // Deliberately NOT the panic-red color — [PanicButton] sets that
    // explicitly on itself so it's unmistakably alarm-colored regardless of
    // theme, while every other FAB in the app (e.g. "add contact") should
    // read as a normal affirmative action, not an emergency one.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SafeHerColors.violet,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SafeHerColors.violetDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? SafeHerColors.violet : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? SafeHerColors.violetLight : null,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? SafeHerColors.violet
              : SafeHerColors.surfaceTint,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : SafeHerColors.violet,
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: SafeHerColors.violet,
    ),
  );
}
