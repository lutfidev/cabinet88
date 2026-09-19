import 'package:flutter/material.dart';

import 'colors.dart';
import 'palette.dart';
import 'spacing.dart';
import 'text_styles.dart';
import 'typography.dart';

export 'colors.dart';
export 'effects.dart';
export 'palette.dart';
export 'pixel_palette.dart';
export 'sizes.dart';
export 'spacing.dart';
export 'text_styles.dart';
export 'typography.dart';

/// Assembles the [ThemeData] Cabinet88 runs on.
///
/// The app is dark only. There is no light variant in the design, so there is
/// no light theme here either — but there are two dark palettes, the design's
/// own and its high-contrast derivation, and [themeFor] builds a theme from
/// whichever is live.
abstract final class AppTheme {
  /// The design, verbatim.
  static ThemeData get dark => themeFor(AppPalette.standard);

  /// The accessibility pass: brighter text, firmer edges, no scanlines.
  static ThemeData get highContrast => themeFor(AppPalette.highContrast);

  static ThemeData themeFor(AppPalette palette) {
    final AppTextStyles text = AppTextStyles(palette);
    final ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accentPrimary,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accentSecondary,
      onSecondary: AppColors.background,
      tertiary: AppColors.accentHighlight,
      onTertiary: AppColors.artWell,
      error: AppColors.accentDanger,
      onError: AppColors.onAccent,
      surface: AppColors.background,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surfaceRaised,
      onSurfaceVariant: palette.textMeta,
      outline: palette.border,
      outlineVariant: palette.borderDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppFonts.bodyFamily,
      textTheme: _textTheme(text),
      dividerTheme: DividerThemeData(
        color: palette.borderDivider,
        thickness: AppBorderWidths.hairline,
        space: AppBorderWidths.hairline,
      ),
    );
  }

  static TextTheme _textTheme(AppTextStyles text) => TextTheme(
        displayLarge: text.wordmark,
        headlineMedium: text.screenTitle,
        titleLarge: text.detailTitle,
        titleMedium: text.cardTitle,
        titleSmall: text.rowTitle,
        bodyLarge: text.blurb,
        bodyMedium: text.body,
        bodySmall: text.bodySmall,
        labelLarge: text.bodyStrong,
        labelMedium: text.caption,
        labelSmall: text.statLabel,
      );
}

/// Puts the live [AppPalette] in the tree.
///
/// Installed once, in `main.dart`, above every route. Widgets never read it
/// directly — they go through `context.palette` and `context.text`.
class PaletteScope extends InheritedWidget {
  const PaletteScope({super.key, required this.palette, required super.child});

  final AppPalette palette;

  /// Falls back to the design's own palette when nothing has installed a
  /// scope, so a widget lifted into a test harness still renders.
  static AppPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaletteScope>()?.palette ??
      AppPalette.standard;

  @override
  bool updateShouldNotify(PaletteScope oldWidget) => oldWidget.palette != palette;
}

/// The two accessors every widget uses. Nothing else may reach a palette
/// colour or a role style.
extension PaletteContext on BuildContext {
  AppPalette get palette => PaletteScope.of(this);

  AppTextStyles get text => AppTextStyles(palette);
}
