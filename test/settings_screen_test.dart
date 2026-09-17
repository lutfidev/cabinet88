import 'package:cabinet88/main.dart';
import 'package:cabinet88/screens/settings_screen.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/crt_overlay.dart';
import 'package:cabinet88/widgets/pixel_sprite.dart';
import 'package:cabinet88/widgets/pixel_toggle.dart';
import 'package:cabinet88/widgets/settings_row.dart';
import 'package:cabinet88/widgets/sprite_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsService> _loaded([Map<String, Object> stored = const <String, Object>{}]) async {
  SharedPreferences.setMockInitialValues(stored);
  final SettingsService settings = SettingsService();
  await settings.load();
  return settings;
}

/// Progress for the whole-app tests. Empty — none of them plays anything.
Future<ProgressService> _progress() async {
  final ProgressService progress = ProgressService();
  await progress.load();
  return progress;
}

Future<SettingsService> _pumpSettings(WidgetTester tester) async {
  final SettingsService settings = await _loaded();
  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsService>.value(
      value: settings,
      child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}

/// The track colour of the nth toggle on screen.
Color _trackColour(WidgetTester tester, int index) {
  final Finder toggle = find.byType(PixelToggle).at(index);
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: toggle, matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  testWidgets('the screen shows the design\'s four switches, in its order',
      (WidgetTester tester) async {
    await _pumpSettings(tester);

    expect(find.text('CABINET SETTINGS'), findsOneWidget);
    expect(find.byType(SettingsRow), findsNWidgets(AppSetting.values.length));
    expect(find.text('CRT scanlines'), findsOneWidget);
    expect(find.text('Softer glow, authentic curve'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
    expect(find.text('Cabinet ambience'), findsOneWidget);
    expect(find.text('On-screen D-pad'), findsOneWidget);
    expect(find.text('Otherwise swipe controls only'), findsOneWidget);
  });

  testWidgets('a switch reads its state, and tapping the row writes it',
      (WidgetTester tester) async {
    final SettingsService settings = await _pumpSettings(tester);

    // CRT is on by default, ambience is off.
    expect(_trackColour(tester, 0), AppColors.accentPrimary);
    expect(_trackColour(tester, 2), AppColors.surfaceToggleOff);

    await tester.tap(find.text('CRT scanlines'));
    await tester.pumpAndSettle();

    expect(settings.crtScanlines, isFalse);
    expect(_trackColour(tester, 0), AppColors.surfaceToggleOff);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(AppSetting.crtScanlines.storageKey), isFalse);
  });

  testWidgets('the CRT overlay follows the switch, with no restart',
      (WidgetTester tester) async {
    final SettingsService settings = await _loaded();
    await tester.pumpWidget(
      Cabinet88App(settings: settings, progress: await _progress()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(CrtOverlay.scanlineKey), findsOneWidget);

    await settings.setValue(AppSetting.crtScanlines, false);
    await tester.pump();
    expect(find.byKey(CrtOverlay.scanlineKey), findsNothing);

    await settings.setValue(AppSetting.crtScanlines, true);
    await tester.pump();
    expect(find.byKey(CrtOverlay.scanlineKey), findsOneWidget);
  });

  testWidgets('a stored-off scanline setting is honoured on the first frame',
      (WidgetTester tester) async {
    final SettingsService settings = await _loaded(<String, Object>{
      AppSetting.crtScanlines.storageKey: false,
    });
    await tester.pumpWidget(
      Cabinet88App(settings: settings, progress: await _progress()),
    );

    // Before any settling: nothing flickers on, not even for one frame.
    expect(find.byKey(CrtOverlay.scanlineKey), findsNothing);
  });

  testWidgets('the home avatar opens settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      Cabinet88App(settings: await _loaded(), progress: await _progress()),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is PixelSprite && widget.spriteId == SpriteMaps.avatar,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('CABINET SETTINGS'), findsOneWidget);
  });
}
