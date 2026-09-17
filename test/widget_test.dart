import 'package:cabinet88/main.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds on the dark cabinet theme', (WidgetTester tester) async {
    await tester.pumpWidget(const Cabinet88App());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Cabinet88');
    expect(app.theme?.brightness, Brightness.dark);
    expect(app.theme?.scaffoldBackgroundColor, AppColors.background);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
