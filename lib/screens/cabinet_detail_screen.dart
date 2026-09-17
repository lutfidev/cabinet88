import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cabinet.dart';
import '../models/trophy.dart';
import '../services/progress_service.dart';
import '../services/trophy_service.dart';
import '../theme/app_theme.dart';
import '../widgets/detail_header_card.dart';
import '../widgets/layouts/tabbed_detail_layout.dart';
import '../widgets/rise_route.dart';
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
class CabinetDetailScreen extends StatefulWidget {
  const CabinetDetailScreen({super.key, required this.cabinet});

  final Cabinet cabinet;

  /// The route home pushes.
  static Route<void> route(Cabinet cabinet) => RiseRoute<void>(
        builder: (BuildContext context) => CabinetDetailScreen(cabinet: cabinet),
      );

  @override
  State<CabinetDetailScreen> createState() => _CabinetDetailScreenState();
}

class _CabinetDetailScreenState extends State<CabinetDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the file is what the Curator trophy counts. Filed once this
    // frame is out: progress tells the UI when it changes, and saying so
    // while the tree is still being built would mark it dirty mid-build.
    final ProgressService progress = context.read<ProgressService>();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      progress.recordFileRead(widget.cabinet.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Cabinet cabinet = widget.cabinet;
    final TrophyService trophyService = context.watch<TrophyService>();
    // The player's own best, not the catalog's seeded number.
    final int best = context.select<ProgressService, int>(
        (ProgressService p) => p.bestFor(cabinet.id));

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.appShell),
        // One transparent Material for the whole screen, so every press
        // highlight paints above the shell gradient.
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            // No ScreenRise here: RiseRoute plays the design's rise as this
            // route's own transition, and twice would double it.
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
                    best: best,
                    trophies: TrophyCatalog.featured,
                    trophyService: trophyService,
                  ),
                ),
              ],
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
