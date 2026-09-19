import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The three readouts above the field: score, level, personal best.
///
/// Each keeps the design's own colour — green, cyan, magenta — so a glance
/// tells them apart without reading the labels.
///
/// A readout is one fact to a screen reader, not a silkscreen abbreviation
/// followed by a number: the shell hands down the spoken form of each.
class PlayHud extends StatelessWidget {
  const PlayHud({
    super.key,
    required this.scoreLabel,
    required this.score,
    required this.scoreSpoken,
    required this.levelLabel,
    required this.level,
    required this.levelSpoken,
    required this.bestLabel,
    required this.best,
    required this.bestSpoken,
  });

  final String scoreLabel;
  final String score;
  final String levelLabel;
  final String level;
  final String bestLabel;
  final String best;

  final String scoreSpoken;
  final String levelSpoken;
  final String bestSpoken;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.hud,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: _Readout(
              label: scoreLabel,
              value: score,
              spoken: scoreSpoken,
              color: AppColors.accentPositive,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Flexible(
            child: _Readout(
              label: levelLabel,
              value: level,
              spoken: levelSpoken,
              color: AppColors.accentSecondary,
              alignment: CrossAxisAlignment.center,
            ),
          ),
          Flexible(
            child: _Readout(
              label: bestLabel,
              value: best,
              spoken: bestSpoken,
              color: AppColors.accentPrimary,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({
    required this.label,
    required this.value,
    required this.spoken,
    required this.color,
    required this.alignment,
  });

  final String label;
  final String value;
  final String spoken;
  final Color color;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: spoken,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: context.text.pixelLabel),
          const SizedBox(height: AppSpacing.s7),
          Text(value, style: context.text.hudValue.copyWith(color: color)),
        ],
      ),
    );
  }
}
