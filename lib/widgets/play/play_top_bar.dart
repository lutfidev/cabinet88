import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The play shell's top bar: leave, which cabinet this is, and pause.
///
/// The design draws the divider under it at white `.07`, the same value
/// [context.palette.surfaceRaised] carries.
class PlayTopBar extends StatelessWidget {
  const PlayTopBar({
    super.key,
    required this.exitLabel,
    required this.title,
    required this.pauseLabel,
    required this.onExit,
    required this.onTogglePause,
  });

  final String exitLabel;
  final String title;
  final String pauseLabel;
  final VoidCallback onExit;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.palette.surfaceRaised,
            width: AppBorderWidths.hairline,
          ),
        ),
      ),
      child: Padding(
        padding: AppInsets.playBar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _BarAction(
              label: exitLabel,
              style: context.text.pixelLabel
                  .copyWith(color: context.palette.textPixelMuted),
              onTap: onExit,
            ),
            Text(
              title,
              style: context.text.pixelLabel
                  .copyWith(color: AppColors.accentHighlight),
            ),
            _BarAction(
              label: pauseLabel,
              style: context.text.pixelLabel
                  .copyWith(color: AppColors.accentSecondary),
              onTap: onTogglePause,
            ),
          ],
        ),
      ),
    );
  }
}

/// A bare label that taps. The text sits at the design's size; the target
/// around it is grown to the platform minimum, which costs no pixels because
/// there is nothing drawn behind it.
class _BarAction extends StatelessWidget {
  const _BarAction({required this.label, required this.style, required this.onTap});

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: Center(widthFactor: 1, child: Text(label, style: style)),
      ),
    );
  }
}
