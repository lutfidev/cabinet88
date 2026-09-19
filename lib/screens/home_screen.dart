import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../models/cabinet_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/layouts/playlist_layout.dart';
import '../widgets/pixel_sprite.dart';
import '../widgets/screen_rise.dart';
import '../widgets/sprite_maps.dart';
import 'cabinet_detail_screen.dart';
import 'settings_screen.dart';

/// Copy, verbatim from the design.
const String _greeting = 'GOOD EVENING';
const String _heading = 'The vault is open';

/// The home screen: a greeting header over the Playlist layout.
///
/// Nothing pins. The design scrolls the whole body, header included, under the
/// CRT layer that arrives in phase 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.appShell),
        // One transparent Material for the whole screen, so every row press
        // highlight paints above the shell gradient.
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: ScreenRise(
              child: SingleChildScrollView(
                padding: AppInsets.screen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _GreetingHeader(),
                    const SizedBox(height: AppSpacing.s20),
                    PlaylistLayout(
                      cabinets: CabinetCatalog.all,
                      featured: CabinetCatalog.all.first,
                      onOpen: (Cabinet cabinet) => Navigator.of(context)
                          .push(CabinetDetailScreen.route(cabinet)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_greeting, style: context.text.greetingEyebrow),
              const SizedBox(height: AppSpacing.s6),
              Text(_heading, style: context.text.screenTitle),
            ],
          ),
        ),
        const _AvatarButton(),
      ],
    );
  }
}

/// The design taps this through to a profile screen. The architecture has no
/// profile screen, but it has settings, and this is the only way into them
/// until the bottom nav exists.
class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(SettingsScreen.route()),
      child: Container(
        width: AppSizes.avatarButton,
        height: AppSizes.avatarButton,
        decoration: BoxDecoration(
          color: AppColors.secondaryTintFill,
          borderRadius: AppBorderRadius.tile,
          border: Border.all(
            color: AppColors.secondaryTintBorder,
            width: AppBorderWidths.hairline,
          ),
        ),
        child: const Center(
          child: PixelSprite(
            spriteId: SpriteMaps.avatar,
            pixelSize: AppSizes.spriteNav,
            glow: AppColors.accentSecondary,
          ),
        ),
      ),
    );
  }
}
