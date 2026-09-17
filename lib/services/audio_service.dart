import 'settings_service.dart';

/// The moments a cabinet would make a noise at.
///
/// Named after events the app already has, not after sounds: the design defers
/// its sound design spec ("sound design + haptics spec" sits in its own next
/// steps), so there is nothing here to take from it yet. When real audio is
/// commissioned it is written against this list.
enum ArcadeCue {
  /// A control was pressed — a D-pad key, the action button, an overlay CTA.
  uiSelect,

  /// A fresh run began.
  runStart,

  /// The run gained something. An apple, for Serpent 88.
  pickup,

  /// The run ended.
  gameOver,
}

/// Whatever actually makes the sound. Swapped, not rewritten, when audio files
/// land — nothing above this line knows how a cue is played.
abstract interface class AudioSink {
  void play(ArcadeCue cue);

  /// The room hum, on or off. Called only when the state actually changes.
  void ambience(bool playing);
}

/// The sink this build ships: every cue is dropped on the floor.
class SilentAudioSink implements AudioSink {
  const SilentAudioSink();

  @override
  void play(ArcadeCue cue) {}

  @override
  void ambience(bool playing) {}
}

/// The call sites' single entry point to audio, and the global mute.
///
/// The mute is the design's own third switch: its state key is `sound` and its
/// label is `Cabinet ambience`, default off, so a silent install is what the
/// prototype ships. Nothing new was added to the settings screen for it.
///
/// Ambience is reconciled rather than commanded: the play screen says whether
/// a cabinet is open, the switch says whether sound is allowed, and the hum
/// follows both — so flipping the switch mid-run takes effect immediately.
class AudioService {
  AudioService(this._settings, {AudioSink? sink})
      : _sink = sink ?? const SilentAudioSink() {
    _settings.addListener(_reconcileAmbience);
  }

  final SettingsService _settings;
  final AudioSink _sink;

  bool _cabinetOpen = false;
  bool _ambiencePlaying = false;

  /// The global mute, read at every call rather than cached.
  bool get enabled => _settings.cabinetAmbience;

  bool get ambiencePlaying => _ambiencePlaying;

  void play(ArcadeCue cue) {
    if (enabled) {
      _sink.play(cue);
    }
  }

  /// The play screen mounted. The hum starts if the switch allows it.
  void enterCabinet() {
    _cabinetOpen = true;
    _reconcileAmbience();
  }

  /// The play screen went away.
  void leaveCabinet() {
    _cabinetOpen = false;
    _reconcileAmbience();
  }

  void _reconcileAmbience() {
    final bool shouldPlay = _cabinetOpen && enabled;
    if (shouldPlay == _ambiencePlaying) {
      return;
    }
    _ambiencePlaying = shouldPlay;
    _sink.ambience(shouldPlay);
  }

  void dispose() {
    _settings.removeListener(_reconcileAmbience);
  }
}
