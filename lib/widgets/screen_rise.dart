import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The design's `avRise`, driven by any 0→1 animation: a fade up ten pixels.
///
/// Stated once here, and used twice — by [ScreenRise] for the screen that is
/// never pushed, and by `RiseRoute` for every screen that is. The curve and
/// the distance are the design's (`avRise .3s ease both`).
Widget riseTransition(Animation<double> animation, Widget child) {
  final Animation<double> eased =
      CurveTween(curve: Curves.ease).animate(animation);
  return FadeTransition(
    opacity: eased,
    child: AnimatedBuilder(
      animation: eased,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        offset: Offset(0, AppSpacing.s10 * (1 - eased.value)),
        child: child,
      ),
      child: child,
    ),
  );
}

/// [riseTransition] on a clock of its own, for a screen with no route
/// animation behind it.
///
/// Only the home screen needs this: it is the app's first route, so nothing
/// pushes it and there is no route transition to ride. Every other screen gets
/// the same motion from `RiseRoute` instead — wrapping one of those in this
/// widget would play the rise twice.
class ScreenRise extends StatefulWidget {
  const ScreenRise({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenRise> createState() => _ScreenRiseState();
}

class _ScreenRiseState extends State<ScreenRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.screenRise,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      riseTransition(_controller, widget.child);
}
