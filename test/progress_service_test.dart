import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _serpent = CabinetCatalog.serpentId;

Future<ProgressService> _loaded([
  Map<String, Object> stored = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(stored);
  final ProgressService progress = ProgressService();
  await progress.load();
  return progress;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install has played nothing and scored nothing', () async {
    final ProgressService progress = await _loaded();

    expect(progress.bestFor(_serpent), 0);
    expect(progress.hasPlayed(_serpent), isFalse);
    expect(progress.cabinetsPlayed, 0);
    expect(progress.filesRead, 0);
  });

  test('a run files a best, and only a better one replaces it', () async {
    final ProgressService progress = await _loaded();

    expect(await progress.recordScore(_serpent, 120), isTrue);
    expect(progress.bestFor(_serpent), 120);

    expect(await progress.recordScore(_serpent, 90), isFalse);
    expect(await progress.recordScore(_serpent, 120), isFalse);
    expect(progress.bestFor(_serpent), 120);

    expect(await progress.recordScore(_serpent, 121), isTrue);
    expect(progress.bestFor(_serpent), 121);
  });

  test('a best survives a restart', () async {
    final ProgressService progress = await _loaded();
    await progress.recordScore(_serpent, 640);
    await progress.recordPlayed(_serpent);
    await progress.recordFileRead('blockfall');

    // Same storage, a new service — which is what a relaunch amounts to.
    final ProgressService relaunched = ProgressService();
    await relaunched.load();

    expect(relaunched.bestFor(_serpent), 640);
    expect(relaunched.hasPlayed(_serpent), isTrue);
    expect(relaunched.hasReadFile('blockfall'), isTrue);
    expect(relaunched.hasReadFile(_serpent), isFalse);
  });

  test('scores are kept per cabinet', () async {
    final ProgressService progress = await _loaded();

    await progress.recordScore(_serpent, 200);
    await progress.recordScore('blockfall', 50);

    expect(progress.bestFor(_serpent), 200);
    expect(progress.bestFor('blockfall'), 50);
    expect(progress.bestFor('deflect'), 0);
  });

  test('a cabinet played twice is still one cabinet', () async {
    final ProgressService progress = await _loaded();

    await progress.recordPlayed(_serpent);
    await progress.recordPlayed(_serpent);
    await progress.recordPlayed('brickyard');

    expect(progress.cabinetsPlayed, 2);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList(ProgressService.playedKey),
      <String>[_serpent, 'brickyard'],
    );
  });

  test('anything that changes tells the UI', () async {
    final ProgressService progress = await _loaded();
    int notifications = 0;
    progress.addListener(() => notifications++);

    await progress.recordScore(_serpent, 10);
    await progress.recordPlayed(_serpent);
    await progress.recordFileRead(_serpent);
    expect(notifications, 3);

    // None of these is a change.
    await progress.recordScore(_serpent, 5);
    await progress.recordPlayed(_serpent);
    await progress.recordFileRead(_serpent);
    expect(notifications, 3);
  });
}
