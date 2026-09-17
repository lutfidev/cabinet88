import 'package:flutter/painting.dart';

/// Fixed component boxes the design pins to an exact size.
///
/// Separate from the spacing scale: these are the dimensions of specific
/// controls, not steps a layout can choose from.
abstract final class AppSizes {
  /// The device frame the design was drawn against.
  static const Size designFrame = Size(412, 892);

  /// Sprite box in a playlist row.
  static const double rowSprite = 34;

  /// Trophy glyph ring: detail screen, then trophy case.
  static const double trophyGlyph = 36;
  static const double trophyGlyphLarge = 38;

  /// Detail top-bar button.
  static const double topBarButton = 38;

  /// Home avatar button.
  static const double avatarButton = 42;

  /// Settings toggle track and its knob.
  static const Size toggleTrack = Size(44, 26);
  static const double toggleKnob = 20;

  /// One D-pad key, on a 3x3 grid with a 5px gutter.
  static const double dpadKey = 54;

  /// The round action button.
  static const double actionButton = 72;

  /// Cabinet art on the detail header card.
  static const double detailArt = 88;

  /// Demo-mode cabinet screen height.
  static const double demoScreen = 300;

  /// Play field: a 16x16 board on a 17px pitch, each cell inset 1px.
  static const int boardCells = 16;
  static const double boardPitch = 17;
  static const double boardCellInset = 1;

  /// Progress bars: inline, then the trophy case.
  static const double progressBar = 4;
  static const double progressBarLarge = 6;

  /// Maximum width of centred overlay copy, then demo copy.
  static const double overlayCopyWidth = 220;
  static const double demoCopyWidth = 280;

  /// Sprite pixel sizes the design draws cabinet art at.
  static const double spriteNav = 2;
  static const double spriteRow = 4;
  static const double spriteAvatar = 5;
  static const double spriteTile = 7;
  static const double spriteDetail = 9;
  static const double spriteGrid = 10;
  static const double spriteFeatured = 13;
  static const double spriteExtraLarge = 20;

  /// A sprite's glow blur is 1.2x its pixel size.
  static const double spriteGlowFactor = 1.2;
}
