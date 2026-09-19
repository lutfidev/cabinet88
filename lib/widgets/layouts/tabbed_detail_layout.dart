import 'package:flutter/material.dart';

import '../../models/cabinet.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/trophy.dart';
import '../../services/trophy_service.dart';
import '../../theme/app_theme.dart';
import '../detail/overview_tab.dart';
import '../detail/scores_tab.dart';
import '../detail/trophies_tab.dart';
import '../touch_target.dart';

/// The three tabs the design gives the cabinet file. There are no others.
enum DetailTab {
  overview('Overview'),
  scores('Scores'),
  trophies('Trophies');

  const DetailTab(this.label);

  final String label;
}

/// The Tabbed detail body: the tab strip, and the view under it.
///
/// Everything it draws comes off the [Cabinet] it is handed, so an eleventh
/// cabinet needs no change here. Each tab scrolls on its own, which is what
/// keeps a tab's position when you leave it and come back.
class TabbedDetailLayout extends StatefulWidget {
  const TabbedDetailLayout({
    super.key,
    required this.cabinet,
    required this.best,
    required this.trophies,
    required this.trophyService,
  });

  final Cabinet cabinet;

  /// The player's best on this cabinet. Zero until they score one.
  final int best;
  final List<Trophy> trophies;
  final TrophyService trophyService;

  @override
  State<TabbedDetailLayout> createState() => _TabbedDetailLayoutState();
}

class _TabbedDetailLayoutState extends State<TabbedDetailLayout> {
  DetailTab _selected = DetailTab.overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: AppInsets.gutter,
          child: _TabStrip(
            selected: _selected,
            onSelect: (DetailTab tab) => setState(() => _selected = tab),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selected.index,
            sizing: StackFit.expand,
            children: <Widget>[
              _TabView(
                tab: DetailTab.overview,
                child: OverviewTab(
                  cabinet: widget.cabinet,
                  best: widget.best,
                ),
              ),
              _TabView(
                tab: DetailTab.scores,
                child: ScoresTab(
                  entries: LeaderboardMock.forCabinet(widget.cabinet),
                ),
              ),
              _TabView(
                tab: DetailTab.trophies,
                child: TrophiesTab(
                  trophies: widget.trophies,
                  service: widget.trophyService,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One tab's scroll region. The key is what remembers where it was left.
class _TabView extends StatelessWidget {
  const _TabView({required this.tab, required this.child});

  final DetailTab tab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: PageStorageKey<DetailTab>(tab),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s18,
        AppSpacing.s16,
        AppSpacing.s26,
      ),
      child: child,
    );
  }
}

/// The pill track holding the three tabs.
class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.selected, required this.onSelect});

  final DetailTab selected;
  final ValueChanged<DetailTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.tabTrack,
      decoration: BoxDecoration(
        color: context.palette.surfaceTrack,
        borderRadius: AppBorderRadius.tile,
      ),
      child: Row(
        children: <Widget>[
          for (final DetailTab tab in DetailTab.values) ...<Widget>[
            if (tab.index > 0) const SizedBox(width: AppSpacing.s6),
            Expanded(
              child: _Tab(
                tab: tab,
                active: tab == selected,
                onTap: () => onSelect(tab),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One tab. The pill is drawn at the design's height and the target around it
/// is the platform's 48, which is what makes the strip taller than the design
/// draws it.
class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.active, required this.onTap});

  final DetailTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: tab.label,
      onTap: onTap,
      excludeSemantics: true,
      child: TouchTarget(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.tab,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: active ? AppColors.accentPrimary : null,
              borderRadius: AppBorderRadius.tab,
            ),
            child: Padding(
              padding: AppInsets.tab,
              child: Text(
                tab.label,
                textAlign: TextAlign.center,
                style: active
                    ? context.text.tabLabel.copyWith(color: AppColors.onAccent)
                    : context.text.tabLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
