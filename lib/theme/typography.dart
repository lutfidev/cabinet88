import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// The two faces Cabinet88 uses.
///
/// `Press Start 2P` is the pixel display face: marquee type, section eyebrows,
/// HUD readouts, anything that should read as cabinet silkscreen. Everything
/// else is `Space Grotesk`, which keeps the app legible as modern Android.
abstract final class AppFonts {
  static const String pixelFamily = 'Press Start 2P';
  static const String bodyFamily = 'Space Grotesk';
}

/// The raw size scale, for the rare widget that needs a bare number rather
/// than a finished [TextStyle].
abstract final class AppFontSizes {
  // Pixel face.
  static const double pixel7 = 7;
  static const double pixel75 = 7.5;
  static const double pixel8 = 8;
  static const double pixel9 = 9;
  static const double pixel10 = 10;
  static const double pixel11 = 11;
  static const double pixel12 = 12;
  static const double pixel13 = 13;
  static const double pixel14 = 14;
  static const double pixel22 = 22;
  // Body face.
  static const double body105 = 10.5;
  static const double body11 = 11;
  static const double body115 = 11.5;
  static const double body12 = 12;
  static const double body125 = 12.5;
  static const double body13 = 13;
  static const double body135 = 13.5;
  static const double body14 = 14;
  static const double body145 = 14.5;
  static const double body18 = 18;
  static const double body19 = 19;
  static const double body22 = 22;
  // Chevrons, stars and D-pad arrows.
  static const double glyph15 = 15;
  static const double glyph16 = 16;
  static const double glyph17 = 17;
}

/// Line-height multipliers, matching the design's unitless `line-height`.
abstract final class AppLineHeights {
  static const double tight = 1.25;
  static const double snug = 1.3;
  static const double normal = 1.5;
  static const double relaxed = 1.55;
  static const double loose = 1.6;
  static const double overlay = 1.7;
}

/// Letter-spacing, in logical pixels.
abstract final class AppLetterSpacing {
  static const double label = 0.5;
  static const double wordmarkSub = 1.0;
}

