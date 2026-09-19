import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rise_route.dart';
import '../widgets/settings_row.dart';
import '../widgets/top_bar_button.dart';

/// Copy, verbatim from the design's settings block.
const String _header = 'CABINET SETTINGS';
const String _backGlyph = '‹';

/// What the chevron is, said out loud.
const String _backLabel = 'Back';

/// The label and hint each switch carries, in the order they are drawn.
///
/// Four are the design's own copy, verbatim. `High contrast` is not — the
/// design names the accessibility pass without drawing a row for it, so
/// this line is written to the voice of the other four.
const Map<AppSetting, (String, String)> _copy = <AppSetting, (String, String)>{
  AppSetting.crtScanlines: ('CRT scanlines', 'Softer glow, authentic curve'),
  AppSetting.highContrast: ('High contrast', 'Brighter text, no scanlines'),
  AppSetting.hapticFeedback: ('Haptic feedback', 'A small thud on every hit'),
  AppSetting.cabinetAmbience: (
    'Cabinet ambience',
    'Room hum behind the game audio',
  ),
  AppSetting.onScreenDpad: ('On-screen D-pad', 'Otherwise swipe controls only'),
};

/// The settings screen.
///
/// The design keeps its four switches inside its profile screen, which the
/// architecture does not have; the block moved here whole, in its own order.
/// High contrast is the one addition, and it keeps those four in sequence.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => RiseRoute<void>(
        builder: (BuildContext context) => const SettingsScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = context.watch<SettingsService>();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.appShell),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            // The rise belongs to RiseRoute, not to the screen body.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: AppInsets.topBar,
                  child: Row(
                    children: <Widget>[
                      TopBarButton(
                        glyph: _backGlyph,
                        fontSize: AppFontSizes.glyph17,
                        onTap: () => Navigator.of(context).maybePop(),
                        label: _backLabel,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: AppInsets.screenBelowBar,
                    children: <Widget>[
                      Semantics(
                        header: true,
                        child: Text(_header, style: context.text.sectionHeader),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      for (final AppSetting setting in AppSetting.values) ...<Widget>[
                        SettingsRow(
                          label: _copy[setting]!.$1,
                          hint: _copy[setting]!.$2,
                          value: settings.valueOf(setting),
                          onTap: () => settings.toggle(setting),
                        ),
                        const SizedBox(height: AppSpacing.s10),
                      ],
                    ],
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
