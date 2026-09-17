import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_sprite.dart';

/// Copy, verbatim from the design's detail top bar.
const String _eyebrow = 'CABINET FILE';
const String _backGlyph = '‹';

/// Placeholder for the Tabbed cabinet detail, which phase 3 builds.
///
/// Only the top bar is real: the design's 38px back button and the
/// `CABINET FILE` eyebrow. Below it sits the cabinet's own art and title so
/// the route is recognisable — nothing here is invented layout, and the body
/// arrives with phase 3.
class CabinetDetailScreen extends StatelessWidget {
  const CabinetDetailScreen({super.key, required this.cabinet});

  final Cabinet cabinet;

  /// The route home pushes. Phase 3 replaces the body behind it, not this.
  static Route<void> route(Cabinet cabinet) => MaterialPageRoute<void>(
        builder: (BuildContext context) => CabinetDetailScreen(cabinet: cabinet),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.appShell),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: AppInsets.topBar,
                  child: Row(
                    children: <Widget>[
                      const _BackButton(),
                      Expanded(
                        child: Center(
                          child: Text(_eyebrow, style: AppTextStyles.detailMeta),
                        ),
                      ),
                      const SizedBox(width: AppSizes.topBarButton),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        PixelSprite(
                          spriteId: cabinet.id,
                          pixelSize: AppSizes.spriteExtraLarge,
                          glow: cabinet.hue,
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Text(cabinet.title, style: AppTextStyles.detailTitle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: AppBorderRadius.button,
      child: Container(
        width: AppSizes.topBarButton,
        height: AppSizes.topBarButton,
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: AppBorderRadius.button,
        ),
        child: Center(
          child: Text(
            _backGlyph,
            style: TextStyle(
              fontSize: AppFontSizes.glyph17,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
