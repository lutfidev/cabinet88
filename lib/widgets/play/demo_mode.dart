import 'package:flutter/material.dart';

import '../../models/cabinet.dart';
import '../../theme/app_theme.dart';
import '../crt_overlay.dart';
import '../pixel_sprite.dart';
import '../touch_target.dart';

/// Copy, verbatim from the design's demo-mode branch.
const String _pressStart = 'PRESS START';

String _caption(String playableTitle) =>
    'Cabinet screen placeholder — this build ships $playableTitle fully '
    'playable; the other nine cabinets drop in behind the same shell.';

String _tryLabel(String playableTitle) => 'TRY ${playableTitle.toUpperCase()}';

/// The same call to action, in the case a screen reader should say it.
String _trySpoken(String playableTitle) => 'Try $playableTitle';

/// What the nine cabinets with no game show instead of a play field.
///
/// The design's own state for them: the cabinet's art on a dead screen, a
/// blinking `PRESS START` that starts nothing, and a way out to the one
/// cabinet that does play.
class DemoMode extends StatelessWidget {
  const DemoMode({
    super.key,
    required this.cabinet,
    required this.playable,
    required this.onTryPlayable,
  });

  /// The cabinet being looked at — the one with no game.
  final Cabinet cabinet;

  /// The cabinet the call to action leads to.
  final Cabinet playable;

  final VoidCallback onTryPlayable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.demoBody,
      child: Column(
        children: <Widget>[
          _DemoScreen(cabinet: cabinet),
          const SizedBox(height: AppSpacing.s18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.demoCopyWidth),
            child: Text(
              _caption(playable.title),
              textAlign: TextAlign.center,
              style: context.text.bodySmall.copyWith(
                color: context.palette.textCaption,
                height: AppLineHeights.loose,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s18),
          _TryCta(
            label: _tryLabel(playable.title),
            spoken: _trySpoken(playable.title),
            onTap: onTryPlayable,
          ),
        ],
      ),
    );
  }
}

/// The dead cabinet screen: art, scanlines, and the blink.
class _DemoScreen extends StatelessWidget {
  const _DemoScreen({required this.cabinet});

  final Cabinet cabinet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.demoScreen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.card,
          border: Border.all(
            color: context.palette.borderDemo,
            width: AppBorderWidths.hairline,
          ),
          gradient: context.palette.demoScreenGradient,
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.card,
          // The same overlay widget as everywhere else, in its in-art tone
          // (hard rule 5). A player with scanlines off gets none here either.
          child: CrtOverlay(
            tone: CrtTone.art,
            vignette: false,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PixelSprite(
                  spriteId: cabinet.id,
                  pixelSize: AppSizes.spriteExtraLarge,
                  glow: cabinet.hue,
                ),
                // `PRESS START` starts nothing on a cabinet with no game, so
                // a screen reader is not told to press it. The caption and
                // the call to action below carry what this screen is.
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.s14,
                  child: ExcludeSemantics(child: _Blink()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `PRESS START`, on `avBlink 1.4s steps(1,end) infinite` — full for the first
/// 60% of the cycle, then [AppOpacities.blinkOff]. A step, never a fade: the
/// design's keyframes hold each value flat.
class _Blink extends StatefulWidget {
  const _Blink();

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  /// The point in the cycle the design's keyframes step down at.
  static const double _offAt = 0.6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.blink,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity:
            _controller.value < _offAt ? 1 : AppOpacities.blinkOff,
        child: child,
      ),
      child: Text(
        _pressStart,
        textAlign: TextAlign.center,
        style: context.text.pixelLabel
            .copyWith(color: AppColors.accentHighlight),
      ),
    );
  }
}

class _TryCta extends StatelessWidget {
  const _TryCta({
    required this.label,
    required this.spoken,
    required this.onTap,
  });

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
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorderRadius.control,
            child: Container(
              padding: AppInsets.demoCta,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.control,
                border: Border.all(
                  color: AppColors.positiveTintCta,
                  width: AppBorderWidths.hairline,
                ),
              ),
              child: Text(
                label,
                style: context.text.pixelLabel
                    .copyWith(color: AppColors.accentPositive),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
