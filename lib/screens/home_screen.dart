import 'package:flutter/material.dart';

import '../models/cabinet.dart';
import '../models/cabinet_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/layouts/playlist_layout.dart';
import '../widgets/pixel_sprite.dart';
import '../widgets/sprite_maps.dart';
import 'cabinet_detail_screen.dart';

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
            child: _ScreenRise(
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
              Text(_greeting, style: AppTextStyles.greetingEyebrow),
              const SizedBox(height: AppSpacing.s6),
              Text(_heading, style: AppTextStyles.screenTitle),
            ],
          ),
        ),
        const _AvatarButton(),
      ],
    );
  }
}

/// The design taps this through to a profile screen. There is no profile
/// screen in the architecture, so it renders and does nothing for now.
class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// The design's avRise: a screen body fades up ten pixels on entry.
class _ScreenRise extends StatefulWidget {
  const _ScreenRise({required this.child});

  final Widget child;

  @override
  State<_ScreenRise> createState() => _ScreenRiseState();
}

class _ScreenRiseState extends State<_ScreenRise>
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
