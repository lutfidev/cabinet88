import 'package:flutter/painting.dart';

/// The thirteen-colour palette the placeholder pixel sprites are drawn from.
///
/// Kept apart from [AppColors] because it is art data, not UI chrome: keys match
/// the single-letter codes in the design's `C` map so sprite maps copy across
/// verbatim, and the whole thing is replaced when commissioned art lands
/// (hard rule 6).
abstract final class PixelPalette {
  static const Color green = Color(0xFF6BFF8F);
  static const Color greenDark = Color(0xFF2FAE52);
  static const Color red = Color(0xFFFF3B5C);
  static const Color cyan = Color(0xFF35E5FF);
  static const Color cyanDark = Color(0xFF177F9C);
  static const Color magenta = Color(0xFFFF2D8A);
  static const Color yellow = Color(0xFFFFE14D);
  static const Color orange = Color(0xFFFF9425);
  static const Color white = Color(0xFFF4EEFF);
  static const Color blueGrey = Color(0xFF7D76A6);
  static const Color grey = Color(0xFF9A92BD);
  static const Color brown = Color(0xFFA2662E);
  static const Color pink = Color(0xFFFFB3D1);

  /// A `.` in a sprite map means "leave this cell empty".
  static const String emptyCell = '.';

  static const Map<String, Color> byKey = <String, Color>{
    'g': green,
    'G': greenDark,
    'r': red,
    'c': cyan,
    'C': cyanDark,
    'm': magenta,
    'y': yellow,
    'o': orange,
    'w': white,
    'b': blueGrey,
    's': grey,
    'a': brown,
    'p': pink,
  };
}
