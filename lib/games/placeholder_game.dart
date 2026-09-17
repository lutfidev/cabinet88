import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'arcade_game.dart';
import 'test_pattern_painter.dart';

/// The shell's stand-in until a cabinet brings a real game.
///
/// It moves between phases and nothing else: no rules, no scoring, no clock.
/// [tick] and [input] are deliberately empty — phase 4 ships no game logic, and
/// the viewport shows a static test pattern.
class PlaceholderGame implements ArcadeGame {
  final ValueNotifier<GameStatus> _status =
      ValueNotifier<GameStatus>(const GameStatus());

  @override
  ValueListenable<GameStatus> get status => _status;

  /// The pattern is static, so the painter carries no repaint signal at all.
  @override
  CustomPainter createPainter() => const TestPatternPainter();

  @override
  void start() => _status.value = const GameStatus(phase: GamePhase.playing);

  @override
  void tick(Duration elapsed) {}

  @override
  void input(GameInput input) {}

  @override
  void pause() {
    if (_status.value.phase == GamePhase.playing) {
      _status.value = _status.value.copyWith(phase: GamePhase.paused);
    }
  }

  @override
  void resume() {
    if (_status.value.phase == GamePhase.paused) {
      _status.value = _status.value.copyWith(phase: GamePhase.playing);
    }
  }

  @override
  void reset() => _status.value = const GameStatus();

  /// Ends the run so the game-over state can be inspected without a game to
  /// lose. The shell reaches this from a long press on the action button, and
  /// only while the placeholder is what is attached — phase 5 deletes both.
  void endRun() {
    if (_status.value.phase.isRunning) {
      _status.value = _status.value.copyWith(phase: GamePhase.over);
    }
  }

  @override
  void dispose() => _status.dispose();
}
