import 'package:flutter/painting.dart';

/// The genres the design tags cabinets with, and filters the library by.
enum CabinetGenre {
  arcade('Arcade'),
  puzzle('Puzzle'),
  versus('Versus'),
  shooter('Shooter'),
  cards('Cards'),
  reflex('Reflex');

  const CabinetGenre(this.label);

  /// The label exactly as the design renders it.
  final String label;
}

/// One line of the "How to play" list: an input and what it does.
class CabinetControl {
  const CabinetControl({required this.input, required this.action});

  /// The pixel-type key cap, e.g. `D-PAD`, `SWIPE`, `TAP`.
  final String input;

  /// What that input does, in sentence case.
  final String action;
}

/// One of the ten cabinets in the vault.
///
/// Every cabinet is owned from first launch — there is no locked state, no
/// price and no entitlement, per hard rule 8.
class Cabinet {
  const Cabinet({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.hue,
    required this.highScore,
    required this.plays,
    required this.blurb,
    required this.note,
    required this.controls,
    this.playable = false,
  });

  /// Stable key. Doubles as the sprite-map key.
  final String id;

  final String title;
  final CabinetGenre genre;
  final int year;

  /// The cabinet's signature colour, drawn from the accent palette. Used for
  /// its sprite glow and its marquee stripe.
  final Color hue;

  /// Personal best. Zero means never scored, which the UI shows as a dash.
  final int highScore;

  /// Lifetime runs.
  final int plays;

  /// The one-line hook.
  final String blurb;

  /// The second line, on restoration and rules.
  final String note;

  final List<CabinetControl> controls;

  /// Whether the real game ships behind the play shell. Only Serpent 88 does
  /// in v1; the other nine show the demo-mode placeholder.
  final bool playable;

  /// The catalog's seeded high score, as the design formats it. Where a real
  /// best exists — Serpent 88's — the UI reads that instead, through
  /// [scoreLabel].
  String get highScoreLabel => scoreLabel(highScore);

  /// A score as the design writes it: grouped thousands, or an em dash when
  /// there is nothing to show.
  static String scoreLabel(int score) => score == 0 ? '—' : formatScore(score);

  /// A score as a screen reader should hear it.
  ///
  /// The drawn em dash means "never scored", which does not survive being
  /// read out loud.
  static String spokenScore(int score) => score == 0 ? 'none yet' : formatScore(score);

  /// `24680` becomes `24,680`, matching `toLocaleString('en-US')`.
  static String formatScore(int value) {
    final String digits = value.toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }
}
