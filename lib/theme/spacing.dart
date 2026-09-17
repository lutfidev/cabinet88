import 'package:flutter/painting.dart';

/// The spacing scale, in logical pixels.
///
/// The design does not round to a 4pt grid, so every step it actually uses is
/// kept here verbatim rather than smoothed into a tidier ramp. Reach for
/// [AppInsets] first; drop to a bare step only when no composite fits.
abstract final class AppSpacing {
  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s5 = 5;
  static const double s6 = 6;
  static const double s7 = 7;
  static const double s8 = 8;
  static const double s9 = 9;
  static const double s10 = 10;
  static const double s11 = 11;
  static const double s12 = 12;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s15 = 15;
  static const double s16 = 16;
  static const double s17 = 17;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s26 = 26;
  static const double s28 = 28;
  static const double s30 = 30;
  static const double s34 = 34;
}

/// The padding composites the design repeats, named for where they are used.
abstract final class AppInsets {
  /// Every top-level screen body (`18px 16px 26px`).
  static const EdgeInsets screen = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    AppSpacing.s18,
    AppSpacing.s16,
    AppSpacing.s26,
  );

  /// A screen body that sits under its own top bar (`0 16px 26px`).
  static const EdgeInsets screenBelowBar = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    0,
    AppSpacing.s16,
    AppSpacing.s26,
  );

  /// Horizontal gutter, for full-bleed rows that re-inset their children.
  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: AppSpacing.s16);

  /// Detail screen top bar (`14px 16px`).
  static const EdgeInsets topBar = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s14,
  );

  /// Play screen top bar (`13px 16px`).
  static const EdgeInsets playBar = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s13,
  );

  /// Play screen HUD strip (`14px 20px`).
  static const EdgeInsets hud = EdgeInsets.symmetric(
    horizontal: AppSpacing.s20,
    vertical: AppSpacing.s14,
  );

  /// A cabinet row in the playlist, and a leaderboard row (`12px 4px`).
  static const EdgeInsets listRow = EdgeInsets.symmetric(
    horizontal: AppSpacing.s4,
    vertical: AppSpacing.s12,
  );

  /// A detail stat tile (`13px 11px`).
  static const EdgeInsets statTile = EdgeInsets.symmetric(
    horizontal: AppSpacing.s11,
    vertical: AppSpacing.s13,
  );

  /// A control or trophy pill (`11px 13px`).
  static const EdgeInsets pill = EdgeInsets.symmetric(
    horizontal: AppSpacing.s13,
    vertical: AppSpacing.s11,
  );

  /// The detail play pill (`10px 16px`).
  static const EdgeInsets playPill = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s10,
  );

  /// The play overlay call to action (`13px 20px`).
  static const EdgeInsets overlayCta = EdgeInsets.symmetric(
    horizontal: AppSpacing.s20,
    vertical: AppSpacing.s13,
  );

  /// The demo-mode call to action (`14px 20px`).
  static const EdgeInsets demoCta = EdgeInsets.symmetric(
    horizontal: AppSpacing.s20,
    vertical: AppSpacing.s14,
  );

  /// A filter chip (`9px 14px`).
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.s14,
    vertical: AppSpacing.s9,
  );

  /// The detail tab strip track (`5px`), and one tab inside it (`10px 6px`).
  static const EdgeInsets tabTrack = EdgeInsets.all(AppSpacing.s5);
  static const EdgeInsets tab = EdgeInsets.symmetric(
    horizontal: AppSpacing.s6,
    vertical: AppSpacing.s10,
  );

  /// The bottom navigation bar (`9px 6px`).
  static const EdgeInsets navBar = EdgeInsets.symmetric(
    horizontal: AppSpacing.s6,
    vertical: AppSpacing.s9,
  );

  /// The detail header card and the tonight-pick card (`14px` / `16px`).
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.s14);
  static const EdgeInsets cardRoomy = EdgeInsets.all(AppSpacing.s16);

  /// A settings row (`14px`), and the purchase note (`15px`).
  static const EdgeInsets settingsRow = EdgeInsets.all(AppSpacing.s14);
  static const EdgeInsets note = EdgeInsets.all(AppSpacing.s15);

  /// The frame around the play field (`10px`).
  static const EdgeInsets playField = EdgeInsets.all(AppSpacing.s10);

  /// The play overlay body (`20px`).
  static const EdgeInsets playOverlay = EdgeInsets.all(AppSpacing.s20);

  /// The toggle track, which insets its own knob (`3px`).
  static const EdgeInsets toggleTrack = EdgeInsets.all(AppSpacing.s3);
}

/// Corner radii, in logical pixels.
abstract final class AppRadii {
  /// Board cell (`2px`) and progress bar (`3px`).
  static const Radius cell = Radius.circular(2);
  static const Radius progress = Radius.circular(3);

  /// Small badge (`4px`).
  static const Radius badge = Radius.circular(4);

  /// Chip with square corners (`8px`), and a detail tab (`9px`).
  static const Radius chipSquare = Radius.circular(8);
  static const Radius tab = Radius.circular(9);

  /// Overlay call to action and top-bar button (`10px`).
  static const Radius button = Radius.circular(10);

  /// Control pill and D-pad key (`11px`).
  static const Radius control = Radius.circular(11);

  /// Stat tile, tab track, art well (`12px`).
  static const Radius tile = Radius.circular(12);

  /// Settings row, purchase note, primary button (`13px`).
  static const Radius row = Radius.circular(13);

  /// Card, play field, tonight-pick (`14px`).
  static const Radius card = Radius.circular(14);

  /// Detail header card (`16px`), and a poster-scale frame (`18px`).
  static const Radius cardLarge = Radius.circular(16);
  static const Radius frame = Radius.circular(18);

  /// Fully rounded chip (`999px`).
  static const Radius pill = Radius.circular(999);
}

/// The same radii as ready-made [BorderRadius] values.
abstract final class AppBorderRadius {
  static const BorderRadius cell = BorderRadius.all(AppRadii.cell);
  static const BorderRadius progress = BorderRadius.all(AppRadii.progress);
  static const BorderRadius badge = BorderRadius.all(AppRadii.badge);
  static const BorderRadius chipSquare = BorderRadius.all(AppRadii.chipSquare);
  static const BorderRadius tab = BorderRadius.all(AppRadii.tab);
  static const BorderRadius button = BorderRadius.all(AppRadii.button);
  static const BorderRadius control = BorderRadius.all(AppRadii.control);
  static const BorderRadius tile = BorderRadius.all(AppRadii.tile);
  static const BorderRadius row = BorderRadius.all(AppRadii.row);
  static const BorderRadius card = BorderRadius.all(AppRadii.card);
  static const BorderRadius cardLarge = BorderRadius.all(AppRadii.cardLarge);
  static const BorderRadius frame = BorderRadius.all(AppRadii.frame);
  static const BorderRadius pill = BorderRadius.all(AppRadii.pill);
}

/// Hairline weights. The design draws every border at 1px except the
/// onboarding marquee frame, which is 2px.
abstract final class AppBorderWidths {
  static const double hairline = 1;
  static const double marquee = 2;
}
