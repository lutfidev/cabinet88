import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'arcade_game.dart';
import 'test_pattern_painter.dart';

/// The shell's stand-in for a cabinet with no game of its own.
///
/// It moves between phases and nothing else: no rules, no scoring, no clock.
/// [tick] and [input] are deliberately empty. The nine cabinets that have no
/// game show demo mode rather than a field, so in the shipped app this only
/// keeps the HUD supplied; a game arriving for one of them replaces it.
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

  @override
  void dispose() => _status.dispose();
}
