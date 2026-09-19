import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../touch_target.dart';

/// The play shell's top bar: leave, which cabinet this is, and pause.
///
/// The design draws the divider under it at white `.07`, the same value
/// [context.palette.surfaceRaised] carries.
///
/// The title takes whatever the two actions leave and elides rather than
/// overflowing, so no font-size setting can push it off the bar.
class PlayTopBar extends StatelessWidget {
  const PlayTopBar({
    super.key,
    required this.exitLabel,
    required this.exitSpoken,
    required this.title,
    required this.pauseLabel,
    required this.pauseSpoken,
    required this.onExit,
    required this.onTogglePause,
  });

  final String exitLabel;
  final String title;
  final String pauseLabel;

  /// The drawn labels are silkscreen: a chevron and a word in capitals.
  /// These are what a screen reader is given instead.
  final String exitSpoken;
  final String pauseSpoken;

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
              spoken: exitSpoken,
              style: context.text.pixelLabel
                  .copyWith(color: context.palette.textPixelMuted),
              onTap: onExit,
            ),
            Flexible(
              child: Semantics(
                container: true,
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.pixelLabel
                      .copyWith(color: AppColors.accentHighlight),
                ),
              ),
            ),
            _BarAction(
              label: pauseLabel,
              spoken: pauseSpoken,
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
  const _BarAction({
    required this.label,
    required this.spoken,
    required this.style,
    required this.onTap,
  });

  final String label;
  final String spoken;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: spoken,
      onTap: onTap,
      excludeSemantics: true,
      child: TouchTarget(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(label, style: style),
        ),
      ),
    );
  }
}
