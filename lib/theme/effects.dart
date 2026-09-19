import 'package:flutter/painting.dart';

import 'colors.dart';

/// Gradients, shadows and motion timings from the design.
///
/// The two gradients that spend a palette colour — the detail header card
/// and the demo-mode screen — are not here. They vary with the
/// high-contrast theme, so they live on `AppPalette` instead.
///
/// These live here for the same reason colours do: hard rule 4 means no widget
/// may carry a raw value, and a gradient stop is as much a design value as a
/// hex is.
///
/// CSS sizes a radial gradient as an ellipse (`70% 80% at 50% 45%`); Flutter's
/// [RadialGradient] is circular. Where the two disagree the radius below takes
/// the larger CSS axis. That is a mapping decision, recorded in
/// `docs/design-tokens.md`, not an invented value.
abstract final class AppGradients {
  /// App shell, `linear-gradient(180deg,#140c24 0%,#0a0714 45%,#0a0714 100%)`.
  static const LinearGradient appShell = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColors.backgroundTop,
      AppColors.background,
      AppColors.background,
    ],
    stops: <double>[0.0, 0.45, 1.0],
  );

  /// Tonight-pick card, `linear-gradient(120deg,...)`. A CSS angle of 120deg
  /// points right and down, hence the begin/end pair.
  static const LinearGradient tonightPick = LinearGradient(
    begin: Alignment(-0.87, -0.5),
    end: Alignment(0.87, 0.5),
    colors: <Color>[
      AppColors.primaryTintStrong,
      AppColors.secondaryTintStrong,
    ],
  );

  /// Cabinet tile, `linear-gradient(180deg,#171029,#0b0714)`.
  static const LinearGradient tile = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.tileTop, AppColors.artWell],
  );

  /// Round action button, `radial-gradient(circle at 35% 30%,#ff6fae,#d5145f)`.
  static const RadialGradient actionButton = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.9,
    colors: <Color>[
      AppColors.actionButtonTop,
      AppColors.actionButtonBottom,
    ],
  );

  /// Play field, `radial-gradient(80% 80% at 50% 50%,...)`.
  static const RadialGradient playField = RadialGradient(
    radius: 0.8,
    colors: <Color>[
      AppColors.positiveTintCore,
      AppColors.playBackground,
    ],
  );

  /// CRT vignette, `radial-gradient(120% 80% at 50% 40%,...)`.
  static const RadialGradient crtVignette = RadialGradient(
    center: Alignment(0, -0.2),
    radius: 1.2,
    colors: <Color>[AppColors.vignetteClear, AppColors.vignette],
    stops: <double>[0.45, 1.0],
  );
}

/// Drop shadows and glows.
abstract final class AppShadows {
  /// Play field, `0 0 50px -18px rgba(107,255,143,.5)`.
  static const List<BoxShadow> playField = <BoxShadow>[
    BoxShadow(
      color: AppColors.positiveTintGlow,
      blurRadius: 50,
      spreadRadius: -18,
    ),
  ];

  /// Action button, `0 8px 0 -2px #7d0b38`. A hard offset, no blur.
  static const List<BoxShadow> actionButton = <BoxShadow>[
    BoxShadow(
      color: AppColors.actionButtonShadow,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  /// Serpent head, `0 0 12px #6bff8f`.
  static const List<BoxShadow> boardHeadGlow = <BoxShadow>[
    BoxShadow(color: AppColors.boardBody, blurRadius: 12),
  ];

  /// Food pellet, `0 0 12px #ff2d8a`.
  static const List<BoxShadow> boardFoodGlow = <BoxShadow>[
    BoxShadow(color: AppColors.boardFood, blurRadius: 12),
  ];

  /// Wordmark, `text-shadow:0 0 18px rgba(255,225,77,.55)`.
  static const List<Shadow> wordmarkGlow = <Shadow>[
    Shadow(color: AppColors.highlightGlow, blurRadius: 18),
  ];
}

/// The CRT scanline pattern, used by the one overlay widget (hard rule 5).
///
/// `repeating-linear-gradient` over a 3px period: 1px of [AppColors.scanlineDark]
/// then 2px of [AppColors.scanlineLight].
abstract final class AppScanlines {
  static const double period = 3;
  static const double darkBand = 1;

  /// The lighter in-art pattern the design layers over cabinet screens uses the
  /// same 1px-in-3px period, at these alphas instead.
  static const Color artDark = Color(0x4D000000);
}

/// Animation timings.
abstract final class AppDurations {
  /// `avRise .3s ease both` — every screen entrance.
  static const Duration screenRise = Duration(milliseconds: 300);

  /// `avBlink 1.4s steps(1,end) infinite` — the demo-mode `PRESS START`.
  static const Duration blink = Duration(milliseconds: 1400);

  /// `avPulse 2.6s ease-out infinite`.
  static const Duration pulse = Duration(milliseconds: 2600);

  /// `avSweep 5s linear infinite`.
  static const Duration sweep = Duration(seconds: 5);
}

/// Opacity values the design applies to whole elements.
abstract final class AppOpacities {
  /// A locked trophy on the detail screen (`.45`) and in the trophy case (`.4`).
  static const double lockedDetail = 0.45;
  static const double lockedCase = 0.4;

  /// The off state of a blinking label (`.25`).
  static const double blinkOff = 0.25;
}
