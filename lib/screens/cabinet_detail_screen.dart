import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cabinet.dart';
import '../models/trophy.dart';
import '../services/trophy_service.dart';
import '../theme/app_theme.dart';
import '../widgets/detail_header_card.dart';
import '../widgets/layouts/tabbed_detail_layout.dart';
import '../widgets/screen_rise.dart';
import '../widgets/top_bar_button.dart';
import 'play_screen.dart';

/// Copy and glyphs, verbatim from the design's detail top bar.
const String _eyebrow = 'CABINET FILE';
const String _backGlyph = '‹';
const String _starGlyph = '☆';

/// The cabinet file: one cabinet's header, and its three tabs.
///
/// The header and the tab strip are pinned; only the open tab scrolls. The
/// design scrolls the header away with the body, but that can put the play
/// button off screen, which the phase guardrail rules out.
class CabinetDetailScreen extends StatelessWidget {
  const CabinetDetailScreen({super.key, required this.cabinet});

  final Cabinet cabinet;

  /// The route home pushes.
  static Route<void> route(Cabinet cabinet) => MaterialPageRoute<void>(
        builder: (BuildContext context) => CabinetDetailScreen(cabinet: cabinet),
      );

  @override
  Widget build(BuildContext context) {
    final TrophyService trophyService = context.watch<TrophyService>();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.appShell),
        // One transparent Material for the whole screen, so every press
        // highlight paints above the shell gradient.
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: ScreenRise(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _TopBar(),
                  Padding(
                    padding: AppInsets.gutter,
                    child: DetailHeaderCard(
                      cabinet: cabinet,
                      onPlay: () => Navigator.of(context)
                          .push(PlayScreen.route(cabinet)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s18),
                  Expanded(
                    child: TabbedDetailLayout(
                      cabinet: cabinet,
                      trophies: TrophyCatalog.featured,
                      trophyService: trophyService,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.topBar,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TopBarButton(
            glyph: _backGlyph,
            fontSize: AppFontSizes.glyph17,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Text(_eyebrow, style: AppTextStyles.topBarEyebrow),
          // The design draws this star with no handler and no filled state, so
          // it renders and does nothing. Inventing a favourite would mean
          // inventing its colour too.
          const TopBarButton(
            glyph: _starGlyph,
            fontSize: AppFontSizes.glyph15,
          ),
        ],
      ),
    );
  }
}
