import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../theme/app_theme.dart';

/// Copy, verbatim from the design's play top bar.
const String _exit = '‹ EXIT';

/// Placeholder for the shared play shell, which phase 4 builds.
///
/// Deliberately thin: the design's ground colour and the two top-bar items
/// that name the route. The HUD, the field, the overlays and the controls all
/// belong to phase 4, so nothing is sketched here for it to inherit.
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key, required this.cabinet});

  final Cabinet cabinet;

  /// The route the detail screen's play button pushes.
  static Route<void> route(Cabinet cabinet) => MaterialPageRoute<void>(
        builder: (BuildContext context) => PlayScreen(cabinet: cabinet),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.playBackground,
      body: SafeArea(
        child: Padding(
          padding: AppInsets.playBar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Text(
                  _exit,
                  style: AppTextStyles.pixelLabel
                      .copyWith(color: AppColors.textPixelMuted),
                ),
              ),
              Text(
                cabinet.title,
                style: AppTextStyles.pixelLabel
                    .copyWith(color: AppColors.accentHighlight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
