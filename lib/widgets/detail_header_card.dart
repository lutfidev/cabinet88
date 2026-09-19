import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../theme/app_theme.dart';
import 'pixel_sprite.dart';
import 'touch_target.dart';

/// The detail screen's header: art, title, meta, and the primary play button.
///
/// Pinned above the tab strip, so the play button is reachable whatever the
/// open tab has scrolled to.
class DetailHeaderCard extends StatelessWidget {
  const DetailHeaderCard({
    super.key,
    required this.cabinet,
    required this.onPlay,
  });

  final Cabinet cabinet;
  final VoidCallback onPlay;

  /// `PLAY` on a cabinet whose game ships, `OPEN CABINET` on the rest.
  static const String playLabel = 'PLAY';
  static const String openLabel = 'OPEN CABINET';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        gradient: context.palette.detailHeaderGradient,
        borderRadius: AppBorderRadius.cardLarge,
        border: Border.all(
          color: context.palette.border,
          width: AppBorderWidths.hairline,
        ),
      ),
      child: Row(
        children: <Widget>[
          _ArtWell(cabinet: cabinet),
          const SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Title and meta are one fact, and the middle dot between
                // genre and year is punctuation, not a word.
                Semantics(
                  container: true,
                  label: '${cabinet.title}. ${cabinet.genre.label}, ${cabinet.year}.',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        cabinet.title,
                        style: context.text.detailTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s7),
                      Text(
                        '${cabinet.genre.label} · ${cabinet.year}',
                        style: context.text.detailMeta,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s11),
                _PlayPill(
                  label: cabinet.playable ? playLabel : openLabel,
                  onTap: onPlay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The 88px well the cabinet's art sits in.
class _ArtWell extends StatelessWidget {
  const _ArtWell({required this.cabinet});

  final Cabinet cabinet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.detailArt,
      height: AppSizes.detailArt,
      decoration: const BoxDecoration(
        color: AppColors.artWell,
        borderRadius: AppBorderRadius.tile,
      ),
      child: Center(
        child: PixelSprite(
          spriteId: cabinet.id,
          pixelSize: AppSizes.spriteDetail,
          glow: cabinet.hue,
        ),
      ),
    );
  }
}

/// The green pill. Sized by its label, as the design's inline-block is.
///
/// The design draws it ~38px tall, under the platform minimum — the touch
/// target deferred from phase 3. It keeps that height and gains the target
/// around it, which costs the header card 10px.
class _PlayPill extends StatelessWidget {
  const _PlayPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: TouchTarget(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.tab,
          child: Container(
            padding: AppInsets.playPill,
            decoration: const BoxDecoration(
              color: AppColors.accentPositive,
              borderRadius: AppBorderRadius.tab,
            ),
            child: Text(label, style: context.text.playButton),
          ),
        ),
      ),
    );
  }
}
