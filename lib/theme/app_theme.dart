import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

export 'colors.dart';
export 'effects.dart';
export 'pixel_palette.dart';
export 'sizes.dart';
export 'spacing.dart';
export 'typography.dart';

/// Assembles the [ThemeData] Cabinet88 runs on.
///
/// The app is dark only. There is no light variant in the design, so there is
/// no light theme here either.
abstract final class AppTheme {
  static ThemeData get dark {
    const ColorScheme scheme = ColorScheme(
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
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceRaised,
      onSurfaceVariant: AppColors.textMeta,
      outline: AppColors.border,
      outlineVariant: AppColors.borderDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppFonts.bodyFamily,
      textTheme: _textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDivider,
        thickness: AppBorderWidths.hairline,
        space: AppBorderWidths.hairline,
      ),
    );
  }

  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTextStyles.wordmark,
        headlineMedium: AppTextStyles.screenTitle,
        titleLarge: AppTextStyles.detailTitle,
        titleMedium: AppTextStyles.cardTitle,
        titleSmall: AppTextStyles.rowTitle,
        bodyLarge: AppTextStyles.blurb,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.bodyStrong,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.statLabel,
      );
}
