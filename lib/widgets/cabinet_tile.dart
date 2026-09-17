import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../theme/app_theme.dart';
import 'pixel_sprite.dart';

/// One cabinet as a playlist row: sprite, title, meta, high score.
///
/// The row sprite is the one place in the design that draws a cabinet without
/// its hue glow, so no [PixelSprite.glow] is passed.
class CabinetTile extends StatelessWidget {
  const CabinetTile({super.key, required this.cabinet, required this.onTap});

  final Cabinet cabinet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.surfacePressed,
      splashColor: AppColors.surfacePressed,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderDivider,
              width: AppBorderWidths.hairline,
            ),
          ),
        ),
        child: Padding(
          padding: AppInsets.listRow,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: AppSizes.rowSprite,
                height: AppSizes.rowSprite,
                child: Center(
                  child: PixelSprite(
                    spriteId: cabinet.id,
                    pixelSize: AppSizes.spriteRow,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      cabinet.title,
                      style: AppTextStyles.rowTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '${cabinet.genre.label} · ${cabinet.plays} plays',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s13),
              Text(cabinet.highScoreLabel, style: AppTextStyles.rowScore),
            ],
          ),
        ),
      ),
    );
  }
}
