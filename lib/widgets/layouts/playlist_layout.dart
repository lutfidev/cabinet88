import 'package:flutter/material.dart';

import '../../models/cabinet.dart';
import '../../theme/app_theme.dart';
import '../cabinet_tile.dart';

/// Copy, verbatim from the design.
const String _pickEyebrow = "TONIGHT'S PICK";
const String _pickSubtitle = 'Five minutes is never five minutes.';
const String _sectionLabel = 'ALL CABINETS';

/// The Playlist home body: tonight's pick, then every cabinet as a row.
///
/// Kept apart from `HomeScreen` so a future Marquee or Row direction can take
/// its place without the screen changing. It routes nothing itself — the
/// screen owns navigation and hands down [onOpen].
class PlaylistLayout extends StatelessWidget {
  const PlaylistLayout({
    super.key,
    required this.cabinets,
    required this.featured,
    required this.onOpen,
  });

  final List<Cabinet> cabinets;

  /// The cabinet on the tonight-pick card. The design uses the first in the
  /// catalog, not a computed pick.
  final Cabinet featured;

  final ValueChanged<Cabinet> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TonightsPick(cabinet: featured, onTap: () => onOpen(featured)),
        const SizedBox(height: AppSpacing.s16),
        Text(_sectionLabel, style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.s10),
        for (final Cabinet cabinet in cabinets)
          CabinetTile(cabinet: cabinet, onTap: () => onOpen(cabinet)),
      ],
    );
  }
}

class _TonightsPick extends StatelessWidget {
  const _TonightsPick({required this.cabinet, required this.onTap});

  final Cabinet cabinet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.tonightPick,
        borderRadius: AppBorderRadius.card,
        border: Border.all(
          color: AppColors.primaryTintBorder,
          width: AppBorderWidths.hairline,
        ),
      ),
      // A transparent Material of its own, so the press highlight lands above
      // the card gradient rather than behind it.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.card,
          highlightColor: AppColors.surfacePressed,
          splashColor: AppColors.surfacePressed,
          child: Padding(
            padding: AppInsets.cardRoomy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_pickEyebrow, style: AppTextStyles.eyebrow),
                const SizedBox(height: AppSpacing.s8),
                Text(cabinet.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.s4),
                Text(_pickSubtitle, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
