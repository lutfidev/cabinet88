import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/models/leaderboard_entry.dart';
import 'package:cabinet88/models/trophy.dart';
import 'package:cabinet88/screens/cabinet_detail_screen.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/services/audio_service.dart';
import 'package:cabinet88/services/haptic_service.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/services/trophy_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/detail_header_card.dart';
import 'package:cabinet88/widgets/layouts/tabbed_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service with everything unlocked, to prove the rows follow the service
/// and nothing else.
class _AllUnlockedTrophyService implements TrophyService {
  const _AllUnlockedTrophyService();

  @override
  bool isUnlocked(Trophy trophy) => true;
}

Cabinet get _serpent => CabinetCatalog.all.first;
Cabinet get _minefield =>
    CabinetCatalog.all.firstWhere((Cabinet c) => c.id == 'minefield');

/// Pumps the cabinet file. [stored] seeds progress, which is where both the
/// best score and every trophy now come from; [service] overrides the derived
/// trophy service where a test needs a fixed answer.
Future<void> _pumpDetail(
  WidgetTester tester,
  Cabinet cabinet, {
  TrophyService? service,
  Map<String, Object> stored = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(stored);
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await settings.load();
  await progress.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressService>.value(value: progress),
        Provider<TrophyService>.value(
          value: service ?? ProgressTrophyService(progress),
        ),
        ChangeNotifierProvider<SettingsService>.value(value: settings),
        // The play button routes into the shell, which reads both of these.
        Provider<HapticService>.value(value: HapticService(settings)),
        Provider<AudioService>.value(value: AudioService(settings)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: CabinetDetailScreen(cabinet: cabinet),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The colour a trophy's glyph is drawn in.
Color? _glyphColor(WidgetTester tester, String glyph) =>
    tester.widget<Text>(find.text(glyph)).style?.color;

/// The opacity the row carrying [name] is drawn at.
double _rowOpacity(WidgetTester tester, String name) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(name), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  testWidgets('the header carries the cabinet and its play action',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);

    expect(find.text('CABINET FILE'), findsOneWidget);
    expect(find.text('☆'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DetailHeaderCard),
        matching: find.text('Serpent 88'),
      ),
      findsOneWidget,
    );
    expect(find.text('Arcade · 1988'), findsOneWidget);
    expect(find.text(DetailHeaderCard.playLabel), findsOneWidget);
  });

  testWidgets('a cabinet without its game reads OPEN CABINET',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _minefield);

    expect(find.text(DetailHeaderCard.openLabel), findsOneWidget);
    expect(find.text(DetailHeaderCard.playLabel), findsNothing);
  });

  testWidgets('the play button routes to the play screen',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);

    await tester.tap(find.text(DetailHeaderCard.playLabel));
    await tester.pumpAndSettle();

    final PlayScreen play = tester.widget<PlayScreen>(find.byType(PlayScreen));
    expect(play.cabinet.id, 'serpent');
  });

  testWidgets('overview shows the cabinet copy and its three stats',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);

    expect(find.text('${_serpent.blurb} ${_serpent.note}'), findsOneWidget);
    expect(find.text('Your best'), findsOneWidget);
    // Nothing has been played, so the stat tile is a dash — the catalog's
    // 24,680 is the leaderboard's mock, not the player's best.
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Runs played'), findsOneWidget);
    expect(find.text('412'), findsOneWidget);
    expect(find.text('Released'), findsOneWidget);
  });

  testWidgets('the three tabs switch', (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);

    int openTab() => tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;
    expect(openTab(), DetailTab.overview.index);

    await tester.tap(find.text(DetailTab.scores.label));
    await tester.pumpAndSettle();
    expect(openTab(), DetailTab.scores.index);

    await tester.tap(find.text(DetailTab.trophies.label));
    await tester.pumpAndSettle();
    expect(openTab(), DetailTab.trophies.index);
  });

  testWidgets('scores builds the board off the cabinet high score',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);
    await tester.tap(find.text(DetailTab.scores.label));
    await tester.pumpAndSettle();

    expect(find.text('01'), findsOneWidget);
    expect(find.text('08'), findsOneWidget);
    expect(find.text(LeaderboardMock.youHandle), findsOneWidget);
    expect(find.text('24,680'), findsWidgets);
  });

  testWidgets('your best reads the score you actually set',
      (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      _serpent,
      stored: <String, Object>{'${ProgressService.bestPrefix}serpent': 1240},
    );

    expect(find.text('1,240'), findsOneWidget);
  });

  testWidgets('both locked and unlocked trophies render',
      (WidgetTester tester) async {
    // One cabinet played, which is exactly what First Coin asks for.
    await _pumpDetail(
      tester,
      _serpent,
      stored: <String, Object>{
        ProgressService.playedKey: <String>['serpent'],
      },
    );
    await tester.tap(find.text(DetailTab.trophies.label));
    await tester.pumpAndSettle();

    expect(find.byType(Opacity), findsNWidgets(TrophyCatalog.featured.length));

    // First Coin is earned; No Guessing belongs to a cabinet with no game.
    expect(_rowOpacity(tester, 'First Coin'), 1);
    expect(_glyphColor(tester, '1'), AppColors.accentHighlight);

    expect(_rowOpacity(tester, 'No Guessing'), AppOpacities.lockedDetail);
    expect(_glyphColor(tester, 'X'), AppPalette.standard.textLocked);
  });

  testWidgets('unlock state follows the service, not the catalog',
      (WidgetTester tester) async {
    // Nothing has been played, so every derived trophy would be locked. The
    // rows follow the service instead.
    await _pumpDetail(
      tester,
      _serpent,
      service: const _AllUnlockedTrophyService(),
    );
    await tester.tap(find.text(DetailTab.trophies.label));
    await tester.pumpAndSettle();

    for (final Trophy trophy in TrophyCatalog.featured) {
      expect(_rowOpacity(tester, trophy.name), 1);
      expect(_glyphColor(tester, trophy.glyph), AppColors.accentHighlight);
    }
  });

  testWidgets('opening the file counts towards Curator',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _pumpDetail(tester, _serpent);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(ProgressService.filesReadKey),
      <String>['serpent'],
    );
  });

  testWidgets('each tab keeps its own scroll position',
      (WidgetTester tester) async {
    // A short viewport, so the eight-row board has somewhere to scroll.
    tester.view.physicalSize = const Size(412, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpDetail(tester, _serpent);
    await tester.tap(find.text(DetailTab.scores.label));
    await tester.pumpAndSettle();

    final Finder scores =
        find.byKey(const PageStorageKey<DetailTab>(DetailTab.scores));
    double offset() => tester
        .state<ScrollableState>(
          find.descendant(of: scores, matching: find.byType(Scrollable)),
        )
        .position
        .pixels;

    await tester.drag(scores, const Offset(0, -60));
    await tester.pumpAndSettle();
    final double scrolled = offset();
    expect(scrolled, greaterThan(0));

    await tester.tap(find.text(DetailTab.overview.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(DetailTab.scores.label));
    await tester.pumpAndSettle();

    expect(offset(), scrolled);
  });

  testWidgets('every cabinet opens a populated file', (WidgetTester tester) async {
    for (final Cabinet cabinet in CabinetCatalog.all) {
      await _pumpDetail(tester, cabinet);

      expect(
        find.descendant(
          of: find.byType(DetailHeaderCard),
          matching: find.text(cabinet.title),
        ),
        findsOneWidget,
        reason: cabinet.id,
      );
      expect(
        find.text('${cabinet.genre.label} · ${cabinet.year}'),
        findsOneWidget,
        reason: cabinet.id,
      );
      expect(find.text('${cabinet.blurb} ${cabinet.note}'), findsOneWidget,
          reason: cabinet.id);
    }
  });
}
