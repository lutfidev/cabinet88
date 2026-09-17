import 'package:cabinet88/models/cabinet.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/models/trophy.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/trophy_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _serpent = CabinetCatalog.serpentId;

Trophy _trophy(String id) =>
    TrophyCatalog.all.firstWhere((Trophy t) => t.id == id);

Future<ProgressService> _loaded() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final ProgressService progress = ProgressService();
  await progress.load();
  return progress;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install has earned nothing', () async {
    final TrophyService service = ProgressTrophyService(await _loaded());

    for (final Trophy trophy in TrophyCatalog.all) {
      expect(service.isUnlocked(trophy), isFalse, reason: trophy.name);
    }
  });

  test('First Coin opens on the first run', () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    await progress.recordPlayed(_serpent);

    expect(service.isUnlocked(_trophy('first-coin')), isTrue);
    expect(service.isUnlocked(_trophy('full-house')), isFalse);
  });

  test('Century needs the hundred it asks for', () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    await progress.recordScore(_serpent, 99);
    expect(service.isUnlocked(_trophy('century')), isFalse);

    await progress.recordScore(_serpent, 100);
    expect(service.isUnlocked(_trophy('century')), isTrue);
  });

  test('a hundred on another cabinet is not a Serpent 88 hundred', () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    await progress.recordScore('blockfall', 5000);

    expect(service.isUnlocked(_trophy('century')), isFalse);
  });

  test('Curator wants every cabinet file, not most of them', () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    for (final Cabinet cabinet in CabinetCatalog.all.skip(1)) {
      await progress.recordFileRead(cabinet.id);
    }
    expect(service.isUnlocked(_trophy('curator')), isFalse);

    await progress.recordFileRead(_serpent);
    expect(service.isUnlocked(_trophy('curator')), isTrue);
  });

  test('a trophy whose cabinet has no game stays locked, however much you play',
      () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    await progress.recordPlayed(_serpent);
    await progress.recordScore(_serpent, 100000);
    for (final Cabinet cabinet in CabinetCatalog.all) {
      await progress.recordFileRead(cabinet.id);
    }

    for (final String id in <String>[
      'wall-breaker',
      'no-guessing',
      'perfect-maze',
      'all-nighter',
    ]) {
      expect(service.isUnlocked(_trophy(id)), isFalse, reason: id);
    }
  });

  test('Full House counts cabinets played, all ten of them', () async {
    final ProgressService progress = await _loaded();
    final TrophyService service = ProgressTrophyService(progress);

    for (final Cabinet cabinet in CabinetCatalog.all) {
      await progress.recordPlayed(cabinet.id);
    }

    expect(service.isUnlocked(_trophy('full-house')), isTrue);
  });
}
