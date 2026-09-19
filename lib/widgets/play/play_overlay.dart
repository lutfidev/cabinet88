import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../touch_target.dart';

/// The panel over the field in every phase but play: attract, paused, over.
///
/// One widget for all three — only the title, its colour, the note and the
/// call to action change.
///
/// The panel arrives without being asked for: a run ends, and this is what
/// says so. It announces itself once when it appears, as the title and the
/// note in one breath, and the call to action under it stays a button of its
/// own.
class PlayOverlay extends StatelessWidget {
  const PlayOverlay({
    super.key,
    required this.title,
    required this.titleColor,
    required this.note,
    required this.ctaLabel,
    required this.ctaSpoken,
    required this.onCta,
  });

  final String title;
  final Color titleColor;
  final String note;
  final String ctaLabel;

  /// The call to action in the case a screen reader should say it.
  final String ctaSpoken;

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
            Semantics(
              container: true,
              liveRegion: true,
              label: '$title. $note',
              excludeSemantics: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.overlayTitle.copyWith(color: titleColor),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            // The note is the one part that can outgrow a short field — a
            // small phone in portrait leaves the panel barely taller than its
            // own copy. It gives way rather than overflowing; the title and
            // the call to action never move.
            // The title node above already carries this sentence, and the
            // scroll view it sits in has nothing of its own to announce.
            Flexible(
              child: ExcludeSemantics(
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
            ),
            const SizedBox(height: AppSpacing.s14),
            _Cta(label: ctaLabel, spoken: ctaSpoken, onTap: onCta),
          ],
        ),
      ),
    );
  }
}

/// The design draws this ~39px tall, under the platform minimum — the touch
/// target deferred from phase 4. It keeps that height and gains the target.
class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.spoken, required this.onTap});

  final String label;
  final String spoken;
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
        child: Material(
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
        ),
      ),
    );
  }
}
