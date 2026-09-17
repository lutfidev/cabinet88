import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/play/play_controls.dart';
import 'package:cabinet88/widgets/play/play_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Cabinet get _serpent => CabinetCatalog.all.first;

Future<void> _pumpPlay(
  WidgetTester tester, {
  Cabinet? cabinet,
  bool dpad = true,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppSetting.onScreenDpad.storageKey: dpad,
  });
  final SettingsService settings = SettingsService();
  await settings.load();

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsService>.value(
      value: settings,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: PlayScreen(cabinet: cabinet ?? _serpent),
      ),
    ),
  );
  await tester.pumpAndSettle();
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

  testWidgets('the chrome carries the design\'s labels and this cabinet\'s best',
      (WidgetTester tester) async {
    await _pumpPlay(tester);

    expect(find.text('‹ EXIT'), findsOneWidget);
    expect(find.text('PAUSE'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('HI'), findsOneWidget);
    expect(find.text('24,680'), findsOneWidget);
    expect(
      find.text('Swipe the screen, use the D-pad, or arrow keys'),
      findsOneWidget,
    );
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

  testWidgets('a long press on the action button ends the run',
      (WidgetTester tester) async {
    await _pumpPlay(tester);
    await _start(tester);

    await tester.longPress(find.text('RESET'));
    await tester.pumpAndSettle();

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(
      find.text('You scored 0. The wall always wins eventually.'),
      findsOneWidget,
    );
    expect(_overlayCta('PLAY AGAIN'), findsOneWidget);

    // And PLAY AGAIN starts another one.
    await tester.tap(_overlayCta('PLAY AGAIN'));
    await tester.pump();
    expect(find.byType(PlayOverlay), findsNothing);

    await _close(tester);
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
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: SettingsService(),
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

  testWidgets('every cabinet gets the same shell', (WidgetTester tester) async {
    for (final Cabinet cabinet in CabinetCatalog.all) {
      await _pumpPlay(tester, cabinet: cabinet);
      expect(find.text(cabinet.title.toUpperCase()), findsNWidgets(2));
      expect(find.byType(PlayOverlay), findsOneWidget);
    }
  });
}
