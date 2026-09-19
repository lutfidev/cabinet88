import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The panel over the field in every phase but play: attract, paused, over.
///
/// One widget for all three — only the title, its colour, the note and the
/// call to action change.
class PlayOverlay extends StatelessWidget {
  const PlayOverlay({
    super.key,
    required this.title,
    required this.titleColor,
    required this.note,
    required this.ctaLabel,
    required this.onCta,
  });

  final String title;
  final Color titleColor;
  final String note;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.playOverlayScrim,
        borderRadius: AppBorderRadius.card,
      ),
      child: Padding(
        padding: AppInsets.playOverlay,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.overlayTitle.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.s14),
            // The note is the one part that can outgrow a short field — a
            // small phone in portrait leaves the panel barely taller than its
            // own copy. It gives way rather than overflowing; the title and
            // the call to action never move.
            Flexible(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppSizes.overlayCopyWidth),
                child: SingleChildScrollView(
                  child: Text(
                    note,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall
                        .copyWith(height: AppLineHeights.normal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            _Cta(label: ctaLabel, onTap: onCta),
          ],
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentPrimary,
      borderRadius: AppBorderRadius.button,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.button,
        child: Padding(
          padding: AppInsets.overlayCta,
          child: Text(label, style: context.text.overlayCta),
        ),
      ),
    );
  }
}
