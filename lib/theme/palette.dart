import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'colors.dart';

/// The colours that change when high contrast is on.
///
/// Everything in [AppColors] is fixed: hues, backgrounds, accent tints, the
/// board and the scanline pattern. What varies is the dimming — the text
/// ladder, the neutral surface fills and the borders — so those tokens live
/// here instead, and a widget reaches them through `context.palette` rather
/// than a static. Nothing else in the app may hold one of these values.
///
/// [standard] is the design, verbatim. [highContrast] is derived from it by
/// three stated rules and introduces no new hue: every token below keeps its
/// base RGB and moves only in alpha. The rules are recorded in
/// `docs/design-tokens.md` §14, and `test/palette_test.dart` enforces both
/// halves of the guarantee.
@immutable
class AppPalette {
  const AppPalette({
    required this.textPrimary,
    required this.textBody,
    required this.textSecondary,
    required this.textScore,
    required this.textSubtle,
    required this.textPixelMuted,
    required this.textCaption,
    required this.textMeta,
    required this.textHint,
    required this.textFaint,
    required this.textDisabled,
    required this.textLocked,
    required this.surfaceRaised,
    required this.surfaceTrack,
    required this.surfaceTile,
    required this.surfaceRow,
    required this.surfacePressed,
    required this.surfaceFade,
    required this.surfaceToggleOff,
    required this.borderStrong,
    required this.border,
    required this.borderDivider,
    required this.borderDemo,
  });

  // --- Text: a ladder of alphas over #f4eeff --------------------------------

  /// Body and heading text.
  final Color textPrimary;

  /// Cabinet blurb (`.72`), note copy (`.70`), leaderboard scores (`.65`).
  final Color textBody;
  final Color textSecondary;
  final Color textScore;

  /// Subtitles (`.60`), `EXIT` (`.55`), play captions (`.50`).
  final Color textSubtle;
  final Color textPixelMuted;
  final Color textCaption;

  /// Row meta and stat labels (`.45`), settings hints (`.42`), HUD labels
  /// (`.40`), inactive tabs (`.35`), a locked trophy ring (`.25`).
  final Color textMeta;
  final Color textHint;
  final Color textFaint;
  final Color textDisabled;
  final Color textLocked;

  // --- Surfaces: neutral white fills over the background --------------------

  /// Detail header (`.070`), tab strip track (`.050`), stat and trophy tiles
  /// (`.040`), settings rows (`.035`), a pressed row (`.030`), a gradient tail
  /// (`.020`), the off state of a toggle (`.150`).
  final Color surfaceRaised;
  final Color surfaceTrack;
  final Color surfaceTile;
  final Color surfaceRow;
  final Color surfacePressed;
  final Color surfaceFade;
  final Color surfaceToggleOff;

  // --- Borders --------------------------------------------------------------

  /// D-pad key (`.09`), card outline (`.08`), list divider (`.06`), the demo
  /// frame (`.14`).
  final Color borderStrong;
  final Color border;
  final Color borderDivider;
  final Color borderDemo;

  // --- Gradients that spend a palette colour --------------------------------

  /// Detail header card, `linear-gradient(120deg,...)`. A CSS angle of 120deg
  /// points right and down, hence the begin/end pair.
  LinearGradient get detailHeaderGradient => LinearGradient(
        begin: const Alignment(-0.87, -0.5),
        end: const Alignment(0.87, 0.5),
        colors: <Color>[surfaceRaised, surfaceFade],
      );

  /// Demo-mode cabinet screen, `radial-gradient(70% 80% at 50% 45%,...)`.
  RadialGradient get demoScreenGradient => RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 0.8,
        colors: <Color>[borderDemo, AppColors.playBackground],
      );

  /// The design, verbatim. Alpha is baked into the hex so nothing has to
  /// compose opacity at the call site.
  static const AppPalette standard = AppPalette(
    textPrimary: Color(0xFFF4EEFF), // #f4eeff
    textBody: Color(0xB8F4EEFF), // .72
    textSecondary: Color(0xB3F4EEFF), // .70
    textScore: Color(0xA6F4EEFF), // .65
    textSubtle: Color(0x99F4EEFF), // .60
    textPixelMuted: Color(0x8CF4EEFF), // .55
    textCaption: Color(0x80F4EEFF), // .50
    textMeta: Color(0x73F4EEFF), // .45
    textHint: Color(0x6BF4EEFF), // .42
    textFaint: Color(0x66F4EEFF), // .40
    textDisabled: Color(0x59F4EEFF), // .35
    textLocked: Color(0x40F4EEFF), // .25
    surfaceRaised: Color(0x12FFFFFF), // .070
    surfaceTrack: Color(0x0DFFFFFF), // .050
    surfaceTile: Color(0x0AFFFFFF), // .040
    surfaceRow: Color(0x09FFFFFF), // .035
    surfacePressed: Color(0x08FFFFFF), // .030
    surfaceFade: Color(0x05FFFFFF), // .020
    surfaceToggleOff: Color(0x26FFFFFF), // .150
    borderStrong: Color(0x17FFFFFF), // .09
    border: Color(0x14FFFFFF), // .08
    borderDivider: Color(0x0FFFFFFF), // .06
    borderDemo: Color(0x24FFFFFF), // .14
  );

  /// Derived from [standard], never drawn from the design — the design names
  /// the accessibility pass and gives it no values, so these follow three
  /// rules instead of a source line:
  ///
  /// 1. **Text** — the ladder's alpha range `[.25, 1.0]` is remapped onto
  ///    `[.70, 1.0]`, which lifts the dim end clear of WCAG AA against
  ///    `#0a0714` while keeping every step in its original order.
  /// 2. **Borders** — alpha x3.5, so every card, row and key has an edge.
  /// 3. **Surfaces** — alpha x1.8, enough to separate a fill from the ground
  ///    without turning it into a grey slab.
  static const AppPalette highContrast = AppPalette(
    textPrimary: Color(0xFFF4EEFF), // 1.00 — already full
    textBody: Color(0xE3F4EEFF), // .72 -> .89
    textSecondary: Color(0xE1F4EEFF), // .70 -> .88
    textScore: Color(0xDBF4EEFF), // .65 -> .86
    textSubtle: Color(0xD6F4EEFF), // .60 -> .84
    textPixelMuted: Color(0xD1F4EEFF), // .55 -> .82
    textCaption: Color(0xCCF4EEFF), // .50 -> .80
    textMeta: Color(0xC7F4EEFF), // .45 -> .78
    textHint: Color(0xC4F4EEFF), // .42 -> .77
    textFaint: Color(0xC2F4EEFF), // .40 -> .76
    textDisabled: Color(0xBDF4EEFF), // .35 -> .74
    textLocked: Color(0xB3F4EEFF), // .25 -> .70
    surfaceRaised: Color(0x20FFFFFF), // .070 -> .125
    surfaceTrack: Color(0x17FFFFFF), // .050 -> .090
    surfaceTile: Color(0x12FFFFFF), // .040 -> .071
    surfaceRow: Color(0x10FFFFFF), // .035 -> .063
    surfacePressed: Color(0x0EFFFFFF), // .030 -> .055
    surfaceFade: Color(0x09FFFFFF), // .020 -> .035
    surfaceToggleOff: Color(0x44FFFFFF), // .150 -> .267
    borderStrong: Color(0x51FFFFFF), // .09 -> .32
    border: Color(0x46FFFFFF), // .08 -> .27
    borderDivider: Color(0x35FFFFFF), // .06 -> .21
    borderDemo: Color(0x7EFFFFFF), // .14 -> .49
  );
}