/// Font weights. Press Start 2P has one weight; these apply to Space Grotesk.
abstract final class AppFontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// Finished text styles, named by the role they fill.
abstract final class AppTextStyles {
  static TextStyle _pixel(double size, Color color, {double? letterSpacing, double? height}) =>
      GoogleFonts.pressStart2p(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle _body(
    double size,
    Color color, {
    FontWeight weight = AppFontWeights.regular,
    double? height,
  }) =>
      GoogleFonts.spaceGrotesk(fontSize: size, color: color, fontWeight: weight, height: height);

  // --- Pixel face ------------------------------------------------------------

  /// The `CABINET 88` marquee.
  static TextStyle get wordmark =>
      _pixel(AppFontSizes.pixel22, AppColors.accentHighlight, height: AppLineHeights.normal);

  /// The line under the wordmark.
  static TextStyle get wordmarkSub => _pixel(
        AppFontSizes.pixel8,
        AppColors.accentSecondary,
        letterSpacing: AppLetterSpacing.wordmarkSub,
      );

  /// Bottom navigation label.
  static TextStyle get navLabel => _pixel(AppFontSizes.pixel7, AppColors.textDisabled);

  /// Genre and year on the detail header card.
  static TextStyle get detailMeta => _pixel(AppFontSizes.pixel75, AppColors.textMeta);

  /// Small eyebrow: `TONIGHT'S PICK`, `CABINET FILE`, `PURCHASE`.
  static TextStyle get eyebrow => _pixel(AppFontSizes.pixel8, AppColors.accentHighlight);

  /// The `CABINET FILE` label on the detail top bar. The same size as
  /// [eyebrow], but the design draws this one muted, not in highlight yellow.
  static TextStyle get topBarEyebrow => _pixel(AppFontSizes.pixel8, AppColors.textMeta);

  /// Section header: `ALL CABINETS`, `CABINET SETTINGS`, `GOOD EVENING`.
  static TextStyle get sectionHeader =>
      _pixel(AppFontSizes.pixel9, AppColors.accentSecondary, letterSpacing: AppLetterSpacing.label);

  /// The greeting eyebrow on the home header. Same face and tracking as
  /// [sectionHeader], but the design draws this one in magenta, not cyan.
  static TextStyle get greetingEyebrow =>
      _pixel(AppFontSizes.pixel9, AppColors.accentPrimary, letterSpacing: AppLetterSpacing.label);

  /// The high score at the end of a playlist row.
  static TextStyle get rowScore => _pixel(AppFontSizes.pixel8, AppColors.textPixelMuted);

  /// Play-shell chrome: `EXIT`, `PAUSE`, HUD labels, leaderboard rows.
  static TextStyle get pixelLabel => _pixel(AppFontSizes.pixel9, AppColors.textFaint);

  /// A leaderboard handle. The same face and size as [pixelLabel], drawn at
  /// full strength; [pixelLabel] itself carries the rank's default colour.
  static TextStyle get leaderHandle => _pixel(AppFontSizes.pixel9, AppColors.textPrimary);

  /// Text inside the green play pill.
  static TextStyle get playButton => _pixel(AppFontSizes.pixel9, AppColors.onAccentPositive);

  /// Call to action inside the play overlay.
  static TextStyle get overlayCta => _pixel(AppFontSizes.pixel10, AppColors.onAccent);

  /// Detail stat tile value, and a detail trophy glyph.
  static TextStyle get statValue => _pixel(AppFontSizes.pixel11, AppColors.accentSecondary);

  /// The single character inside a detail trophy ring. A locked row recolours
  /// this to [AppColors.textLocked], as the design does.
  static TextStyle get trophyGlyph => _pixel(AppFontSizes.pixel11, AppColors.accentHighlight);

  /// Trophy-case glyph and podium numeral.
  static TextStyle get glyphPixel => _pixel(AppFontSizes.pixel12, AppColors.accentHighlight);

  /// HUD readout.
  static TextStyle get hudValue => _pixel(AppFontSizes.pixel13, AppColors.textPrimary);

  /// Play overlay title, which carries its own generous leading.
  static TextStyle get overlayTitle =>
      _pixel(AppFontSizes.pixel13, AppColors.accentHighlight, height: AppLineHeights.overlay);

  /// Profile stat value.
  static TextStyle get statValueLarge => _pixel(AppFontSizes.pixel14, AppColors.accentPrimary);

  // --- Body face -------------------------------------------------------------

  /// Label under a stat tile value.
  static TextStyle get statLabel => _body(AppFontSizes.body105, AppColors.textMeta);

  /// Row meta, settings hints, trophy descriptions, the D-pad hint.
  static TextStyle get caption => _body(AppFontSizes.body11, AppColors.textFaint);

  /// A trophy description. One step brighter than [caption]; the design draws
  /// this line at .45, not .40.
  static TextStyle get captionMeta => _body(AppFontSizes.body11, AppColors.textMeta);

  /// Inline links such as `See all` and `All 10`, and footer notes.
  static TextStyle get captionLink => _body(AppFontSizes.body115, AppColors.textMeta);

  /// Detail tab label.
  static TextStyle get tabLabel => _body(AppFontSizes.body12, AppColors.textSubtle);

  /// The workhorse: subtitles, scores, chips, overlay notes.
  static TextStyle get bodySmall => _body(AppFontSizes.body125, AppColors.textSubtle);

  /// The line under a card title, such as the tonight-pick subtitle. One step
  /// dimmer than [bodySmall].
  static TextStyle get cardSubtitle => _body(AppFontSizes.body125, AppColors.textScore);

  /// The score at the end of a leaderboard row.
  static TextStyle get leaderScore => _body(AppFontSizes.body125, AppColors.textScore);

  /// Note copy inside a card.
  static TextStyle get body =>
      _body(AppFontSizes.body13, AppColors.textSecondary, height: AppLineHeights.relaxed);

  /// Settings row label, trophy name.
  static TextStyle get bodyStrong =>
      _body(AppFontSizes.body135, AppColors.textPrimary, weight: AppFontWeights.semiBold);

  /// Cabinet blurb on the detail screen.
  static TextStyle get blurb =>
      _body(AppFontSizes.body14, AppColors.textBody, height: AppLineHeights.loose);

  /// Cabinet title in a playlist row.
  static TextStyle get rowTitle =>
      _body(AppFontSizes.body145, AppColors.textPrimary, weight: AppFontWeights.medium);

  /// Title on the tonight-pick card.
  static TextStyle get cardTitle =>
      _body(AppFontSizes.body18, AppColors.textPrimary, weight: AppFontWeights.semiBold);

  /// Cabinet title on the detail header card.
  static TextStyle get detailTitle => _body(
        AppFontSizes.body19,
        AppColors.textPrimary,
        weight: AppFontWeights.bold,
        height: AppLineHeights.tight,
      );

  /// Screen heading, e.g. `The vault is open`.
  static TextStyle get screenTitle =>
      _body(AppFontSizes.body22, AppColors.textPrimary, weight: AppFontWeights.semiBold);
}
