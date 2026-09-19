import 'package:flutter/material.dart';

import '../../models/leaderboard_entry.dart';
import '../../theme/app_theme.dart';

/// The Scores tab: the cabinet's eight-row leaderboard.
class ScoresTab extends StatelessWidget {
  const ScoresTab({super.key, required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final LeaderboardEntry entry in entries) _LeaderboardRow(entry: entry),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  /// Ranks one to three carry their own colour; the rest stay muted.
  Color _rankColor(BuildContext context) => entry.rank <= AppColors.rankColors.length
      ? AppColors.rankColors[entry.rank - 1]
      : context.palette.textFaint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: entry.isYou ? AppColors.primaryTintRow : null,
        border: Border(
          bottom: BorderSide(
            color: context.palette.borderDivider,
            width: AppBorderWidths.hairline,
          ),
        ),
      ),
      child: Padding(
        padding: AppInsets.listRow,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: AppSizes.leaderRankColumn,
              child: Text(
                entry.rankLabel,
                style: context.text.pixelLabel.copyWith(color: _rankColor(context)),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                entry.handle,
                style: context.text.leaderHandle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(entry.scoreLabel, style: context.text.leaderScore),
          ],
        ),
      ),
    );
  }
}
