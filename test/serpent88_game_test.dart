import 'dart:math';

import 'package:cabinet88/games/arcade_game.dart';
import 'package:cabinet88/games/serpent88/serpent88_game.dart';
import 'package:cabinet88/games/serpent88/serpent_engine.dart';
import 'package:cabinet88/games/serpent88/serpent_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every apple in the top-left corner, so two games given the same inputs
/// play the same run.
class _CornerRandom implements Random {
  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

Serpent88Game _game() =>
    Serpent88Game(engine: SerpentEngine(random: _CornerRandom()));

/// Runs a game's clock the way a ticker would: a steady frame, over and over,
/// with [elapsed] counting from when the ticker started.
void _runClock(
  Serpent88Game game, {
  required Duration frame,
  required Duration total,
}) {
  for (Duration at = Duration.zero; at <= total; at += frame) {
    game.tick(at);
  }
}

void main() {
  test('the clock is fixed: 60Hz and 120Hz play the same run', () {
    final Serpent88Game sixty = _game()..start();
    final Serpent88Game oneTwenty = _game()..start();
    addTearDown(sixty.dispose);
    addTearDown(oneTwenty.dispose);

    const Duration second = Duration(seconds: 1);
    _runClock(sixty, frame: const Duration(milliseconds: 16), total: second);
    _runClock(oneTwenty, frame: const Duration(milliseconds: 8), total: second);

    expect(sixty.status.value, oneTwenty.status.value);
    // One second is four steps to the apple and three more after it.
    expect(sixty.status.value.score, 11);
    expect(sixty.status.value.phase, GamePhase.playing);
  });

  test('a stalled frame is dropped, not replayed', () {
    final Serpent88Game game = _game()..start();
    addTearDown(game.dispose);

    game.tick(Duration.zero);
    // A whole second in one frame: the catch-up cap allows 200ms of it, which
    // is one step and change, never seven.
    game.tick(const Duration(seconds: 1));

    expect(game.status.value.score, 0);
    expect(game.status.value.phase, GamePhase.playing);
  });

  test('pausing stops the simulation, and resuming does not teleport', () {
    final Serpent88Game game = _game()..start();
    addTearDown(game.dispose);

    _runClock(
      game,
      frame: const Duration(milliseconds: 16),
      total: const Duration(milliseconds: 128),
    );
    expect(game.status.value.phase, GamePhase.playing);

    game.pause();
    expect(game.status.value.phase, GamePhase.paused);
    // Ticks arriving while paused change nothing.
    game.tick(const Duration(seconds: 5));
    expect(game.status.value.score, 0);

    game.resume();
    // The shell's ticker restarts from zero after a pause, and the game takes
    // that as its new origin rather than reading it as five seconds owed.
    _runClock(
      game,
      frame: const Duration(milliseconds: 16),
      total: const Duration(milliseconds: 96),
    );
    expect(game.status.value.phase, GamePhase.playing);
    expect(game.status.value.score, 0);
  });

  test('the HUD gets the score, the level and the end of the run', () {
    final Serpent88Game game = _game()..start();
    addTearDown(game.dispose);

    final List<GameStatus> published = <GameStatus>[];
    game.status.addListener(() => published.add(game.status.value));

    _runClock(
      game,
      frame: const Duration(milliseconds: 16),
      total: const Duration(seconds: 2),
    );

    expect(game.status.value.phase, GamePhase.over);
    expect(game.status.value.score, 11);
    expect(game.status.value.level, 1);
    // The HUD is told when a number changes, not once a frame.
    expect(published.length, lessThan(5));
  });

  test('input turns the serpent, and only while a run exists', () {
    final SerpentEngine engine = SerpentEngine(random: _CornerRandom());
    final Serpent88Game game = Serpent88Game(engine: engine);
    addTearDown(game.dispose);

    game.input(GameInput.up);
    expect(engine.direction, SerpentRules.startDirection);

    game.start();
    game.input(GameInput.up);
    _runClock(
      game,
      frame: const Duration(milliseconds: 16),
      total: const Duration(milliseconds: 160),
    );

    expect(engine.direction, Direction.up);
    expect(engine.head, const Cell(8, 7));
  });

  test('reset puts the cabinet back to attract', () {
    final Serpent88Game game = _game()..start();
    addTearDown(game.dispose);

    _runClock(
      game,
      frame: const Duration(milliseconds: 16),
      total: const Duration(seconds: 1),
    );
    expect(game.status.value.score, 11);

    game.reset();

    expect(game.status.value, const GameStatus());
    expect(game.status.value.phase, GamePhase.attract);
  });
}
