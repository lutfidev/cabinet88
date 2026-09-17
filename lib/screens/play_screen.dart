import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../games/arcade_game.dart';
import '../games/placeholder_game.dart';
import '../models/cabinet.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/play/play_controls.dart';
import '../widgets/play/play_field.dart';
import '../widgets/play/play_hud.dart';
import '../widgets/play/play_overlay.dart';
import '../widgets/play/play_top_bar.dart';

/// Copy, verbatim from the design's play shell.
const String _exit = '‹ EXIT';
const String _pause = 'PAUSE';
const String _resume = 'RESUME';
const String _scoreLabel = 'SCORE';
const String _levelLabel = 'LEVEL';
const String _bestLabel = 'HI';
const String _start = 'START';
const String _reset = 'RESET';
const String _playAgain = 'PLAY AGAIN';
const String _paused = 'PAUSED';
const String _gameOver = 'GAME OVER';
const String _idleNote = 'Swipe, tap the D-pad, or press an arrow key to begin.';
const String _pausedNote = 'Take your time. The apple is not going anywhere.';
const String _footer = 'Swipe the screen, use the D-pad, or arrow keys';

String _overNote(int score) =>
    'You scored ${Cabinet.formatScore(score)}. The wall always wins eventually.';

/// Keys the shell accepts, from design-tokens section 12: arrows and WASD.
final Map<LogicalKeyboardKey, GameInput> _keyMap = <LogicalKeyboardKey, GameInput>{
  LogicalKeyboardKey.arrowUp: GameInput.up,
  LogicalKeyboardKey.arrowDown: GameInput.down,
  LogicalKeyboardKey.arrowLeft: GameInput.left,
  LogicalKeyboardKey.arrowRight: GameInput.right,
  LogicalKeyboardKey.keyW: GameInput.up,
  LogicalKeyboardKey.keyS: GameInput.down,
  LogicalKeyboardKey.keyA: GameInput.left,
  LogicalKeyboardKey.keyD: GameInput.right,
};

