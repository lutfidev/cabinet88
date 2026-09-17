import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../crt_overlay.dart';

/// The viewport every cabinet draws into.
///
/// The frame, its glow and its scanlines belong to the shell; what appears
/// inside comes from the game's painter, and the shell never asks what it is.
class PlayField extends StatelessWidget {
  const PlayField({super.key, required this.painter, this.overlay});

  final CustomPainter painter;

  /// The attract, paused or game-over panel, when one is showing.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.card,
        border: Border.all(
          color: AppColors.positiveTintBorder,
          width: AppBorderWidths.hairline,
        ),
        gradient: AppGradients.playField,
        boxShadow: AppShadows.playField,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: AppInsets.playField,
            // The cabinet screen's own scanlines: heavier than the app's, and
            // the same widget, never a second implementation.
            child: CrtOverlay(
              tone: CrtTone.art,
              vignette: false,
              child: CustomPaint(painter: painter, isComplex: true),
            ),
          ),
          if (overlay != null) Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}
