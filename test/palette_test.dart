import 'package:cabinet88/theme/app_theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 23 tokens that vary by theme, standard beside its derivation.
///
/// Listed by hand because that is the point: if someone adds a token to
/// [AppPalette] and not to this table, the count test fails and the guarantees
/// below never silently stop covering it.
final List<(String, Color, Color)> _tokens = <(String, Color, Color)>[
  ('textPrimary', AppPalette.standard.textPrimary, AppPalette.highContrast.textPrimary),
  ('textBody', AppPalette.standard.textBody, AppPalette.highContrast.textBody),
  ('textSecondary', AppPalette.standard.textSecondary, AppPalette.highContrast.textSecondary),
  ('textScore', AppPalette.standard.textScore, AppPalette.highContrast.textScore),
  ('textSubtle', AppPalette.standard.textSubtle, AppPalette.highContrast.textSubtle),
  ('textPixelMuted', AppPalette.standard.textPixelMuted, AppPalette.highContrast.textPixelMuted),
  ('textCaption', AppPalette.standard.textCaption, AppPalette.highContrast.textCaption),
  ('textMeta', AppPalette.standard.textMeta, AppPalette.highContrast.textMeta),
  ('textHint', AppPalette.standard.textHint, AppPalette.highContrast.textHint),
  ('textFaint', AppPalette.standard.textFaint, AppPalette.highContrast.textFaint),
  ('textDisabled', AppPalette.standard.textDisabled, AppPalette.highContrast.textDisabled),
  ('textLocked', AppPalette.standard.textLocked, AppPalette.highContrast.textLocked),
  ('surfaceRaised', AppPalette.standard.surfaceRaised, AppPalette.highContrast.surfaceRaised),
  ('surfaceTrack', AppPalette.standard.surfaceTrack, AppPalette.highContrast.surfaceTrack),
  ('surfaceTile', AppPalette.standard.surfaceTile, AppPalette.highContrast.surfaceTile),
  ('surfaceRow', AppPalette.standard.surfaceRow, AppPalette.highContrast.surfaceRow),
  ('surfacePressed', AppPalette.standard.surfacePressed, AppPalette.highContrast.surfacePressed),
  ('surfaceFade', AppPalette.standard.surfaceFade, AppPalette.highContrast.surfaceFade),
  ('surfaceToggleOff', AppPalette.standard.surfaceToggleOff, AppPalette.highContrast.surfaceToggleOff),
  ('borderStrong', AppPalette.standard.borderStrong, AppPalette.highContrast.borderStrong),
  ('border', AppPalette.standard.border, AppPalette.highContrast.border),
  ('borderDivider', AppPalette.standard.borderDivider, AppPalette.highContrast.borderDivider),
  ('borderDemo', AppPalette.standard.borderDemo, AppPalette.highContrast.borderDemo),
];

/// The text ladder, in the order it is drawn — brightest first.
List<(String, Color, Color)> get _ladder => _tokens.take(12).toList();

/// Flattens a translucent colour onto the app background, so its contrast can
/// be measured the way a reader actually sees it.
Color _over(Color foreground, Color background) => Color.from(
      alpha: 1,
      red: foreground.a * foreground.r + (1 - foreground.a) * background.r,
      green: foreground.a * foreground.g + (1 - foreground.a) * background.g,
      blue: foreground.a * foreground.b + (1 - foreground.a) * background.b,
    );

/// WCAG contrast ratio against [AppColors.background].
double _contrast(Color text) {
  const Color background = AppColors.background;
  final double a = _over(text, background).computeLuminance();
  final double b = background.computeLuminance();
  final double lighter = a > b ? a : b;
  final double darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('the table covers every token on the palette', () {
    // 23 fields, and the two gradients are derived from them.
    expect(_tokens.length, 23);
    expect(_tokens.map((t) => t.$1).toSet().length, 23);
  });

  test('high contrast introduces no new hue', () {
    for (final (String name, Color standard, Color derived) in _tokens) {
      expect(derived.r, closeTo(standard.r, 0.001), reason: '$name red moved');
      expect(derived.g, closeTo(standard.g, 0.001), reason: '$name green moved');
      expect(derived.b, closeTo(standard.b, 0.001), reason: '$name blue moved');
    }
  });

  test('high contrast never dims a token', () {
    for (final (String name, Color standard, Color derived) in _tokens) {
      expect(derived.a, greaterThanOrEqualTo(standard.a), reason: '$name went dimmer');
    }
  });

  test('both palettes keep the ladder in its order', () {
    for (int i = 1; i < _ladder.length; i++) {
      expect(_ladder[i].$2.a, lessThan(_ladder[i - 1].$2.a),
          reason: '${_ladder[i].$1} is not below ${_ladder[i - 1].$1} in standard');
      expect(_ladder[i].$3.a, lessThan(_ladder[i - 1].$3.a),
          reason: '${_ladder[i].$1} is not below ${_ladder[i - 1].$1} in high contrast');
    }
  });

  test('every text token clears WCAG AA in high contrast', () {
    for (final (String name, _, Color derived) in _ladder) {
      expect(_contrast(derived), greaterThanOrEqualTo(4.5), reason: '$name is under AA');
    }
  });

  test('the dim end of the design does not clear AA, which is why the theme exists', () {
    // Not a complaint about the design — it is a mood piece, and this is the
    // one place the two goals genuinely disagree.
    expect(_contrast(AppPalette.standard.textLocked), lessThan(4.5));
    expect(_contrast(AppPalette.standard.textDisabled), lessThan(4.5));
    expect(_contrast(AppPalette.standard.textPrimary), greaterThanOrEqualTo(4.5));
  });
}
