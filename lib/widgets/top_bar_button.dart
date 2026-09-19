import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'touch_target.dart';

/// The 38px glyph button the design puts at each end of a top bar.
///
/// Shared so the back chevron is drawn once, not once per screen. Drawn at
/// the design's 38px and targeted at the platform's 48, which costs the top
/// bar 10px of height and the glyph nothing.
class TopBarButton extends StatelessWidget {
  const TopBarButton({
    super.key,
    required this.glyph,
    required this.fontSize,
    this.onTap,
    this.label,
  }) : assert(
          onTap == null || label != null,
          'a button that does something has to say what',
        );

  final String glyph;
  final double fontSize;

  /// Null leaves the button inert, which is how the design draws the star.
  final VoidCallback? onTap;

  /// What a screen reader announces. A chevron would otherwise be read out as
  /// the character it is.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Widget button = TouchTarget(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.button,
        child: Container(
          width: AppSizes.topBarButton,
          height: AppSizes.topBarButton,
          decoration: BoxDecoration(
            color: context.palette.surfaceRaised,
            borderRadius: AppBorderRadius.button,
          ),
          child: Center(
            child: Text(
              glyph,
              style: TextStyle(fontSize: fontSize, color: context.palette.textPrimary),
            ),
          ),
        ),
      ),
    );

    // An inert button is not announced at all. Reading out the star would
    // promise a favourite feature the design never drew.
    if (onTap == null) {
      return ExcludeSemantics(child: button);
    }
    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: button,
    );
  }
}
