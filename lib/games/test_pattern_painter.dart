import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';

/// The static test pattern the shell shows when no game is attached.
///
/// An empty board at the design's geometry — 16x16 cells on a 17px pitch, each
/// inset 1px — scaled to whatever square the field gives it. Nothing here
/// moves, and nothing here knows a rule: phase 4 ships no game logic.
class TestPatternPainter extends CustomPainter {
  const TestPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / (AppSizes.boardCells * AppSizes.boardPitch);
    final double pitch = AppSizes.boardPitch * scale;
    final double inset = AppSizes.boardCellInset * scale;
    final Radius radius = Radius.circular(AppRadii.cell.x * scale);
    final Paint cell = Paint()..color = AppColors.boardCell;

    for (int row = 0; row < AppSizes.boardCells; row++) {
      for (int column = 0; column < AppSizes.boardCells; column++) {
        final Rect bounds = Rect.fromLTWH(
          column * pitch + inset,
          row * pitch + inset,
          pitch - inset * 2,
          pitch - inset * 2,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(bounds, radius), cell);
      }
    }
  }

  /// Static by definition. The field repaints it only when it changes size.
  @override
  bool shouldRepaint(TestPatternPainter oldDelegate) => false;
}
