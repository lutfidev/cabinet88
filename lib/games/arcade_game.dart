import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Where a run is, at any moment.
///
/// The shell draws an overlay for every phase except [playing], which is what
/// the design's `overlayOn: !running || paused` amounts to.
enum GamePhase {
  /// Nothing has started. Every entry to the play screen begins here.
  attract,
  playing,
  paused,

  /// The run ended. The shell offers `PLAY AGAIN`.
  over;

  /// A run exists, started or paused — the design's `running`.
  bool get isRunning => this == GamePhase.playing || this == GamePhase.paused;
}

/// The four directions the shell can hand a game, from the D-pad, a swipe or
/// an arrow key. What a game does with one is its own business.
enum GameInput { up, down, left, right }

/// Everything the shell's HUD and overlays read.
@immutable
class GameStatus {
  const GameStatus({
    this.phase = GamePhase.attract,
    this.score = 0,
    this.level = 1,
  });

  final GamePhase phase;
  final int score;
  final int level;

  GameStatus copyWith({GamePhase? phase, int? score, int? level}) => GameStatus(
        phase: phase ?? this.phase,
        score: score ?? this.score,
        level: level ?? this.level,
      );

  @override
  bool operator ==(Object other) =>
      other is GameStatus &&
      other.phase == phase &&
      other.score == score &&
      other.level == level;

  @override
  int get hashCode => Object.hash(phase, score, level);
}

/// The contract every cabinet satisfies to run inside the shared play shell.
///
/// The shell owns the [Ticker] and the input plumbing; the game owns the rules
/// and the pixels. Nothing here names a game, and nothing here is Flutter UI
/// beyond the painter the field needs.
///
/// [status] notifies only when a number the HUD shows actually changes; a game
/// that repaints every frame drives its painter from its own signal instead.
/// Wiring the HUD to the frame signal would rebuild it sixty times a second
/// for nothing.
abstract interface class ArcadeGame {
  /// Score, level and phase. Notifies only on a real change.
  ValueListenable<GameStatus> get status;

  /// The painter the play field draws with. Called once when the field mounts.
  ///
  /// The game wires its own repaint signal into the painter
  /// (`CustomPainter(repaint: ...)`); the shell never asks it to repaint.
  CustomPainter createPainter();

  /// Begin a fresh run, from [GamePhase.attract] or [GamePhase.over].
  void start();

  /// Advance the simulation. [elapsed] is the ticker's total elapsed time, so
  /// a game can hold a fixed timestep rather than trusting frame deltas.
  void tick(Duration elapsed);

  /// A direction, from whichever control produced it.
  void input(GameInput input);

  void pause();
  void resume();

  /// Return to [GamePhase.attract], discarding the run.
  void reset();

  void dispose();
}
