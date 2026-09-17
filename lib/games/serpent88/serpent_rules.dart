/// Serpent 88's rules, exactly as the design's prototype states them
/// (`docs/design-tokens.md` section 12, lifted from `Arcade Vault.dc.html`).
///
/// Plain Dart on purpose: the whole logic layer is testable without a widget
/// binding, and every number a run depends on is in this one file.
abstract final class SerpentRules {
  /// The field is 16 x 16. Nothing wraps — a wall ends the run.
  static const int gridSize = 16;

  /// Three segments, head first, facing right in the middle of the field.
  static const List<Cell> startSnake = <Cell>[
    Cell(8, 8),
    Cell(7, 8),
    Cell(6, 8),
  ];

  static const Direction startDirection = Direction.right;

  /// The first apple is always in the same place, four cells ahead.
  static const Cell startFood = Cell(12, 8);

  /// The opening tick, and the floor the speed ramp stops at.
  static const int startStepMs = 140;
  static const int fastestStepMs = 70;

  /// Every apple takes this much off the tick.
  static const int stepDecayMs = 5;

  /// An apple is worth `10 + apples eaten so far`, counting itself.
  static const int scorePerApple = 10;

  /// Five apples to a level, starting at one.
  static const int applesPerLevel = 5;

  /// How long a step lasts once [eaten] apples are down.
  static int stepMsFor(int eaten) {
    final int ramped = startStepMs - eaten * stepDecayMs;
    return ramped < fastestStepMs ? fastestStepMs : ramped;
  }

  /// The HUD's level readout.
  static int levelFor(int eaten) => eaten ~/ applesPerLevel + 1;

  /// What an apple adds to the score, given the count *after* eating it.
  static int scoreFor(int eaten) => scorePerApple + eaten;
}

/// One square of the field. Immutable, comparable, cheap to make.
class Cell {
  const Cell(this.x, this.y);

  final int x;
  final int y;

  Cell translated(Direction direction) =>
      Cell(x + direction.dx, y + direction.dy);

  /// Whether this square is off the board. There is no wrap-around.
  bool get isOutsideField =>
      x < 0 || y < 0 || x >= SerpentRules.gridSize || y >= SerpentRules.gridSize;

  @override
  bool operator ==(Object other) => other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Cell($x, $y)';
}

/// The four headings. The serpent never stops, so there is no fifth.
enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.dx, this.dy);

  final int dx;
  final int dy;

  /// A turn into this heading's opposite is a turn into your own neck.
  bool isOpposite(Direction other) => dx == -other.dx && dy == -other.dy;
}
