import 'package:flutter/painting.dart';

/// Every colour in Cabinet88, named by the role it plays.
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
  // Text — a ladder of alphas over #f4eeff
  // ---------------------------------------------------------------------------

  /// Body and heading text.
  static const Color textPrimary = Color(0xFFF4EEFF); // #f4eeff

  static const Color textBody = Color(0xB8F4EEFF); // .72 — cabinet blurb
  static const Color textSecondary = Color(0xB3F4EEFF); // .70 — note copy
  static const Color textScore = Color(0xA6F4EEFF); // .65 — leaderboard scores
  static const Color textSubtle = Color(0x99F4EEFF); // .60 — subtitles
  static const Color textPixelMuted = Color(0x8CF4EEFF); // .55 — `EXIT`
  static const Color textCaption = Color(0x80F4EEFF); // .50 — play captions
  static const Color textMeta = Color(0x73F4EEFF); // .45 — row meta, stat labels
  static const Color textHint = Color(0x6BF4EEFF); // .42 — settings hints
  static const Color textFaint = Color(0x66F4EEFF); // .40 — HUD labels
  static const Color textDisabled = Color(0x59F4EEFF); // .35 — inactive tabs
  static const Color textLocked = Color(0x40F4EEFF); // .25 — locked trophy ring

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
  // Surfaces — neutral fills over the background
  // ---------------------------------------------------------------------------

  static const Color surfaceRaised = Color(0x12FFFFFF); // .070 — detail header
  static const Color surfaceTrack = Color(0x0DFFFFFF); // .050 — tab strip track
  static const Color surfaceTile = Color(0x0AFFFFFF); // .040 — stat, trophy
  static const Color surfaceRow = Color(0x09FFFFFF); // .035 — settings rows
  static const Color surfacePressed = Color(0x08FFFFFF); // .030 — row pressed
  static const Color surfaceFade = Color(0x05FFFFFF); // .020 — gradient tail
  static const Color surfaceToggleOff = Color(0x26FFFFFF); // .150 — toggle off

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------

  static const Color borderStrong = Color(0x17FFFFFF); // .09 — D-pad key
  static const Color border = Color(0x14FFFFFF); // .08 — card outline
  static const Color borderDivider = Color(0x0FFFFFFF); // .06 — list divider
  static const Color borderDemo = Color(0x24FFFFFF); // .14 — demo frame

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

  /// Ranks 01, 02 and 03. Every rank below falls back to [textFaint].
  static const List<Color> rankColors = <Color>[
    accentHighlight,
    accentSecondary,
    accentWarning,
  ];
}
