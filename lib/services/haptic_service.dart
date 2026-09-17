import 'package:flutter/services.dart';

import 'settings_service.dart';

/// The taps the cabinet gives back, and nothing louder.
///
/// Three strengths, one per kind of moment, so the whole app's feel is stated
/// in one file rather than scattered across the widgets that trigger it. Every
/// call is gated on the design's own `Haptic feedback` switch — off means the
/// platform is never asked at all.
///
/// The platform side is Flutter's [HapticFeedback], which goes through the
/// Android view's own haptics. No vibrate permission, no dependency.
class HapticService {
  const HapticService(this._settings);

  final SettingsService _settings;

  bool get enabled => _settings.hapticFeedback;

  /// A control was pressed: a D-pad key, the action button, or a swipe the
  /// shell accepted. The lightest thing the platform offers — this one fires
  /// several times a second during a fast run, so anything heavier would buzz.
  void tap() {
    if (enabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// The run gained something. An apple, for Serpent 88.
  void pickup() {
    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// The run ended. The one moment worth a heavier thud, and it only ever
  /// lands once per run.
  void over() {
    if (enabled) {
      HapticFeedback.mediumImpact();
    }
  }
}
