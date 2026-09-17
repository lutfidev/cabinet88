import 'dart:collection';
import 'dart:math';

import 'serpent_rules.dart';

/// Serpent 88's simulation: the whole game, with no clock and no pixels.
///
/// Zero Flutter imports — the phase guardrail. It knows nothing about tickers,
/// painters or widgets: something else decides *when* [step] runs, and
/// something else decides how [snake] and [food] are drawn.
class SerpentEngine {
  SerpentEngine({Random? random}) : _random = random ?? Random() {
    start();
  }

  /// Injected so a test can force an apple to land where it wants one.
  final Random _random;

  final List<Cell> _snake = <Cell>[];
  late final UnmodifiableListView<Cell> _snakeView =
      UnmodifiableListView<Cell>(_snake);

  /// Turns taken but not yet stepped into. At most [maxQueuedTurns].
  final Queue<Direction> _turns = Queue<Direction>();

  /// Two, so a fast corner — up then left before the next step — keeps both
  /// halves of the turn. The prototype held one and dropped the first.
  static const int maxQueuedTurns = 2;

  late Direction _direction;
  late Cell _food;
  int _score = 0;
  int _eaten = 0;
  bool _isOver = false;

  /// The serpent, head first.
  List<Cell> get snake => _snakeView;

  Cell get head => _snake.first;
  Cell get food => _food;

  /// The heading the next [step] will take, queued turns aside.
  Direction get direction => _direction;

  int get score => _score;
  int get eaten => _eaten;
  int get level => SerpentRules.levelFor(_eaten);

  /// How long the current step lasts. Drops as apples go down.
  int get stepMs => SerpentRules.stepMsFor(_eaten);

  /// The run is finished: a wall or the serpent's own body.
  bool get isOver => _isOver;

  /// Drop a fresh coin. Everything returns to the design's opening position.
  void start() {
    _snake
      ..clear()
      ..addAll(SerpentRules.startSnake);
    _turns.clear();
    _direction = SerpentRules.startDirection;
    _food = SerpentRules.startFood;
    _score = 0;
    _eaten = 0;
    _isOver = false;
  }

  /// Queue a turn. Returns whether it was taken.
  ///
  /// Rejected: a reversal into your own neck, and a turn you are already
  /// making. Both are measured against the *last queued* heading rather than
  /// the one on screen, so two turns in one step can never combine into a
  /// reversal.
  bool turn(Direction next) {
    if (_isOver) {
      return false;
    }
    final Direction latest = _turns.isEmpty ? _direction : _turns.last;
    if (next == latest || next.isOpposite(latest)) {
      return false;
    }
    if (_turns.length >= maxQueuedTurns) {
      return false;
    }
    _turns.add(next);
    return true;
  }

  /// One tick of the simulation.
  void step() {
    if (_isOver) {
      return;
    }
    if (_turns.isNotEmpty) {
      _direction = _turns.removeFirst();
    }

    final Cell next = head.translated(_direction);
    if (next.isOutsideField || _hitsBody(next)) {
      _isOver = true;
      return;
    }

    final bool ate = next == _food;
    _snake.insert(0, next);
    if (ate) {
      _eaten += 1;
      _score += SerpentRules.scoreFor(_eaten);
      _food = _rollFood();
    } else {
      // The tail vacates as the head advances, so the length only grows on an
      // apple.
      _snake.removeLast();
    }
  }

  /// The last segment is moving out of the way this step, so running into it
  /// is not a collision — the prototype's `i < snake.length - 1`.
  bool _hitsBody(Cell candidate) {
    for (int i = 0; i < _snake.length - 1; i++) {
      if (_snake[i] == candidate) {
        return true;
      }
    }
    return false;
  }

  /// A free square, never one the serpent is standing on.
  ///
  /// Rejection sampling, as the prototype does it. A nearly full board makes
  /// that unbounded, so after one board's worth of misses it picks from the
  /// squares that are actually free.
  Cell _rollFood() {
    const int size = SerpentRules.gridSize;
    final int attempts = size * size;
    for (int i = 0; i < attempts; i++) {
      final Cell candidate = Cell(_random.nextInt(size), _random.nextInt(size));
      if (!_snake.contains(candidate)) {
        return candidate;
      }
    }

    final List<Cell> free = <Cell>[
      for (int y = 0; y < size; y++)
        for (int x = 0; x < size; x++)
          if (!_snake.contains(Cell(x, y))) Cell(x, y),
    ];
    // A full board has nowhere to put one. Nothing is eaten, nothing moves.
    return free.isEmpty ? _food : free[_random.nextInt(free.length)];
  }
}
