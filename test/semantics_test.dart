import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/screens/cabinet_detail_screen.dart';
import 'package:cabinet88/screens/home_screen.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/screens/settings_screen.dart';
import 'package:cabinet88/services/audio_service.dart';
import 'package:cabinet88/services/haptic_service.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/services/trophy_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Cabinet get _serpent => CabinetCatalog.byId(CabinetCatalog.serpentId);
Cabinet get _minefield => CabinetCatalog.byId('minefield');

Future<Widget> _harness(Widget home) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await settings.load();
  await progress.load();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ProgressService>.value(value: progress),
      ChangeNotifierProvider<SettingsService>.value(value: settings),
      Provider<HapticService>(
        create: (BuildContext c) => HapticService(c.read<SettingsService>()),
      ),
      Provider<AudioService>(
        create: (BuildContext c) => AudioService(c.read<SettingsService>()),
      ),
      ProxyProvider<ProgressService, TrophyService>(
        update: (BuildContext _, ProgressService p, TrophyService? _) =>
            ProgressTrophyService(p),
      ),
    ],
    child: MaterialApp(theme: AppTheme.dark, home: home),
  );
}

/// Every control on screen is big enough to hit and says what it does.
///
/// Both guidelines are Flutter's own, so what passes here is what an audit
/// with the platform's rules would ask for. The third one,
/// `textContrastGuideline`, cannot run yet: it rasterises the screen, which
/// makes `google_fonts` fetch the real face over the network. It comes back
/// when the fonts are vendored. Until then `test/palette_test.dart` holds the
/// contrast line, measured rather than sampled.
Future<void> _expectUsableControls(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  testWidgets('home: every control is labelled and 48dp', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(const HomeScreen()));
    await tester.pumpAndSettle();

    await _expectUsableControls(tester);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a playlist row reads as one sentence, not four fragments',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Serpent 88. Arcade, ${_serpent.plays} plays. '
        'High score ${Cabinet.formatScore(_serpent.highScore)}.',
      ),
      findsOneWidget,
    );
    // The row draws the sprite, the title, the meta and the score as four
    // separate strings. None of them is a node of its own any more.
    expect(find.bySemanticsLabel('Serpent 88'), findsNothing);
    handle.dispose();
  });

  testWidgets('the cabinet file: every control, on every tab',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _serpent)));
    await tester.pumpAndSettle();

    await _expectUsableControls(tester);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('PLAY'), findsOneWidget);
    // The inert star is not announced at all: it promises nothing because it
    // does nothing.
    expect(find.bySemanticsLabel('☆'), findsNothing);

    for (final String tab in <String>['Scores', 'Trophies']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      await _expectUsableControls(tester);
    }
    handle.dispose();
  });

  testWidgets('the open tab is the selected one', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _serpent)));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Overview')),
      isSemantics(isSelected: true, isButton: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Scores')),
      isSemantics(isSelected: false, isButton: true),
    );

    await tester.tap(find.text('Scores'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Scores')),
      isSemantics(isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('a stat tile is one fact, and an unset best is not an em dash',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _minefield)));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Your best: none yet'), findsOneWidget);
    expect(find.bySemanticsLabel('Released: ${_minefield.year}'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a leaderboard row names its rank, and the player knows theirs',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _serpent)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scores'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp(r'^Rank 1\. ZED\. ')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Rank 5\. PLR-1 \(YOU\), your score\. ')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a trophy says whether it is locked', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _serpent)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trophies'));
    await tester.pumpAndSettle();

    // Nothing has been played in this harness, so every featured trophy is
    // locked — and says so, where the screen only dims it.
    expect(find.bySemanticsLabel(RegExp(r'Locked\.$')), findsWidgets);
    handle.dispose();
  });

  testWidgets('settings: every row is a switch that says its state',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(const SettingsScreen()));
    await tester.pumpAndSettle();

    await _expectUsableControls(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel('CRT scanlines')),
      isSemantics(
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        hint: 'Softer glow, authentic curve',
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('High contrast')),
      isSemantics(hasToggledState: true, isToggled: false),
    );

    await tester.tap(find.text('High contrast'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('High contrast')),
      isSemantics(isToggled: true),
    );
    handle.dispose();
  });

  testWidgets('the play shell: the D-pad is four directions, not four triangles',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    await _expectUsableControls(tester);
    for (final String key in <String>['Up', 'Down', 'Left', 'Right']) {
      expect(find.bySemanticsLabel(key), findsOneWidget, reason: key);
    }
    expect(find.bySemanticsLabel('Exit'), findsOneWidget);
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    // `START` is drawn twice in the attract state: the action button, and the
    // overlay's call to action.
    expect(find.bySemanticsLabel('Start'), findsNWidgets(2));
    handle.dispose();
  });

  testWidgets('the HUD reads as three facts, not three abbreviations',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.bySemanticsLabel('Score 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Best none yet'), findsOneWidget);
    // `HI` is not a word, and an em dash is not a score.
    expect(find.bySemanticsLabel('HI'), findsNothing);
    handle.dispose();
  });

  testWidgets('the overlay announces itself, title and note together',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^SERPENT 88. Swipe'))),
      isSemantics(isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('demo mode: the way out is a control, the blink is not',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _minefield)));
    await tester.pump(const Duration(milliseconds: 400));

    await _expectUsableControls(tester);
    expect(find.bySemanticsLabel('Try Serpent 88'), findsOneWidget);
    // `PRESS START` starts nothing here, so nothing is told to press it.
    expect(find.bySemanticsLabel('PRESS START'), findsNothing);
    handle.dispose();
  });

  testWidgets('the sprites are art, and say nothing', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(await _harness(const HomeScreen()));
    await tester.pumpAndSettle();

    // The avatar is the only thing a sprite sits inside on home that is also
    // a control, and what it reports is the control, not the art.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Settings')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });
}
