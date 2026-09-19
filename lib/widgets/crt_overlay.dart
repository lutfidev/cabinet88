import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';

/// Which scanline pattern to lay down.
enum CrtTone {
  /// The whole-app pattern: one dark line, then two light ones, per 3px.
  screen,

  /// The heavier pattern the design layers over a cabinet screen: one dark
  /// line per 3px, with nothing in between.
  art,
}

/// The CRT scanline overlay — the one widget hard rule 5 allows.
///
/// Composited over [child] through a [Stack], never painted into a screen, and
/// wrapped in [IgnorePointer] so nothing underneath loses a touch. It follows
/// [SettingsService.crtScanlines]: off, and the overlay is not in the tree at
/// all.
///
/// High contrast overrides it. The design asks for a *scanline-free*
/// high-contrast theme, so that switch wins over this one and the pattern
/// does not paint, whatever the CRT switch says.
///
/// Cost: the painter is behind a [RepaintBoundary] and its `shouldRepaint` is
/// constant, so it paints once per size change and never once per frame. That
/// is the phase guardrail — a game running underneath pays nothing for it.
class CrtOverlay extends StatelessWidget {
  /// Marks the painted layer, so a test can tell an overlay that is switched
  /// off from one that is merely invisible.
  static const ValueKey<String> scanlineKey = ValueKey<String>('crt-scanlines');

  const CrtOverlay({
    super.key,
    required this.child,
    this.tone = CrtTone.screen,
    this.vignette = true,
  });

  final Widget child;
  final CrtTone tone;

  /// The darkened edge the design draws over the whole app. A cabinet screen
  /// inside the play field gets the lines without it.
  final bool vignette;

  @override
  Widget build(BuildContext context) {
    final bool scanlines = context.select<SettingsService, bool>(
      (SettingsService s) => s.crtScanlines && !s.highContrast,
    );
    if (!scanlines) {
      return child;
    }

    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                key: scanlineKey,
                isComplex: true,
                willChange: false,
                painter: _ScanlinePainter(tone: tone, vignette: vignette),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({required this.tone, required this.vignette});

  final CrtTone tone;
  final bool vignette;

  @override
  void paint(Canvas canvas, Size size) {
    final bool isScreen = tone == CrtTone.screen;
    final Paint dark = Paint()
      ..color = isScreen ? AppColors.scanlineDark : AppScanlines.artDark;
    final Paint light = Paint()..color = AppColors.scanlineLight;
    const double gap = AppScanlines.period - AppScanlines.darkBand;

    for (double y = 0; y < size.height; y += AppScanlines.period) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, AppScanlines.darkBand),
        dark,
      );
      if (isScreen) {
        canvas.drawRect(
          Rect.fromLTWH(0, y + AppScanlines.darkBand, size.width, gap),
          light,
        );
      }
    }

    if (vignette) {
      final Rect bounds = Offset.zero & size;
      canvas.drawRect(
        bounds,
        Paint()..shader = AppGradients.crtVignette.createShader(bounds),
      );
    }
  }

  /// Constant per usage: the pattern depends on nothing that changes while the
  /// overlay is mounted.
  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) =>
      oldDelegate.tone != tone || oldDelegate.vignette != vignette;
}
