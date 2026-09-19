import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The three readouts above the field: score, level, personal best.
///
/// Each keeps the design's own colour — green, cyan, magenta — so a glance
/// tells them apart without reading the labels.
class PlayHud extends StatelessWidget {
  const PlayHud({
    super.key,
    required this.scoreLabel,
    required this.score,
    required this.levelLabel,
    required this.level,
    required this.bestLabel,
    required this.best,
  });

  final String scoreLabel;
  final String score;
  final String levelLabel;
  final String level;
  final String bestLabel;
  final String best;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.hud,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _Readout(
            label: scoreLabel,
            value: score,
            color: AppColors.accentPositive,
            alignment: CrossAxisAlignment.start,
          ),
          _Readout(
            label: levelLabel,
            value: level,
            color: AppColors.accentSecondary,
            alignment: CrossAxisAlignment.center,
          ),
          _Readout(
            label: bestLabel,
            value: best,
            color: AppColors.accentPrimary,
            alignment: CrossAxisAlignment.end,
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
    required this.color,
    required this.alignment,
  });

  final String label;
  final String value;
  final Color color;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: context.text.pixelLabel),
        const SizedBox(height: AppSpacing.s7),
        Text(value, style: context.text.hudValue.copyWith(color: color)),
      ],
    );
  }
}
