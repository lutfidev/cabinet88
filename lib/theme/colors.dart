import 'package:flutter/painting.dart';

/// Every colour in Cabinet88 that does not vary by theme.
///
/// The text ladder, the neutral surface fills and the borders all change
/// when high contrast is on, so they are not here — they live in
/// `palette.dart` and are reached through `context.palette`.
///
/// Values are lifted verbatim from `design/Arcade Vault.dc.html`; the source CSS
/// is noted against each one. Alpha is baked into the hex so nothing has to
/// compose opacity at the call site. The sprite art palette lives separately, in
/// `pixel_palette.dart`.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------

  /// Top stop of the app shell gradient.
  static const Color backgroundTop = Color(0xFF140C24); // #140c24

  /// Base app background, gradient stops 45% and 100%.
  static const Color background = Color(0xFF0A0714); // #0a0714

  /// The play screen sits on its own darker ground.
  static const Color playBackground = Color(0xFF05040A); // #05040a

  /// Well behind a pixel sprite: cabinet art boxes, list thumbs.
  static const Color artWell = Color(0xFF0B0714); // #0b0714

  /// Top stop of a cabinet tile gradient; bottom stop is [artWell].
  static const Color tileTop = Color(0xFF171029); // #171029

  /// Bottom tab bar, over a 12px backdrop blur.
  static const Color tabBarBackground = Color(0xF00C0814); // rgba(12,8,20,.94)

  /// Scrim behind the play overlay.
  static const Color playOverlayScrim = Color(0xDB05040A); // rgba(5,4,10,.86)

  // ---------------------------------------------------------------------------
  // Text on an accent fill
  // ---------------------------------------------------------------------------

  // The text ladder itself varies with the high-contrast theme, so it lives
  // in `palette.dart`. These two do not: they are read against a filled
  // accent, never against the app background.

  /// Text on a filled accent button.
  static const Color onAccent = Color(0xFFFFFFFF); // #fff

  /// Text on the green play pill.
  static const Color onAccentPositive = Color(0xFF06180D); // #06180d

  // ---------------------------------------------------------------------------
  // Accents
  // ---------------------------------------------------------------------------

  /// Magenta: primary accent, active tab, progress, toggle-on.
  static const Color accentPrimary = Color(0xFFFF2D8A); // #ff2d8a

  /// Cyan: section headers, stat values, secondary chrome.
  static const Color accentSecondary = Color(0xFF35E5FF); // #35e5ff

  /// Yellow: marquee type, rank 01, trophy rings.
  static const Color accentHighlight = Color(0xFFFFE14D); // #ffe14d

  /// Green: play actions, live score, affirmatives.
  static const Color accentPositive = Color(0xFF6BFF8F); // #6bff8f

  /// Orange: rank 03.
  static const Color accentWarning = Color(0xFFFF9425); // #ff9425

  /// Red: game over.
  static const Color accentDanger = Color(0xFFFF3B5C); // #ff3b5c

  /// Label of an active filter chip.
  static const Color accentPrimarySoft = Color(0xFFFFB3D1); // #ffb3d1

  // ---------------------------------------------------------------------------
  // Accent tints
  // ---------------------------------------------------------------------------

  static const Color primaryTintStrong = Color(0x38FF2D8A); // .22 — card fill
  static const Color primaryTintBorder = Color(0x4DFF2D8A); // .30 — card border
  static const Color primaryTintRow = Color(0x24FF2D8A); // .14 — the player row

  static const Color secondaryTintFill = Color(0x1435E5FF); // .08 — avatar fill
  static const Color secondaryTintStrong = Color(0x2435E5FF); // .14 — card fill
  static const Color secondaryTintHairline = Color(0x2935E5FF); // .16 — nav rule
  static const Color secondaryTintBorder = Color(0x4D35E5FF); // .30 — avatar

  /// Wordmark glow.
  static const Color highlightGlow = Color(0x8CFFE14D); // .55

  static const Color positiveTintFill = Color(0x0D6BFF8F); // .05 — note fill
  static const Color positiveTintCore = Color(0x126BFF8F); // .07 — field core
  static const Color positiveTintBorder = Color(0x476BFF8F); // .28 — field edge
  static const Color positiveTintPressed = Color(0x4D6BFF8F); // .30 — key down
  static const Color positiveTintDashed = Color(0x596BFF8F); // .35 — note edge
  static const Color positiveTintCta = Color(0x666BFF8F); // .40 — demo CTA
  static const Color positiveTintGlow = Color(0x806BFF8F); // .50 — field glow

  // ---------------------------------------------------------------------------
  // Play field
  // ---------------------------------------------------------------------------

  static const Color boardCell = Color(0x0B6BFF8F); // .045 — empty cell
  static const Color boardBody = accentPositive; // serpent body
  static const Color boardHead = Color(0xFFDCFFE8); // #dcffe8
  static const Color boardFood = accentPrimary; // food pellet

  static const Color actionButtonTop = Color(0xFFFF6FAE); // #ff6fae
  static const Color actionButtonBottom = Color(0xFFD5145F); // #d5145f
  static const Color actionButtonShadow = Color(0xFF7D0B38); // #7d0b38

  // ---------------------------------------------------------------------------
  // CRT overlay
  // ---------------------------------------------------------------------------

  static const Color scanlineDark = Color(0x42000000); // rgba(0,0,0,.26)
  static const Color scanlineLight = Color(0x03FFFFFF); // rgba(255,255,255,.012)
  static const Color vignette = Color(0x8C000000); // rgba(0,0,0,.55)
  static const Color vignetteClear = Color(0x00000000); // rgba(0,0,0,0)

  // ---------------------------------------------------------------------------
  // Leaderboard ranks
  // ---------------------------------------------------------------------------

  /// Ranks 01, 02 and 03. Every rank below falls back to the palette
  /// `textFaint`, which the leaderboard row supplies.
  static const List<Color> rankColors = <Color>[
    accentHighlight,
    accentSecondary,
    accentWarning,
  ];
}
