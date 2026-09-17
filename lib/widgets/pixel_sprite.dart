import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'sprite_maps.dart';

/// Draws one 8×8 placeholder sprite at a given pixel scale.
///
/// The single door every sprite goes through (hard rule 6): screens name a
/// sprite and a size, never the art itself.
///
/// [glow] reproduces the design's `drop-shadow(0 0 {px * 1.2}px {hue})` — one
/// blurred pass of the whole silhouette beneath the art, not a halo per cell.
/// Pass null for no glow, which is what the playlist row does.
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.spriteId,
    required this.pixelSize,
    this.glow,
  });

  /// A key into [SpriteMaps.byId]. For a cabinet this is its `Cabinet.id`.
  final String spriteId;

  /// The edge of one sprite pixel, from `AppSizes.sprite*`.
  final double pixelSize;

  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final List<String> map =
        SpriteMaps.byId[spriteId] ?? SpriteMaps.byId[SpriteMaps.fallbackId]!;
    final double extent = SpriteMaps.size * pixelSize;

    return SizedBox(
      width: extent,
      height: extent,
      child: CustomPaint(
        size: Size.square(extent),
        painter: _PixelSpritePainter(map: map, pixelSize: pixelSize, glow: glow),
      ),
    );
  }
}

class _PixelSpritePainter extends CustomPainter {
  const _PixelSpritePainter({
    required this.map,
    required this.pixelSize,
    required this.glow,
  });

  final List<String> map;
  final double pixelSize;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final Color? glowColour = glow;
    if (glowColour != null) {
      canvas.drawPath(
        _silhouette(),
        Paint()
          ..color = glowColour
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            Shadow.convertRadiusToSigma(pixelSize * AppSizes.spriteGlowFactor),
          ),
      );
    }

    // Anti-aliasing off is the painter's equivalent of `FilterQuality.none`:
    // every cell edge lands hard, so the art never reads as smoothed.
    final Paint cell = Paint()..isAntiAlias = false;
    for (int y = 0; y < map.length; y++) {
      final String row = map[y];
      for (int x = 0; x < row.length; x++) {
        final Color? colour = PixelPalette.byKey[row[x]];
        if (colour == null) continue;
        cell.color = colour;
        canvas.drawRect(_cellRect(x, y), cell);
      }
    }
  }

  /// Every painted cell as one path, so the blur sees a single shape and
  /// overlapping cells do not stack up into a darker edge.
  Path _silhouette() {
    final Path path = Path();
    for (int y = 0; y < map.length; y++) {
      final String row = map[y];
      for (int x = 0; x < row.length; x++) {
        if (PixelPalette.byKey.containsKey(row[x])) path.addRect(_cellRect(x, y));
      }
    }
    return path;
  }

  Rect _cellRect(int x, int y) =>
      Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);

  @override
  bool shouldRepaint(_PixelSpritePainter old) =>
      old.map != map || old.pixelSize != pixelSize || old.glow != glow;
}
