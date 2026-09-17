import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../games/arcade_game.dart';
import '../games/game_catalog.dart';
import '../games/placeholder_game.dart';
import '../models/cabinet.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/play/demo_mode.dart';
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
/// about any particular game: what it draws in the viewport comes from the
/// [ArcadeGame] it was handed, and which game that is comes from
/// [GameCatalog]. A cabinet with no game gets demo mode instead of a field.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.cabinet, this.game});

  final Cabinet cabinet;

  /// An injected game, for a test that needs a predictable one. Left null,
  /// the shell asks [GameCatalog] for this cabinet's game and owns what it
  /// gets back.
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
  /// This cabinet's game, or the phase machine behind the test pattern when
  /// this build ships none for it.
  late final ArcadeGame _game = widget.game ??
      GameCatalog.createFor(widget.cabinet) ??
      PlaceholderGame();

  /// Only a game the shell made is a game the shell may dispose.
  late final bool _ownsGame = widget.game == null;

  late final CustomPainter _painter = _game.createPainter();
  late final Ticker _ticker = createTicker(_game.tick);
  late final ProgressService _progress = context.read<ProgressService>();

  /// The nine cabinets with no game take no input — otherwise an arrow key
  /// would file a run against a cabinet that cannot be played.
  bool get _isDemo => !widget.cabinet.playable;

  GamePhase _lastPhase = GamePhase.attract;
  Offset? _swipeOrigin;

  @override
  void initState() {
    super.initState();
    // Every launch of the play screen starts at the attract state. Fixed
    // behaviour, per the design notes — not a preference.
    _game.reset();
    _game.status.addListener(_followRun);
  }

  @override
  void dispose() {
    _game.status.removeListener(_followRun);
    _ticker.dispose();
    if (_ownsGame) {
      _game.dispose();
    }
    super.dispose();
  }

  /// The ticker runs while a run is live and at no other time, so a paused or
  /// finished cabinet costs nothing. The same signal files progress: a run
  /// that starts marks the cabinet played, and a run that ends offers its
  /// score to the best.
  void _followRun() {
    final GameStatus status = _game.status.value;

    final bool shouldTick = status.phase == GamePhase.playing;
    if (shouldTick && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldTick && _ticker.isActive) {
      _ticker.stop();
    }

    if (status.phase == _lastPhase) {
      return;
    }
    final GamePhase previous = _lastPhase;
    _lastPhase = status.phase;

    if (status.phase == GamePhase.playing && previous != GamePhase.paused) {
      _progress.recordPlayed(widget.cabinet.id);
    } else if (status.phase == GamePhase.over) {
      _progress.recordScore(widget.cabinet.id, status.score);
    }
  }

  /// A direction from any control. Before a run starts, the first one starts
  /// it — the design's own `turn()` does the same, which is what makes the
  /// idle note ("swipe, tap the D-pad, or press an arrow key to begin") true.
  void _handleInput(GameInput input) {
    if (_isDemo) {
      return;
    }
    if (_game.status.value.phase.isRunning) {
      _game.input(input);
    } else {
      _game.start();
    }
  }

  /// The action button and every overlay call to action: resume a paused run,
  /// otherwise begin a fresh one.
  void _handleAction() {
    if (_isDemo) {
      return;
    }
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

  /// Demo mode's way out: swap this cabinet for the one that plays.
  void _openPlayable() => Navigator.of(context)
      .pushReplacement(PlayScreen.route(GameCatalog.playableCabinet));

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _isDemo) {
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
    // The HI readout is the player's own best, not the catalog's seeded one:
    // a cabinet nobody has scored on shows a dash.
    final int best = context.select<ProgressService, int>(
        (ProgressService p) => p.bestFor(widget.cabinet.id));

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
                    best: Cabinet.scoreLabel(best),
                  ),
                  Expanded(
                    child: _isDemo
                        ? SingleChildScrollView(
                            child: DemoMode(
                              cabinet: widget.cabinet,
                              playable: GameCatalog.playableCabinet,
                              onTryPlayable: _openPlayable,
                            ),
                          )
                        : _PlayBody(
                            painter: _painter,
                            overlay: _overlayFor(status),
                            showDpad: showDpad,
                            actionLabel:
                                status.phase.isRunning ? _reset : _start,
                            onPointerDown: _onPointerDown,
                            onPointerUp: _onPointerUp,
                            onDirection: _handleInput,
                            onAction: _handleAction,
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
}

/// The field, the controls and the footer — what a cabinet with a game shows.
class _PlayBody extends StatelessWidget {
  const _PlayBody({
    required this.painter,
    required this.overlay,
    required this.showDpad,
    required this.actionLabel,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onDirection,
    required this.onAction,
  });

  final CustomPainter painter;
  final Widget? overlay;
  final bool showDpad;
  final String actionLabel;
  final PointerDownEventListener onPointerDown;
  final PointerUpEventListener onPointerUp;
  final ValueChanged<GameInput> onDirection;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.playBody,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Listener(
                  onPointerDown: onPointerDown,
                  onPointerUp: onPointerUp,
                  child: PlayField(painter: painter, overlay: overlay),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s18),
          PlayControls(
            showDpad: showDpad,
            actionLabel: actionLabel,
            onDirection: onDirection,
            onAction: onAction,
          ),
          const SizedBox(height: AppSpacing.s18),
          Text(
            _footer,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}
