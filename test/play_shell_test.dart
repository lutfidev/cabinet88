import 'dart:math';

import 'package:cabinet88/games/serpent88/serpent88_game.dart';
import 'package:cabinet88/games/serpent88/serpent_engine.dart';
import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/services/audio_service.dart';
import 'package:cabinet88/services/haptic_service.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/play/demo_mode.dart';
import 'package:cabinet88/widgets/play/play_controls.dart';
import 'package:cabinet88/widgets/play/play_field.dart';
import 'package:cabinet88/widgets/play/play_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Cabinet get _serpent => CabinetCatalog.byId(CabinetCatalog.serpentId);
Cabinet get _minefield => CabinetCatalog.byId('minefield');

/// Every apple lands on (0,0), so a run is the same every time it is played.
class _CornerRandom implements Random {
  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

/// Serpent 88 with a predictable board: from the opening position it eats the
/// apple at (12,8) on the fourth step and runs into the right wall on the
/// eighth, for a score of 11.
Serpent88Game _predictableSerpent() =>
    Serpent88Game(engine: SerpentEngine(random: _CornerRandom()));

/// The sink a shipped audio build would replace. Here it just remembers what
/// the shell asked for.
class _RecordingSink implements AudioSink {
  final List<ArcadeCue> cues = <ArcadeCue>[];
  final List<bool> hum = <bool>[];

  @override
  void play(ArcadeCue cue) => cues.add(cue);

  @override
  void ambience(bool playing) => hum.add(playing);
}

late ProgressService _progress;
late _RecordingSink _audioSink;

/// Every buzz the platform was asked for, in order.
late List<Object?> _buzzes;

/// The buzzes a control press makes, filtered out of [_buzzes] where a test
/// only cares about what the run itself did.
List<Object?> get _runBuzzes => _buzzes
    .where((Object? buzz) => buzz != 'HapticFeedbackType.selectionClick')
    .toList();

Future<void> _pumpPlay(
  WidgetTester tester, {
  Cabinet? cabinet,
  bool dpad = true,
  bool settle = true,
  Map<String, Object> stored = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppSetting.onScreenDpad.storageKey: dpad,
    ...stored,
  });
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await settings.load();
  await progress.load();
  _progress = progress;

  _buzzes = <Object?>[];
  tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      _buzzes.add(call.arguments);
    }
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));

  _audioSink = _RecordingSink();
  final AudioService audio = AudioService(settings, sink: _audioSink);
  addTearDown(audio.dispose);

  final Cabinet playing = cabinet ?? _serpent;
  // Injected, so the board is the same every run — which also means this test
  // owns it, where the shell would have owned one it made itself.
  final Serpent88Game? game = playing.playable ? _predictableSerpent() : null;
  if (game != null) {
    addTearDown(game.dispose);
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settings),
        ChangeNotifierProvider<ProgressService>.value(value: progress),
        Provider<HapticService>.value(value: HapticService(settings)),
        Provider<AudioService>.value(value: audio),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: PlayScreen(cabinet: playing, game: game),
      ),
    ),
  );
  // Demo mode blinks forever, so only a cabinet with a field can settle.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The call to action inside the overlay, as opposed to the action button,
/// which carries some of the same words.
Finder _overlayCta(String label) =>
    find.descendant(of: find.byType(PlayOverlay), matching: find.text(label));

/// Starts a run. Never settle after this — the shell's ticker is running, and
/// `pumpAndSettle` would wait for a frame that never stops coming.
Future<void> _start(WidgetTester tester) async {
  await tester.tap(_overlayCta('START'));
  await tester.pump();
}

/// Runs the clock at a plausible frame rate. One giant pump would be a single
/// enormous frame, which the game deliberately refuses to catch up on.
Future<void> _advance(
  WidgetTester tester, {
  int frames = 80,
  Duration frame = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(frame);
  }
}

