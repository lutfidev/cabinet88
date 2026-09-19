import 'package:flutter/material.dart';

import '../../models/cabinet.dart';
import '../../theme/app_theme.dart';

/// The Overview tab: the cabinet's copy, then its three stat tiles.
class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.cabinet,
    required this.best,
  });

  final Cabinet cabinet;

  /// The player's own best. A cabinet nobody has scored on shows a dash.
  final int best;

  /// The stat labels, as the design writes them.
  static const String bestLabel = 'Your best';
  static const String runsLabel = 'Runs played';
  static const String releasedLabel = 'Released';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The design runs the blurb and the note together as one paragraph.
        Text('${cabinet.blurb} ${cabinet.note}', style: context.text.blurb),
        const SizedBox(height: AppSpacing.s14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  value: Cabinet.scoreLabel(best),
                  label: bestLabel,
                  spoken: Cabinet.spokenScore(best),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: _StatTile(
                  value: cabinet.plays.toString(),
                  label: runsLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: _StatTile(
                  value: cabinet.year.toString(),
                  label: releasedLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One stat tile. The Tabbed variant draws these without a border.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, this.spoken});

  final String value;
  final String label;

  /// What a screen reader hears where the drawn [value] does not survive
  /// being read out — an em dash for a score nobody has set.
  final String? spoken;

  @override
  Widget build(BuildContext context) {
    // A tile reads as one fact, not as a number followed by a caption.
    return Semantics(
      container: true,
      label: '$label: ${spoken ?? value}',
      excludeSemantics: true,
      child: _tile(context),
    );
  }

  Widget _tile(BuildContext context) {
    return Container(
      padding: AppInsets.statTile,
      decoration: BoxDecoration(
        color: context.palette.surfaceTile,
        borderRadius: AppBorderRadius.tile,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value, style: context.text.statValue),
          const SizedBox(height: AppSpacing.s6),
          Text(label, style: context.text.statLabel),
        ],
      ),
    );
  }
}
