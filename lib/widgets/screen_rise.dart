import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The design's `avRise`: a screen body fades up ten pixels on entry.
///
/// Shared by every screen that carries the animation, so the curve and the
/// distance are stated once.
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

  late final Animation<double> _eased =
      CurvedAnimation(parent: _controller, curve: Curves.ease);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _eased,
      child: AnimatedBuilder(
        animation: _eased,
        builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: Offset(0, AppSpacing.s10 * (1 - _eased.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
