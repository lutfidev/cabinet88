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
import 'package:cabinet88/widgets/cabinet_tile.dart';
import 'package:cabinet88/widgets/play/play_field.dart';
import 'package:cabinet88/widgets/play/play_hud.dart';
import 'package:cabinet88/widgets/play/play_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The frame the design was drawn against, and the smallest phone the app is
/// still expected to hold together on.
const Size _designFrame = Size(412, 892);
const Size _smallFrame = Size(320, 640);

/// As far as Android's own font-size setting goes.
const double _systemMax = 2.0;

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

/// Puts the tester on [frame] with the player's font-size setting at [scale].
void _at(WidgetTester tester, Size frame, double scale) {
  tester.view.physicalSize = frame;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// An overflow is reported as an exception, so a screen that survives a scale
/// is a screen that leaves nothing behind.
void _expectNoOverflow(WidgetTester tester, String where) {
  expect(tester.takeException(), isNull, reason: where);
}

/// What the type under [finder] is actually being scaled by.
double _liveScale(WidgetTester tester, Finder finder) =>
    MediaQuery.textScalerOf(tester.element(finder)).scale(10) / 10;

void main() {
  for (final Size frame in <Size>[_designFrame, _smallFrame]) {
    final String on = 'on ${frame.width.toInt()}x${frame.height.toInt()}';

    testWidgets('home holds at the system maximum $on', (WidgetTester tester) async {
      _at(tester, frame, _systemMax);
      await tester.pumpWidget(await _harness(const HomeScreen()));
      await tester.pumpAndSettle();

      _expectNoOverflow(tester, 'home $on');
    });

    testWidgets('the cabinet file holds at the system maximum, every tab $on',
        (WidgetTester tester) async {
      _at(tester, frame, _systemMax);
      await tester.pumpWidget(await _harness(CabinetDetailScreen(cabinet: _serpent)));
      await tester.pumpAndSettle();
      _expectNoOverflow(tester, 'overview $on');

      for (final String tab in <String>['Scores', 'Trophies']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        _expectNoOverflow(tester, '$tab $on');
      }
    });

    testWidgets('settings holds at the system maximum $on', (WidgetTester tester) async {
      _at(tester, frame, _systemMax);
      await tester.pumpWidget(await _harness(const SettingsScreen()));
      await tester.pumpAndSettle();

      _expectNoOverflow(tester, 'settings $on');
    });

    testWidgets('the play shell holds at the system maximum $on',
        (WidgetTester tester) async {
      _at(tester, frame, _systemMax);
      await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
      await tester.pump(const Duration(milliseconds: 400));

      _expectNoOverflow(tester, 'play $on');
    });

    testWidgets('demo mode holds at the system maximum $on', (WidgetTester tester) async {
      _at(tester, frame, _systemMax);
      await tester.pumpWidget(await _harness(PlayScreen(cabinet: _minefield)));
      await tester.pump(const Duration(milliseconds: 400));

      _expectNoOverflow(tester, 'demo $on');
    });
  }

  testWidgets('the play shell is the only screen that caps the setting',
      (WidgetTester tester) async {
    _at(tester, _designFrame, _systemMax);

    await tester.pumpWidget(await _harness(const HomeScreen()));
    await tester.pumpAndSettle();
    expect(
      _liveScale(tester, find.byType(CabinetTile).first),
      _systemMax,
      reason: 'home scrolls, so it carries the setting whole',
    );

    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_liveScale(tester, find.byType(PlayHud)), AppTextScale.playCeiling);
  });

  testWidgets('a setting under the ceiling reaches the play shell untouched',
      (WidgetTester tester) async {
    _at(tester, _designFrame, 1.1);
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_liveScale(tester, find.byType(PlayHud)), closeTo(1.1, 0.001));
  });

  testWidgets('the field keeps more room than the D-pad that drives it',
      (WidgetTester tester) async {
    _at(tester, _smallFrame, _systemMax);
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    // The floor the ceiling was derived from: a board smaller than the pad
    // that plays it is not a game any more.
    expect(
      tester.getSize(find.byType(PlayField)).width,
      greaterThanOrEqualTo(AppSizes.playFieldMin),
    );
  });

  testWidgets('the play top bar elides its title rather than overflowing',
      (WidgetTester tester) async {
    _at(tester, _smallFrame, _systemMax);
    await tester.pumpWidget(await _harness(PlayScreen(cabinet: _serpent)));
    await tester.pump(const Duration(milliseconds: 400));

    _expectNoOverflow(tester, 'top bar');
    expect(tester.getSize(find.byType(PlayTopBar)).width, _smallFrame.width);

    final Text title = tester.widget<Text>(
      find.descendant(
        of: find.byType(PlayTopBar),
        matching: find.text(_serpent.title.toUpperCase()),
      ),
    );
    expect(title.overflow, TextOverflow.ellipsis);
    expect(title.maxLines, 1);
  });
}
