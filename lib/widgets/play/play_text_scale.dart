import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Caps the player's own font-size setting, for everything under it.
///
/// The only widget in Cabinet88 that limits text scaling, and it wraps the
/// only screen that needs limiting. Home, the cabinet file and settings all
/// scroll, so they carry the system setting to whatever maximum the platform
/// offers — verified up to 2.0 on a 320px frame. The play shell cannot: the
/// field is square and shares one screen with the controls that drive it, so
/// every point of text scale is taken out of the board. Left alone, a 320px
/// phone at 2.0 plays Serpent 88 on a 55px board.
///
/// The ceiling itself is [AppTextScale.playCeiling], derived in
/// `docs/design-tokens.md` section 15. Scaling below it passes through
/// untouched.
class PlayTextScale extends StatelessWidget {
  const PlayTextScale({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler:
            media.textScaler.clamp(maxScaleFactor: AppTextScale.playCeiling),
      ),
      child: child,
    );
  }
}