/// The shell all ten cabinets run inside.
///
/// It owns the chrome, the ticker and the input plumbing, and knows nothing
/// about any particular game: everything it draws in the viewport comes from
/// the [ArcadeGame] it was handed. With none, it shows a static test pattern —
/// phase 4 ships no game logic.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.cabinet, this.game});

  final Cabinet cabinet;

  /// The cabinet's game. Null until a cabinet brings one, which is every
  /// cabinet in phase 4.
  final ArcadeGame? game;

  /// The route the detail screen's play button pushes.
  static Route<void> route(Cabinet cabinet, {ArcadeGame? game}) =>
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            PlayScreen(cabinet: cabinet, game: game),
      );

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  late final ArcadeGame _game = widget.game ?? PlaceholderGame();

  /// Only a game the shell made is a game the shell may dispose.
  late final bool _ownsGame = widget.game == null;

  late final CustomPainter _painter = _game.createPainter();
  late final Ticker _ticker = createTicker(_game.tick);

  Offset? _swipeOrigin;

  @override
  void initState() {
    super.initState();
    // Every launch of the play screen starts at the attract state. Fixed
    // behaviour, per the design notes — not a preference.
    _game.reset();
    _game.status.addListener(_followPhase);
  }

  @override
  void dispose() {
    _game.status.removeListener(_followPhase);
    _ticker.dispose();
    if (_ownsGame) {
      _game.dispose();
    }
    super.dispose();
  }

  /// The ticker runs while a run is live and at no other time, so a paused or
  /// finished cabinet costs nothing.
  void _followPhase() {
    final bool shouldTick = _game.status.value.phase == GamePhase.playing;
    if (shouldTick && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldTick && _ticker.isActive) {
      _ticker.stop();
    }
  }

  /// A direction from any control. Before a run starts, the first one starts
  /// it — the design's own `turn()` does the same, which is what makes the
  /// idle note ("swipe, tap the D-pad, or press an arrow key to begin") true.
  void _handleInput(GameInput input) {
    if (_game.status.value.phase.isRunning) {
      _game.input(input);
    } else {
      _game.start();
    }
  }

  /// The action button and every overlay call to action: resume a paused run,
  /// otherwise begin a fresh one.
  void _handleAction() {
    if (_game.status.value.phase == GamePhase.paused) {
      _game.resume();
    } else {
      _game.start();
    }
  }

  void _togglePause() {
    switch (_game.status.value.phase) {
      case GamePhase.playing:
        _game.pause();
      case GamePhase.paused:
        _game.resume();
      case GamePhase.attract:
      case GamePhase.over:
        break;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final GameInput? input = _keyMap[event.logicalKey];
    if (input == null) {
      return KeyEventResult.ignored;
    }
    _handleInput(input);
    return KeyEventResult.handled;
  }

  void _onPointerDown(PointerDownEvent event) => _swipeOrigin = event.position;

  /// The design's swipe: the dominant axis wins, and anything under 14px is a
  /// tap, not a flick.
  void _onPointerUp(PointerUpEvent event) {
    final Offset? origin = _swipeOrigin;
    _swipeOrigin = null;
    if (origin == null) {
      return;
    }
    final Offset delta = event.position - origin;
    if (delta.dx.abs() < AppSpacing.s14 && delta.dy.abs() < AppSpacing.s14) {
      return;
    }
    if (delta.dx.abs() > delta.dy.abs()) {
      _handleInput(delta.dx > 0 ? GameInput.right : GameInput.left);
    } else {
      _handleInput(delta.dy > 0 ? GameInput.down : GameInput.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDpad = context
        .select<SettingsService, bool>((SettingsService s) => s.onScreenDpad);

    return Scaffold(
      backgroundColor: AppColors.playBackground,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKey,
          child: ValueListenableBuilder<GameStatus>(
            valueListenable: _game.status,
            builder: (BuildContext context, GameStatus status, Widget? child) {
              return Column(
                children: <Widget>[
                  PlayTopBar(
                    exitLabel: _exit,
                    title: widget.cabinet.title.toUpperCase(),
                    pauseLabel:
                        status.phase == GamePhase.paused ? _resume : _pause,
                    onExit: () => Navigator.of(context).maybePop(),
                    onTogglePause: _togglePause,
                  ),
                  PlayHud(
                    scoreLabel: _scoreLabel,
                    score: Cabinet.formatScore(status.score),
                    levelLabel: _levelLabel,
                    level: status.level.toString(),
                    bestLabel: _bestLabel,
                    best: widget.cabinet.highScoreLabel,
                  ),
                  Expanded(
                    child: Padding(
                      padding: AppInsets.playBody,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Listener(
                                  onPointerDown: _onPointerDown,
                                  onPointerUp: _onPointerUp,
                                  child: PlayField(
                                    painter: _painter,
                                    overlay: _overlayFor(status),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s18),
                          PlayControls(
                            showDpad: showDpad,
                            actionLabel:
                                status.phase.isRunning ? _reset : _start,
                            onDirection: _handleInput,
                            onAction: _handleAction,
                            onActionLongPress: _endPlaceholderRun,
                          ),
                          const SizedBox(height: AppSpacing.s18),
                          Text(
                            _footer,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textDisabled),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Everything but a live run gets a panel over the field.
  Widget? _overlayFor(GameStatus status) {
    switch (status.phase) {
      case GamePhase.playing:
        return null;
      case GamePhase.attract:
        return PlayOverlay(
          title: widget.cabinet.title.toUpperCase(),
          titleColor: AppColors.accentHighlight,
          note: _idleNote,
          ctaLabel: _start,
          onCta: _handleAction,
        );
      case GamePhase.paused:
        return PlayOverlay(
          title: _paused,
          titleColor: AppColors.accentHighlight,
          note: _pausedNote,
          ctaLabel: _resume,
          onCta: _handleAction,
        );
      case GamePhase.over:
        return PlayOverlay(
          title: _gameOver,
          titleColor: AppColors.accentDanger,
          note: _overNote(status.score),
          ctaLabel: _playAgain,
          onCta: _handleAction,
        );
    }
  }

  /// Phase 4 only. With no game to lose, a long press on the action button is
  /// the way to see the game-over state. It goes when Serpent 88 lands.
  VoidCallback? get _endPlaceholderRun {
    final ArcadeGame game = _game;
    return game is PlaceholderGame ? game.endRun : null;
  }
}
