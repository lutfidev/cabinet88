import 'package:cabinet88/services/haptic_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every buzz the platform was asked for, in order. Flutter sends all three
/// strengths down the same method and names them in the argument.
late List<Object?> _buzzes;

Future<HapticService> _service({required bool enabled}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppSetting.hapticFeedback.storageKey: enabled,
  });
  final SettingsService settings = SettingsService();
  await settings.load();
  return HapticService(settings);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _buzzes = <Object?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        _buzzes.add(call.arguments);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('each moment gets its own strength, lightest first', () async {
    final HapticService haptics = await _service(enabled: true);

    haptics.tap();
    haptics.pickup();
    haptics.over();

    expect(_buzzes, <String>[
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
    ]);
  });

  test('the switch off means the platform is never asked', () async {
    final HapticService haptics = await _service(enabled: false);

    haptics.tap();
    haptics.pickup();
    haptics.over();

    expect(haptics.enabled, isFalse);
    expect(_buzzes, isEmpty);
  });

  test('a fresh install buzzes, because the design ships haptics on', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.load();

    HapticService(settings).tap();

    expect(_buzzes, <String>['HapticFeedbackType.selectionClick']);
  });

  test('a toggle is felt without rebuilding the service', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppSetting.hapticFeedback.storageKey: false,
    });
    final SettingsService settings = SettingsService();
    await settings.load();
    final HapticService haptics = HapticService(settings);

    haptics.tap();
    expect(_buzzes, isEmpty);

    // The same instance, after the switch moves: the setting is read at the
    // call, never cached.
    await settings.setValue(AppSetting.hapticFeedback, true);
    haptics.tap();

    expect(_buzzes, <String>['HapticFeedbackType.selectionClick']);
  });
}
