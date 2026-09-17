import 'cabinet.dart';

/// One row of a cabinet's leaderboard.
///
/// The board is mock data, exactly as the design generates it: eight rows
/// derived from the cabinet's own high score, with the player parked at rank
/// five. No colours here — the row widget resolves those from the theme.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.handle,
    required this.score,
    required this.isYou,
  });

  /// One-based position. Rendered zero-padded: `01`, `02`, ...
  final int rank;

  final String handle;
  final int score;

  /// True for the single row that stands in for the player.
  final bool isYou;

  /// `01`, `02`, ... as the design pads them.
  String get rankLabel => rank.toString().padLeft(2, '0');

  String get scoreLabel => Cabinet.formatScore(score);
}

/// The mock leaderboard the design builds for whichever cabinet is open.
abstract final class LeaderboardMock {
  /// The handles, in the design's order.
  static const List<String> handles = <String>[
    'ZED',
    'AAA',
    'M.K.',
    'RYU',
    'JPX',
    'TOM',
    'ELL',
    'KIM',
    'OZ',
    'VIC',
    'ANA',
    'BOB',
  ];

  /// How many rows a board shows.
  static const int rowCount = 8;

  /// The base score for a cabinet that has never been scored.
  static const int unscoredBase = 5200;

  /// Each row is `11%` below the one above it.
  static const double falloff = 0.11;

  /// The row index the player occupies.
  static const int youRow = 4;

  /// The player's handle on their own row.
  static const String youHandle = 'PLR-1 (YOU)';

  /// Builds [rowCount] rows from a cabinet's high score.
  ///
  /// Derived entirely from the cabinet, so an eleventh cabinet needs no change
  /// here or on the screen.
  static List<LeaderboardEntry> forCabinet(Cabinet cabinet) {
    final int base = cabinet.highScore == 0 ? unscoredBase : cabinet.highScore;
    return List<LeaderboardEntry>.generate(rowCount, (int i) {
      final bool isYou = i == youRow;
      return LeaderboardEntry(
        rank: i + 1,
        handle: isYou ? youHandle : handles[i],
        score: (base * (1 - i * falloff)).round(),
        isYou: isYou,
      );
    }, growable: false);
  }
}
