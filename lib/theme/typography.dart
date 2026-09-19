import 'package:flutter/painting.dart';

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
