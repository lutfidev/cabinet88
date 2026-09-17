import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/models/leaderboard_entry.dart';
import 'package:cabinet88/models/trophy.dart';
import 'package:cabinet88/screens/cabinet_detail_screen.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/services/trophy_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/detail_header_card.dart';
import 'package:cabinet88/widgets/layouts/tabbed_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service with nothing unlocked, to prove the rows follow the service and
/// not the catalog.
class _AllLockedTrophyService implements TrophyService {
  const _AllLockedTrophyService();

  @override
  bool isUnlocked(Trophy trophy) => false;
}

Cabinet get _serpent => CabinetCatalog.all.first;
Cabinet get _minefield =>
    CabinetCatalog.all.firstWhere((Cabinet c) => c.id == 'minefield');

Future<void> _pumpDetail(
  WidgetTester tester,
  Cabinet cabinet, {
  TrophyService service = const SeededTrophyService(),
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SettingsService settings = SettingsService();
  await settings.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<TrophyService>.value(value: service),
        ChangeNotifierProvider<SettingsService>.value(value: settings),
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
    expect(find.text('24,680'), findsOneWidget);
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

  testWidgets('both locked and unlocked trophies render',
      (WidgetTester tester) async {
    await _pumpDetail(tester, _serpent);
    await tester.tap(find.text(DetailTab.trophies.label));
    await tester.pumpAndSettle();

    expect(find.byType(Opacity), findsNWidgets(TrophyCatalog.featured.length));

    // First Coin is unlocked in the design's mock; No Guessing is not.
    expect(_rowOpacity(tester, 'First Coin'), 1);
    expect(_glyphColor(tester, '1'), AppColors.accentHighlight);

    expect(_rowOpacity(tester, 'No Guessing'), AppOpacities.lockedDetail);
    expect(_glyphColor(tester, 'X'), AppColors.textLocked);
  });

  testWidgets('unlock state follows the service, not the catalog',
      (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      _serpent,
      service: const _AllLockedTrophyService(),
    );
    await tester.tap(find.text(DetailTab.trophies.label));
    await tester.pumpAndSettle();

    for (final Trophy trophy in TrophyCatalog.featured) {
      expect(_rowOpacity(tester, trophy.name), AppOpacities.lockedDetail);
      expect(_glyphColor(tester, trophy.glyph), AppColors.textLocked);
    }
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
