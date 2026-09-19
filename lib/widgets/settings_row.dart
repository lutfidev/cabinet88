import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pixel_toggle.dart';

/// One switch on the settings screen: what it does, what it costs you, and
/// its state. The whole row is the target, as the design wires it.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceRow,
      borderRadius: AppBorderRadius.tile,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.tile,
        child: Semantics(
          toggled: value,
          child: Padding(
            padding: AppInsets.settingsRow,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: context.text.settingsLabel),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        hint,
                        style: context.text.caption
                            .copyWith(color: context.palette.textHint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                PixelToggle(value: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
