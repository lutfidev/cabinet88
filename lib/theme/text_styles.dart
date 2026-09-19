import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'colors.dart';
import 'palette.dart';
import 'typography.dart';

/// Finished text styles, named by the role they fill.
///
/// Instance-based, not static, because most of these spend a colour from
/// [AppPalette] and that palette changes when high contrast is on. Widgets
/// reach them through `context.text`; the geometry they are built from —
/// families, sizes, line heights, weights — stays static in `typography.dart`,
/// because none of it varies by theme.
@immutable
class AppTextStyles {
  const AppTextStyles(this.palette);

  final AppPalette palette;

  // Both faces are bundled under the family names in `typography.dart` and
  // declared in `pubspec.yaml`. Nothing here fetches anything: a release build
  // carries no INTERNET permission, so a downloaded face would resolve to the
  // system default and lose the whole pixel treatment.

  TextStyle _pixel(double size, Color color, {double? letterSpacing, double? height}) =>
      TextStyle(
        fontFamily: AppFonts.pixelFamily,
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  TextStyle _body(
    double size,
    Color color, {
    FontWeight weight = AppFontWeights.regular,
    double? height,
  }) =>
      TextStyle(
        fontFamily: AppFonts.bodyFamily,
        // The D-pad arrows and the star are not in Space Grotesk. Nothing else
        // in the app reaches past the first family.
        fontFamilyFallback: const <String>[AppFonts.symbolFamily],
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
      );

  // --- Pixel face ------------------------------------------------------------

  /// The `CABINET 88` marquee.
  TextStyle get wordmark =>
      _pixel(AppFontSizes.pixel22, AppColors.accentHighlight, height: AppLineHeights.normal);

  /// The line under the wordmark.
  TextStyle get wordmarkSub => _pixel(
        AppFontSizes.pixel8,
        AppColors.accentSecondary,
        letterSpacing: AppLetterSpacing.wordmarkSub,
      );

  /// Bottom navigation label.
  TextStyle get navLabel => _pixel(AppFontSizes.pixel7, palette.textDisabled);

  /// Genre and year on the detail header card.
  TextStyle get detailMeta => _pixel(AppFontSizes.pixel75, palette.textMeta);

  /// Small eyebrow: `TONIGHT'S PICK`, `CABINET FILE`, `PURCHASE`.
  TextStyle get eyebrow => _pixel(AppFontSizes.pixel8, AppColors.accentHighlight);

  /// The `CABINET FILE` label on the detail top bar. The same size as
  /// [eyebrow], but the design draws this one muted, not in highlight yellow.
  TextStyle get topBarEyebrow => _pixel(AppFontSizes.pixel8, palette.textMeta);

  /// Section header: `ALL CABINETS`, `CABINET SETTINGS`, `GOOD EVENING`.
  TextStyle get sectionHeader =>
      _pixel(AppFontSizes.pixel9, AppColors.accentSecondary, letterSpacing: AppLetterSpacing.label);

  /// The greeting eyebrow on the home header. Same face and tracking as
  /// [sectionHeader], but the design draws this one in magenta, not cyan.
  TextStyle get greetingEyebrow =>
      _pixel(AppFontSizes.pixel9, AppColors.accentPrimary, letterSpacing: AppLetterSpacing.label);

  /// The high score at the end of a playlist row.
  TextStyle get rowScore => _pixel(AppFontSizes.pixel8, palette.textPixelMuted);

  /// Play-shell chrome: `EXIT`, `PAUSE`, HUD labels, leaderboard rows.
  TextStyle get pixelLabel => _pixel(AppFontSizes.pixel9, palette.textFaint);

  /// A leaderboard handle. The same face and size as [pixelLabel], drawn at
  /// full strength; [pixelLabel] itself carries the rank's default colour.
  TextStyle get leaderHandle => _pixel(AppFontSizes.pixel9, palette.textPrimary);

  /// Text inside the green play pill.
  TextStyle get playButton => _pixel(AppFontSizes.pixel9, AppColors.onAccentPositive);

  /// Call to action inside the play overlay.
  TextStyle get overlayCta => _pixel(AppFontSizes.pixel10, AppColors.onAccent);

  /// Detail stat tile value, and a detail trophy glyph.
  TextStyle get statValue => _pixel(AppFontSizes.pixel11, AppColors.accentSecondary);

  /// The single character inside a detail trophy ring. A locked row recolours
  /// this to [AppPalette.textLocked], as the design does.
  TextStyle get trophyGlyph => _pixel(AppFontSizes.pixel11, AppColors.accentHighlight);

  /// Trophy-case glyph and podium numeral.
  TextStyle get glyphPixel => _pixel(AppFontSizes.pixel12, AppColors.accentHighlight);

  /// HUD readout.
  TextStyle get hudValue => _pixel(AppFontSizes.pixel13, palette.textPrimary);

  /// Play overlay title, which carries its own generous leading.
  TextStyle get overlayTitle =>
      _pixel(AppFontSizes.pixel13, AppColors.accentHighlight, height: AppLineHeights.overlay);

  /// A D-pad arrow. The design leaves these on the body face, at glyph size.
  TextStyle get dpadGlyph => _body(AppFontSizes.glyph17, palette.textPrimary);

  /// Profile stat value.
  TextStyle get statValueLarge => _pixel(AppFontSizes.pixel14, AppColors.accentPrimary);

  // --- Body face -------------------------------------------------------------

  /// Label under a stat tile value.
  TextStyle get statLabel => _body(AppFontSizes.body105, palette.textMeta);

  /// Row meta, settings hints, trophy descriptions, the D-pad hint.
  TextStyle get caption => _body(AppFontSizes.body11, palette.textFaint);

  /// A trophy description. One step brighter than [caption]; the design draws
  /// this line at .45, not .40.
  TextStyle get captionMeta => _body(AppFontSizes.body11, palette.textMeta);

  /// Inline links such as `See all` and `All 10`, and footer notes.
  TextStyle get captionLink => _body(AppFontSizes.body115, palette.textMeta);

  /// Detail tab label.
  TextStyle get tabLabel => _body(AppFontSizes.body12, palette.textSubtle);

  /// The workhorse: subtitles, scores, chips, overlay notes.
  TextStyle get bodySmall => _body(AppFontSizes.body125, palette.textSubtle);

  /// The line under a card title, such as the tonight-pick subtitle. One step
  /// dimmer than [bodySmall].
  TextStyle get cardSubtitle => _body(AppFontSizes.body125, palette.textScore);

  /// The score at the end of a leaderboard row.
  TextStyle get leaderScore => _body(AppFontSizes.body125, palette.textScore);

  /// Note copy inside a card.
  TextStyle get body =>
      _body(AppFontSizes.body13, palette.textSecondary, height: AppLineHeights.relaxed);

  /// Trophy name, and the profile's `Trophies earned` row.
  TextStyle get bodyStrong =>
      _body(AppFontSizes.body135, palette.textPrimary, weight: AppFontWeights.semiBold);

  /// Settings row label. The same size as [bodyStrong], but the design draws
  /// this one at 500, not 600.
  TextStyle get settingsLabel =>
      _body(AppFontSizes.body135, palette.textPrimary, weight: AppFontWeights.medium);

  /// Cabinet blurb on the detail screen.
  TextStyle get blurb =>
      _body(AppFontSizes.body14, palette.textBody, height: AppLineHeights.loose);

  /// Cabinet title in a playlist row.
  TextStyle get rowTitle =>
      _body(AppFontSizes.body145, palette.textPrimary, weight: AppFontWeights.medium);

  /// Title on the tonight-pick card.
  TextStyle get cardTitle =>
      _body(AppFontSizes.body18, palette.textPrimary, weight: AppFontWeights.semiBold);

  /// Cabinet title on the detail header card.
  TextStyle get detailTitle => _body(
        AppFontSizes.body19,
        palette.textPrimary,
        weight: AppFontWeights.bold,
        height: AppLineHeights.tight,
      );

  /// Screen heading, e.g. `The vault is open`.
  TextStyle get screenTitle =>
      _body(AppFontSizes.body22, palette.textPrimary, weight: AppFontWeights.semiBold);
}
