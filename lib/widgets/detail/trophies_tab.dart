import 'package:flutter/material.dart';

import '../../models/trophy.dart';
import '../../services/trophy_service.dart';
import '../../theme/app_theme.dart';

/// The Trophies tab: the four featured trophies, locked or unlocked.
///
/// Unlock state comes from [TrophyService], never from a widget's own guess,
/// so phase 5 swaps real progress in behind this without touching the layout.
class TrophiesTab extends StatelessWidget {
  const TrophiesTab({
    super.key,
    required this.trophies,
    required this.service,
  });

  final List<Trophy> trophies;
  final TrophyService service;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < trophies.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.s10),
          _TrophyRow(
            trophy: trophies[i],
            unlocked: service.isUnlocked(trophies[i]),
          ),
        ],
      ],
    );
  }
}

class _TrophyRow extends StatelessWidget {
  const _TrophyRow({required this.trophy, required this.unlocked});

  final Trophy trophy;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Color ring =
        unlocked ? AppColors.accentHighlight : context.palette.textLocked;

    return Opacity(
      opacity: unlocked ? 1 : AppOpacities.lockedDetail,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: context.palette.surfaceTile,
          borderRadius: AppBorderRadius.tile,
        ),
        child: Row(
          children: <Widget>[
            _GlyphRing(glyph: trophy.glyph, ring: ring),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(trophy.name, style: context.text.bodyStrong),
                  const SizedBox(height: AppSpacing.s2),
                  Text(trophy.description, style: context.text.captionMeta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The bordered square holding a trophy's single pixel character.
class _GlyphRing extends StatelessWidget {
  const _GlyphRing({required this.glyph, required this.ring});

  final String glyph;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.trophyGlyph,
      height: AppSizes.trophyGlyph,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.tab,
        border: Border.all(color: ring, width: AppBorderWidths.hairline),
      ),
      child: Center(
        child: Text(
          glyph,
          style: context.text.trophyGlyph.copyWith(color: ring),
        ),
      ),
    );
  }
}
