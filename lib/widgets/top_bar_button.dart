import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The 38px glyph button the design puts at each end of a top bar.
///
/// Shared so the back chevron is drawn once, not once per screen.
class TopBarButton extends StatelessWidget {
  const TopBarButton({
    super.key,
    required this.glyph,
    required this.fontSize,
    this.onTap,
  });

  final String glyph;
  final double fontSize;

  /// Null leaves the button inert, which is how the design draws the star.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}
