import 'package:cabinet88/services/audio_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sink a real audio build would replace: it plays nothing and remembers
/// everything, which is the only way to see what the service let through.
class _RecordingSink implements AudioSink {
  final List<ArcadeCue> cues = <ArcadeCue>[];
  final List<bool> hum = <bool>[];

  @override
  void play(ArcadeCue cue) => cues.add(cue);

  @override
  void ambience(bool playing) => hum.add(playing);
}

Future<SettingsService> _settings({required bool sound}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppSetting.cabinetAmbience.storageKey: sound,
  });
  final SettingsService settings = SettingsService();
  await settings.load();
  return settings;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install is silent, because the design ships sound off',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.load();
    final _RecordingSink sink = _RecordingSink();
    final AudioService audio = AudioService(settings, sink: sink);
    addTearDown(audio.dispose);

    audio.play(ArcadeCue.runStart);
    audio.enterCabinet();

    expect(audio.enabled, isFalse);
    expect(sink.cues, isEmpty);
    expect(sink.hum, isEmpty);
    expect(audio.ambiencePlaying, isFalse);
  });

  test('sound on lets every cue through, in the order it was played',
      () async {
    final _RecordingSink sink = _RecordingSink();
    final AudioService audio =
        AudioService(await _settings(sound: true), sink: sink);
    addTearDown(audio.dispose);

    audio.play(ArcadeCue.uiSelect);
    audio.play(ArcadeCue.runStart);
    audio.play(ArcadeCue.pickup);
    audio.play(ArcadeCue.gameOver);

    expect(sink.cues, <ArcadeCue>[
      ArcadeCue.uiSelect,
      ArcadeCue.runStart,
      ArcadeCue.pickup,
      ArcadeCue.gameOver,
    ]);
  });

  test('the hum follows the cabinet, and is told only when it changes',
      () async {
    final _RecordingSink sink = _RecordingSink();
    final AudioService audio =
        AudioService(await _settings(sound: true), sink: sink);
    addTearDown(audio.dispose);

    audio.enterCabinet();
    audio.enterCabinet();
    expect(audio.ambiencePlaying, isTrue);

    audio.leaveCabinet();
    audio.leaveCabinet();

    expect(sink.hum, <bool>[true, false]);
    expect(audio.ambiencePlaying, isFalse);
  });

  test('the switch reaches a cabinet that is already open', () async {
    final SettingsService settings = await _settings(sound: false);
    final _RecordingSink sink = _RecordingSink();
    final AudioService audio = AudioService(settings, sink: sink);
    addTearDown(audio.dispose);

    audio.enterCabinet();
    expect(sink.hum, isEmpty);

    // Flipped mid-run: the hum comes up without leaving the screen, and goes
    // back down when it is flipped again.
    await settings.setValue(AppSetting.cabinetAmbience, true);
    expect(audio.ambiencePlaying, isTrue);
    await settings.setValue(AppSetting.cabinetAmbience, false);

    expect(sink.hum, <bool>[true, false]);
  });

  test('a disposed service stops listening to the switch', () async {
    final SettingsService settings = await _settings(sound: false);
    final _RecordingSink sink = _RecordingSink();
    final AudioService audio = AudioService(settings, sink: sink);

    audio.enterCabinet();
    audio.dispose();
    await settings.setValue(AppSetting.cabinetAmbience, true);

    expect(sink.hum, isEmpty);
  });
}
