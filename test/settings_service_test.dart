import 'package:cabinet88/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install gets the design\'s own defaults', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.load();

    expect(settings.crtScanlines, isTrue);
    expect(settings.hapticFeedback, isTrue);
    expect(settings.cabinetAmbience, isFalse);
    expect(settings.onScreenDpad, isTrue);
    // The fifth switch is not the design's. A fresh install is still the
    // design, so it starts off.
    expect(settings.highContrast, isFalse);
  });

  test('stored values win over the defaults', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppSetting.crtScanlines.storageKey: false,
      AppSetting.cabinetAmbience.storageKey: true,
    });
    final SettingsService settings = SettingsService();
    await settings.load();

    expect(settings.crtScanlines, isFalse);
    expect(settings.cabinetAmbience, isTrue);
    // Untouched keys still fall back.
    expect(settings.onScreenDpad, isTrue);
  });

  test('a toggle is written to disk and survives a reload', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.load();

    await settings.toggle(AppSetting.crtScanlines);
    expect(settings.crtScanlines, isFalse);

    await settings.toggle(AppSetting.highContrast);
    expect(settings.highContrast, isTrue);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(AppSetting.crtScanlines.storageKey), isFalse);

    // What a restart sees.
    final SettingsService reloaded = SettingsService();
    await reloaded.load();
    expect(reloaded.crtScanlines, isFalse);
    expect(reloaded.highContrast, isTrue);
  });

  test('listeners hear a change once, and not when nothing changed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.load();

    int notifications = 0;
    settings.addListener(() => notifications++);

    await settings.setValue(AppSetting.onScreenDpad, false);
    expect(notifications, 1);

    await settings.setValue(AppSetting.onScreenDpad, false);
    expect(notifications, 1);
  });
}
