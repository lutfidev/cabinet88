import 'package:cabinet88/main.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/screens/cabinet_detail_screen.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/cabinet_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app reads settings and progress before the first frame, so a test has
/// to hand it loaded services just as `main()` does.
Future<Cabinet88App> _app() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await settings.load();
  await progress.load();
  return Cabinet88App(settings: settings, progress: progress);
}

void main() {
  testWidgets('app builds on the dark cabinet theme', (WidgetTester tester) async {
    await tester.pumpWidget(await _app());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Cabinet88');
    expect(app.theme?.brightness, Brightness.dark);
    expect(app.theme?.scaffoldBackgroundColor, AppColors.background);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('home lists every cabinet in the catalog', (WidgetTester tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    expect(find.byType(CabinetTile), findsNWidgets(CabinetCatalog.all.length));
    expect(find.text('ALL CABINETS'), findsOneWidget);
    expect(find.widgetWithText(CabinetTile, 'Twenty48'), findsOneWidget);
  });

  testWidgets('a cabinet with no score shows a dash', (WidgetTester tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    final Finder minefield = find.widgetWithText(CabinetTile, 'Minefield');
    expect(find.descendant(of: minefield, matching: find.text('—')), findsOneWidget);
  });

  testWidgets('tapping a row opens that cabinet and back returns', (WidgetTester tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CabinetTile, 'Serpent 88'));
    await tester.pumpAndSettle();

    final CabinetDetailScreen detail =
        tester.widget<CabinetDetailScreen>(find.byType(CabinetDetailScreen));
    expect(detail.cabinet.id, 'serpent');

    // The detail top bar carries the design's own glyph button, not a
    // Material BackButton, so pageBack() has nothing to find.
    await tester.tap(find.text('‹'));
    await tester.pumpAndSettle();
    expect(find.byType(CabinetDetailScreen), findsNothing);
    expect(find.byType(CabinetTile), findsNWidgets(CabinetCatalog.all.length));
  });
}
