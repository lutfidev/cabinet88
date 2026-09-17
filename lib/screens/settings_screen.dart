import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_rise.dart';
import '../widgets/settings_row.dart';
import '../widgets/top_bar_button.dart';

/// Copy, verbatim from the design's settings block.
const String _header = 'CABINET SETTINGS';
const String _backGlyph = '‹';

/// The label and hint the design gives each switch, in its order.
const Map<AppSetting, (String, String)> _copy = <AppSetting, (String, String)>{
  AppSetting.crtScanlines: ('CRT scanlines', 'Softer glow, authentic curve'),
  AppSetting.hapticFeedback: ('Haptic feedback', 'A small thud on every hit'),
  AppSetting.cabinetAmbience: (
    'Cabinet ambience',
    'Room hum behind the game audio',
  ),
  AppSetting.onScreenDpad: ('On-screen D-pad', 'Otherwise swipe controls only'),
};

/// The settings screen.
///
/// The design keeps these four switches inside its profile screen, which the
/// architecture does not have; the block moves here whole, in its own order,
/// with nothing added to it.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
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
            child: ScreenRise(
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
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: AppInsets.screenBelowBar,
                      children: <Widget>[
                        Text(_header, style: AppTextStyles.sectionHeader),
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
      ),
    );
  }
}
