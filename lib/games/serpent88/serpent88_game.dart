import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../arcade_game.dart';
import 'serpent_engine.dart';
import 'serpent_painter.dart';
import 'serpent_rules.dart';

/// Serpent 88, wired into the shared play shell.
///
/// The rules live in [SerpentEngine], which has no Flutter in it at all. This
/// is only the adapter: it holds the clock, publishes what the HUD reads, and
/// tells the painter when something moved.
class Serpent88Game implements ArcadeGame {
  Serpent88Game({SerpentEngine? engine})
      : _engine = engine ?? SerpentEngine();

  /// The shell's four inputs, whatever produced them, as headings.
  static const Map<GameInput, Direction> _headings = <GameInput, Direction>{
    GameInput.up: Direction.up,
    GameInput.down: Direction.down,
    GameInput.left: Direction.left,
    GameInput.right: Direction.right,
  };

  /// The most simulation one frame may catch up on. A stall longer than this
  /// — a resumed app, a blocked frame — loses the time rather than replaying
  /// it, so nobody comes back to a serpent that teleported into a wall.
  static const int _maxCatchUpMicros = 200 * Duration.microsecondsPerMillisecond;

  final SerpentEngine _engine;

  final ValueNotifier<GameStatus> _status =
      ValueNotifier<GameStatus>(const GameStatus());

  /// What the painter listens to. Separate from [status] on purpose: the board
  /// changes every step, the HUD's three numbers do not.
  final _RepaintSignal _frames = _RepaintSignal();

  /// Null until the next tick, which becomes the clock's origin. The shell
  /// stops its ticker on a pause and `Ticker.elapsed` restarts at zero, so the
  /// origin is re-taken rather than trusted across that boundary.
  int? _originMicros;

  /// Simulation time owed, carried between frames. This is what makes the
  /// game run identically at 60Hz and 120Hz: the frame rate decides how often
  /// the debt is paid, never how big a step is.
  int _owedMicros = 0;

  @override
  ValueListenable<GameStatus> get status => _status;

  @override
  CustomPainter createPainter() =>
      SerpentPainter(engine: _engine, repaint: _frames);

  @override
  void start() {
    _engine.start();
    _restartClock();
    _status.value = GameStatus(
      phase: GamePhase.playing,
      score: _engine.score,
      level: _engine.level,
    );
    _frames.fire();
  }

  @override
  void tick(Duration elapsed) {
    if (_status.value.phase != GamePhase.playing) {
      return;
    }

    final int now = elapsed.inMicroseconds;
    final int? origin = _originMicros;
    _originMicros = now;
    if (origin == null || now <= origin) {
      return;
    }

    final int delta = now - origin;
    _owedMicros += delta > _maxCatchUpMicros ? _maxCatchUpMicros : delta;

    bool advanced = false;
    while (true) {
      // Re-read every pass: an apple shortens the step from this moment on.
      final int stepMicros =
          _engine.stepMs * Duration.microsecondsPerMillisecond;
      if (_owedMicros < stepMicros) {
        break;
      }
      _owedMicros -= stepMicros;
      _engine.step();
      advanced = true;
      if (_engine.isOver) {
        _owedMicros = 0;
        break;
      }
    }

    if (!advanced) {
      return;
    }
    _frames.fire();
    _status.value = GameStatus(
      phase: _engine.isOver ? GamePhase.over : GamePhase.playing,
      score: _engine.score,
      level: _engine.level,
    );
  }

  @override
  void input(GameInput input) {
    if (!_status.value.phase.isRunning) {
      return;
    }
    final Direction? heading = _headings[input];
    if (heading != null) {
      _engine.turn(heading);
    }
  }

  @override
  void pause() {
    if (_status.value.phase == GamePhase.playing) {
      _status.value = _status.value.copyWith(phase: GamePhase.paused);
    }
  }

  @override
  void resume() {
    if (_status.value.phase == GamePhase.paused) {
      _restartClock();
      _status.value = _status.value.copyWith(phase: GamePhase.playing);
    }
  }

  @override
  void reset() {
    _engine.start();
    _restartClock();
    _status.value = const GameStatus();
    _frames.fire();
  }

  void _restartClock() {
    _originMicros = null;
    _owedMicros = 0;
  }

  @override
  void dispose() {
    _status.dispose();
    _frames.dispose();
  }
}

/// A [Listenable] with nothing in it: the painter only needs to be told that
/// the board moved, never what changed.
class _RepaintSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}
