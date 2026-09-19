import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/touch_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A control the design draws under the platform minimum: the play pill's
/// height, near enough.
const Size _small = Size(60, 38);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  testWidgets('a small control keeps its drawn size and gains a 48dp box',
      (WidgetTester tester) async {
    await _pump(
      tester,
      TouchTarget(
        child: SizedBox.fromSize(size: _small, child: const ColoredBox(color: Color(0xFF00FF00))),
      ),
    );

    expect(tester.getSize(find.byType(TouchTarget)).height, AppSizes.minTouchTarget);
    expect(tester.getSize(find.byType(TouchTarget)).width, _small.width);
    // What is drawn has not moved a pixel.
    expect(tester.getSize(find.byType(SizedBox).last), _small);
  });

  testWidgets('a control already over the minimum is left alone',
      (WidgetTester tester) async {
    const Size large = Size(72, 72);
    await _pump(
      tester,
      TouchTarget(child: SizedBox.fromSize(size: large)),
    );

    expect(tester.getSize(find.byType(TouchTarget)), large);
  });

  testWidgets('a tap in the margin reaches the control', (WidgetTester tester) async {
    int taps = 0;
    await _pump(
      tester,
      TouchTarget(
        child: GestureDetector(
          onTap: () => taps++,
          behavior: HitTestBehavior.opaque,
          child: SizedBox.fromSize(size: _small),
        ),
      ),
    );

    final Rect box = tester.getRect(find.byType(TouchTarget));
    final Rect drawn = tester.getRect(find.byType(GestureDetector));

    // Four pixels above the drawn control: inside the target, outside the
    // thing it wraps.
    final Offset margin = Offset(box.center.dx, drawn.top - 4);
    expect(box.contains(margin), isTrue);
    expect(drawn.contains(margin), isFalse);

    await tester.tapAt(margin);
    await tester.pump();
    expect(taps, 1);

    await tester.tapAt(drawn.center);
    await tester.pump();
    expect(taps, 2);
  });
}
