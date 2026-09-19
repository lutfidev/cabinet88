import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The switches on the settings screen, and where each one is stored.
///
/// Four of the five defaults are the design's own (`set: {crt:true,
/// haptics:true, sound:false, dpad:true}`), so a fresh install matches the
/// prototype — and CRT scanlines start on, which hard rule 5 requires.
///
/// [highContrast] is the fifth, and the design has no row for it: the
/// accessibility pass is named in its next steps and never drawn. It sits
/// second because it overrides the switch above it, and defaults off so a
/// fresh install is still the design.
enum AppSetting {
  crtScanlines('settings.crtScanlines', defaultValue: true),
  highContrast('settings.highContrast', defaultValue: false),
  hapticFeedback('settings.hapticFeedback', defaultValue: true),
  cabinetAmbience('settings.cabinetAmbience', defaultValue: false),
  onScreenDpad('settings.onScreenDpad', defaultValue: true);

  const AppSetting(this.storageKey, {required this.defaultValue});

  /// The `shared_preferences` key. Namespaced so nothing else can collide.
  final String storageKey;

  final bool defaultValue;
}

/// Reads and writes the user's settings.
///
/// The first real persistence in the app. [load] is awaited before the first
/// frame so nothing renders with a default it is about to replace — a scanline
/// overlay that appeared one frame late would flicker.
class SettingsService extends ChangeNotifier {
  SharedPreferences? _preferences;

  final Map<AppSetting, bool> _values = <AppSetting, bool>{
    for (final AppSetting setting in AppSetting.values)
      setting: setting.defaultValue,
  };

  /// Pulls every stored value into memory. Safe to call once, at startup.
  Future<void> load() async {
    final SharedPreferences preferences =
        _preferences ??= await SharedPreferences.getInstance();
    for (final AppSetting setting in AppSetting.values) {
      _values[setting] = preferences.getBool(setting.storageKey) ?? setting.defaultValue;
    }
    notifyListeners();
  }

  bool valueOf(AppSetting setting) => _values[setting] ?? setting.defaultValue;

  /// Writes a switch and tells the UI immediately. The disk write is not
  /// awaited by the listeners, so a toggle takes effect on the next frame.
  Future<void> setValue(AppSetting setting, bool value) async {
    if (_values[setting] == value) {
      return;
    }
    _values[setting] = value;
    notifyListeners();
    await (_preferences ??= await SharedPreferences.getInstance())
        .setBool(setting.storageKey, value);
  }

  Future<void> toggle(AppSetting setting) => setValue(setting, !valueOf(setting));

  /// Hard rule 5's switch. The overlay also yields to [highContrast],
  /// which the design calls a scanline-free theme.
  bool get crtScanlines => valueOf(AppSetting.crtScanlines);

  /// Brighter text, firmer edges, no scanlines. Derived from the design
  /// rather than drawn by it — see [AppPalette].
  bool get highContrast => valueOf(AppSetting.highContrast);

  /// Whether the play shell draws its on-screen D-pad. Off means swipe only.
  bool get onScreenDpad => valueOf(AppSetting.onScreenDpad);

  /// Stored, but nothing reads them until phase 6a wires haptics and audio.
  bool get hapticFeedback => valueOf(AppSetting.hapticFeedback);
  bool get cabinetAmbience => valueOf(AppSetting.cabinetAmbience);
}
