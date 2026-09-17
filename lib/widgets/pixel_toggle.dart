import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The switch the design draws on every settings row.
///
/// A 44x26 track with a 20px knob, magenta when on. The design gives it no
/// transition, so neither does this — nothing here is invented (hard rule 7).
class PixelToggle extends StatelessWidget {
  const PixelToggle({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.toggleTrack.width,
      height: AppSizes.toggleTrack.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value ? AppColors.accentPrimary : AppColors.surfaceToggleOff,
          borderRadius: AppBorderRadius.row,
        ),
        child: Padding(
          padding: AppInsets.toggleTrack,
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: const SizedBox.square(
              dimension: AppSizes.toggleKnob,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.onAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
