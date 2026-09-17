import 'package:flutter/rendering.dart';

import '../../theme/app_theme.dart';
import 'serpent_engine.dart';
import 'serpent_rules.dart';

/// Draws whatever the engine's state currently is.
///
/// The geometry is the design's: 16x16 cells on a 17px pitch, each inset 1px,
/// scaled to the square the field hands it. Every colour and every glow comes
/// from the theme — the painter holds no value of its own.
class SerpentPainter extends CustomPainter {
  SerpentPainter({required this.engine, required super.repaint});

  final SerpentEngine engine;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale =
        size.width / (AppSizes.boardCells * AppSizes.boardPitch);
    final double pitch = AppSizes.boardPitch * scale;
    final double inset = AppSizes.boardCellInset * scale;
    final double side = pitch - inset * 2;
    final Radius radius = Radius.circular(AppRadii.cell.x * scale);

    Rect rectFor(Cell cell) => Rect.fromLTWH(
          cell.x * pitch + inset,
          cell.y * pitch + inset,
          side,
          side,
        );

    final Paint empty = Paint()..color = AppColors.boardCell;
    for (int y = 0; y < SerpentRules.gridSize; y++) {
      for (int x = 0; x < SerpentRules.gridSize; x++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rectFor(Cell(x, y)), radius),
          empty,
        );
      }
    }

    // The apple first, so a head arriving on the same square covers it rather
    // than the other way round.
    final Rect foodRect = rectFor(engine.food);
    final BoxShadow foodGlow = AppShadows.boardFoodGlow.first;
    canvas.drawCircle(
      foodRect.center,
      side / 2,
      _glowPaint(foodGlow, scale),
    );
    // The design draws the pellet at `border-radius:50%` — a disc, where every
    // other cell is a rounded square.
    canvas.drawCircle(
      foodRect.center,
      side / 2,
      Paint()..color = AppColors.boardFood,
    );

    final List<Cell> snake = engine.snake;
    final Paint body = Paint()..color = AppColors.boardBody;
    for (int i = 1; i < snake.length; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(rectFor(snake[i]), radius), body);
    }

    final RRect headRect =
        RRect.fromRectAndRadius(rectFor(snake.first), radius);
    canvas.drawRRect(
      headRect,
      _glowPaint(AppShadows.boardHeadGlow.first, scale),
    );
    canvas.drawRRect(headRect, Paint()..color = AppColors.boardHead);
  }

  /// A CSS `0 0 {blur}px {colour}` glow: one blurred pass of the shape under
  /// the solid one, scaled with the board so it holds its proportion.
  Paint _glowPaint(BoxShadow shadow, double scale) => Paint()
    ..color = shadow.color
    ..maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      Shadow.convertRadiusToSigma(shadow.blurRadius * scale),
    );

  /// The engine's own repaint signal drives every frame, so the delegate never
  /// needs replacing. A size change repaints on its own.
  @override
  bool shouldRepaint(SerpentPainter oldDelegate) => false;
}