/// Unmounts the shell so its ticker is disposed before the test ends.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  testWidgets('the shell opens in the attract state', (WidgetTester tester) async {
    await _pumpPlay(tester);

    expect(find.byType(PlayOverlay), findsOneWidget);
    // Once on the top bar, once as the overlay's title.
    expect(find.text('SERPENT 88'), findsNWidgets(2));
    expect(
      find.text('Swipe, tap the D-pad, or press an arrow key to begin.'),
      findsOneWidget,
    );
    expect(_overlayCta('START'), findsOneWidget);
    // Action button and overlay call to action both read START before a run.
    expect(find.text('START'), findsNWidgets(2));
    expect(find.text('RESET'), findsNothing);
  });

  testWidgets('the chrome carries the design\'s labels, and HI starts empty',
      (WidgetTester tester) async {
    await _pumpPlay(tester);

    expect(find.text('‹ EXIT'), findsOneWidget);
    expect(find.text('PAUSE'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('HI'), findsOneWidget);
    // Nobody has scored on this install, so there is no best to show.
    expect(find.text('—'), findsOneWidget);
    expect(
      find.text('Swipe the screen, use the D-pad, or arrow keys'),
      findsOneWidget,
    );
  });

  testWidgets('HI reads the stored best', (WidgetTester tester) async {
    await _pumpPlay(
      tester,
      stored: <String, Object>{
        '${ProgressService.bestPrefix}${CabinetCatalog.serpentId}': 24680,
      },
    );

    expect(find.text('24,680'), findsOneWidget);
  });

  testWidgets('starting a run clears the overlay and arms reset',
      (WidgetTester tester) async {
    await _pumpPlay(tester);
    await _start(tester);

    expect(find.byType(PlayOverlay), findsNothing);
    expect(find.text('RESET'), findsOneWidget);

    await _close(tester);
  });

  testWidgets('pause and resume, from the top bar', (WidgetTester tester) async {
    await _pumpPlay(tester);
    await _start(tester);

    await tester.tap(find.text('PAUSE'));
    await tester.pump();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(
      find.text('Take your time. The apple is not going anywhere.'),
      findsOneWidget,
    );
    expect(_overlayCta('RESUME'), findsOneWidget);

    await tester.tap(_overlayCta('RESUME'));
    await tester.pump();

    expect(find.byType(PlayOverlay), findsNothing);
    expect(find.text('PAUSE'), findsOneWidget);

    await _close(tester);
  });

  testWidgets('a run ends at the wall, and the score survives it',
      (WidgetTester tester) async {
    await _pumpPlay(tester);
    await _start(tester);
    await _advance(tester);

    expect(find.text('GAME OVER'), findsOneWidget);
    // One apple at 10 + 1, then the right-hand wall.
    expect(
      find.text('You scored 11. The wall always wins eventually.'),
      findsOneWidget,
    );
    expect(_overlayCta('PLAY AGAIN'), findsOneWidget);
    expect(_progress.bestFor(CabinetCatalog.serpentId), 11);
    expect(_progress.hasPlayed(CabinetCatalog.serpentId), isTrue);

    // The HUD picks the new best up without leaving the screen.
    expect(find.text('11'), findsWidgets);

    await tester.tap(_overlayCta('PLAY AGAIN'));
    await tester.pump();
    expect(find.byType(PlayOverlay), findsNothing);

    await _close(tester);
  });

  testWidgets('an apple and the wall each answer in their own way',
      (WidgetTester tester) async {
    // Sound is off on a fresh install, so a test that wants to watch the cues
    // has to turn it on the way the player would.
    await _pumpPlay(
      tester,
      stored: <String, Object>{AppSetting.cabinetAmbience.storageKey: true},
    );
    await _start(tester);
    await _advance(tester);

    // The run eats once and then dies: one light thud for the apple, one
    // heavier one for the wall, and never the other way round.
    expect(_runBuzzes, <String>[
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
    ]);
    // The shell opened the cabinet, started the run, and named both moments.
    expect(_audioSink.cues, containsAllInOrder(<ArcadeCue>[
      ArcadeCue.runStart,
      ArcadeCue.pickup,
      ArcadeCue.gameOver,
    ]));

    await _close(tester);
  });

  testWidgets('a control answers, a key does not', (WidgetTester tester) async {
    await _pumpPlay(
      tester,
      stored: <String, Object>{AppSetting.cabinetAmbience.storageKey: true},
    );

    await tester.tap(find.text('▲'));
    await tester.pump();
    expect(_buzzes, <String>['HapticFeedbackType.selectionClick']);
    expect(_audioSink.cues.first, ArcadeCue.uiSelect);

    // A keyboard is not a thumb on the glass, so it gets no buzz of its own.
    final int beforeKey = _buzzes.length;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_buzzes.length, beforeKey);

    await _close(tester);
  });

  testWidgets('the switch off leaves the run silent and still',
      (WidgetTester tester) async {
    await _pumpPlay(
      tester,
      stored: <String, Object>{AppSetting.hapticFeedback.storageKey: false},
    );
    await _start(tester);
    await _advance(tester);

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(_buzzes, isEmpty);
    // Sound is off by default too, so nothing reached the sink either.
    expect(_audioSink.cues, isEmpty);
    expect(_audioSink.hum, isEmpty);

    await _close(tester);
  });

  testWidgets('the hum comes up with the cabinet and down with it',
      (WidgetTester tester) async {
    await _pumpPlay(
      tester,
      stored: <String, Object>{AppSetting.cabinetAmbience.storageKey: true},
    );

    expect(_audioSink.hum, <bool>[true]);

    await _close(tester);
    expect(_audioSink.hum, <bool>[true, false]);
  });

  testWidgets('a D-pad press starts the run from attract',
      (WidgetTester tester) async {
    await _pumpPlay(tester);

    await tester.tap(find.text('▲'));
    await tester.pump();

    expect(find.byType(PlayOverlay), findsNothing);

    await _close(tester);
  });

  testWidgets('a swipe across the field starts the run',
      (WidgetTester tester) async {
    await _pumpPlay(tester);

    await tester.drag(find.byType(PlayControls), const Offset(0, -60));
    await tester.pump();
    // The controls are not the field, so that one did nothing.
    expect(find.byType(PlayOverlay), findsOneWidget);

    await tester.drag(find.byType(PlayOverlay), const Offset(60, 0));
    await tester.pump();
    expect(find.byType(PlayOverlay), findsNothing);

    await _close(tester);
  });

  testWidgets('turning the D-pad off leaves the action button',
      (WidgetTester tester) async {
    await _pumpPlay(tester, dpad: false);

    expect(find.text('▲'), findsNothing);
    expect(find.text('◀'), findsNothing);
    expect(find.text('START'), findsNWidgets(2));
  });

  testWidgets('exit pops the shell', (WidgetTester tester) async {
    await _pumpPlay(tester);
    final SettingsService settings = SettingsService();
    await settings.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settings),
          ChangeNotifierProvider<ProgressService>.value(value: _progress),
          Provider<HapticService>.value(value: HapticService(settings)),
          Provider<AudioService>.value(value: AudioService(settings)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    Navigator.of(context).push(PlayScreen.route(_serpent)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayScreen), findsOneWidget);

    await tester.tap(find.text('‹ EXIT'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayScreen), findsNothing);
  });

  testWidgets('the cabinet with a game gets the field, the rest get demo mode',
      (WidgetTester tester) async {
    for (final Cabinet cabinet in CabinetCatalog.all) {
      await _pumpPlay(tester, cabinet: cabinet, settle: cabinet.playable);

      // The chrome is the same for all ten: title on the bar, and the HUD.
      expect(find.text(cabinet.title.toUpperCase()), findsWidgets);
      expect(find.text('SCORE'), findsOneWidget);

      if (cabinet.playable) {
        expect(find.byType(PlayField), findsOneWidget);
        expect(find.byType(DemoMode), findsNothing);
      } else {
        expect(find.byType(DemoMode), findsOneWidget);
        expect(find.byType(PlayField), findsNothing);
        expect(find.text('PRESS START'), findsOneWidget);
        expect(find.text('TRY SERPENT 88'), findsOneWidget);
      }
      await _close(tester);
    }
  });

  testWidgets('demo mode takes no input, and files no run',
      (WidgetTester tester) async {
    await _pumpPlay(tester, cabinet: _minefield, settle: false);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    expect(find.byType(DemoMode), findsOneWidget);
    expect(find.byType(PlayOverlay), findsNothing);
    expect(_progress.hasPlayed(_minefield.id), isFalse);
    expect(_progress.cabinetsPlayed, 0);

    await _close(tester);
  });

  testWidgets('demo mode hands you the cabinet that does play',
      (WidgetTester tester) async {
    await _pumpPlay(tester, cabinet: _minefield, settle: false);

    // The call to action sits below the fold on a short viewport, which is
    // what the scroll wrapper is there for.
    await tester.ensureVisible(find.text('TRY SERPENT 88'));
    await tester.pump();
    await tester.tap(find.text('TRY SERPENT 88'));
    // Not pumpAndSettle: the outgoing demo screen is still blinking.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DemoMode), findsNothing);
    expect(find.byType(PlayField), findsOneWidget);
    expect(
      tester.widget<PlayScreen>(find.byType(PlayScreen)).cabinet.id,
      CabinetCatalog.serpentId,
    );

    await _close(tester);
  });
}
