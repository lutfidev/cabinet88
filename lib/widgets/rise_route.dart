import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'screen_rise.dart';

/// Every push in the app.
///
/// The prototype has exactly one screen transition — the body carries
/// `avRise .3s ease both` on every screen, the play shell included — so the
/// app has exactly one too, and it is that. A platform page transition with
/// the rise playing on top of it would be two motions fighting over the same
/// three hundred milliseconds.
class RiseRoute<T> extends PageRouteBuilder<T> {
  RiseRoute({required WidgetBuilder builder, super.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              builder(context),
          transitionDuration: AppDurations.screenRise,
          reverseTransitionDuration: AppDurations.screenRise,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              riseTransition(animation, child),
        );
}
