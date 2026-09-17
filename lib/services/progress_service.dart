import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the player has actually done, and the only place that knows it.
///
/// Three things are kept: the best score per cabinet, which cabinets have been
/// played, and which cabinet files have been read. Every trophy rule is
/// derived from those — nothing stores an unlock of its own, so a trophy can
/// never drift out of step with the run that earned it.
class ProgressService extends ChangeNotifier {
  /// `shared_preferences` keys, namespaced like the settings ones.
  static const String bestPrefix = 'progress.best.';
  static const String playedKey = 'progress.played';
  static const String filesReadKey = 'progress.filesRead';

  SharedPreferences? _preferences;

  final Map<String, int> _best = <String, int>{};
  final Set<String> _played = <String>{};
  final Set<String> _filesRead = <String>{};

  /// Pulls stored progress into memory. Awaited at startup, beside settings.
  Future<void> load() async {
    final SharedPreferences preferences =
        _preferences ??= await SharedPreferences.getInstance();

    _best.clear();
    for (final String key in preferences.getKeys()) {
      if (!key.startsWith(bestPrefix)) {
        continue;
      }
      final int? score = preferences.getInt(key);
      if (score != null) {
        _best[key.substring(bestPrefix.length)] = score;
      }
    }

    _played
      ..clear()
      ..addAll(preferences.getStringList(playedKey) ?? const <String>[]);
    _filesRead
      ..clear()
      ..addAll(preferences.getStringList(filesReadKey) ?? const <String>[]);

    notifyListeners();
  }

  /// A cabinet's best score. Zero means never scored, which the UI draws as a
  /// dash — there is no seeded number here, only what was played.
  int bestFor(String cabinetId) => _best[cabinetId] ?? 0;

  bool hasPlayed(String cabinetId) => _played.contains(cabinetId);

  /// How many distinct cabinets have had a run started on them.
  int get cabinetsPlayed => _played.length;

  bool hasReadFile(String cabinetId) => _filesRead.contains(cabinetId);

  int get filesRead => _filesRead.length;

  /// Files a finished run. Returns whether it beat the stored best.
  Future<bool> recordScore(String cabinetId, int score) async {
    if (score <= bestFor(cabinetId)) {
      return false;
    }
    _best[cabinetId] = score;
    notifyListeners();
    await (_preferences ??= await SharedPreferences.getInstance())
        .setInt('$bestPrefix$cabinetId', score);
    return true;
  }

  /// A run started. Called once per cabinet that matters, not once per run.
  Future<void> recordPlayed(String cabinetId) =>
      _remember(_played, playedKey, cabinetId);

  /// A cabinet file was opened.
  Future<void> recordFileRead(String cabinetId) =>
      _remember(_filesRead, filesReadKey, cabinetId);

  Future<void> _remember(Set<String> into, String key, String cabinetId) async {
    if (!into.add(cabinetId)) {
      return;
    }
    notifyListeners();
    await (_preferences ??= await SharedPreferences.getInstance())
        .setStringList(key, into.toList(growable: false));
  }
}
