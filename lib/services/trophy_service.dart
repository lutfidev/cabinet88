import '../models/cabinet_catalog.dart';
import '../models/trophy.dart';
import 'progress_service.dart';

/// Where the UI asks whether a trophy is unlocked.
///
/// One seam, so no widget reads progress directly.
abstract interface class TrophyService {
  bool isUnlocked(Trophy trophy);
}

/// The real thing: every trophy derived from what was actually played.
///
/// Nothing is seeded. A fresh install has eight locked trophies, and the three
/// whose rules this build can satisfy — [Trophy] `first-coin`, `century` and
/// `curator` — open the moment they are earned. The rest name cabinets that
/// ship as placeholders, so they stay locked until those cabinets are real.
class ProgressTrophyService implements TrophyService {
  const ProgressTrophyService(this.progress);

  final ProgressService progress;

  /// "Score 100 in Serpent 88" — the threshold is the trophy's own copy.
  static const int centuryScore = 100;

  @override
  bool isUnlocked(Trophy trophy) => switch (trophy.id) {
        // "Played your first cabinet."
        'first-coin' => progress.cabinetsPlayed > 0,
        // "Score 100 in Serpent 88."
        'century' =>
          progress.bestFor(CabinetCatalog.serpentId) >= centuryScore,
        // "Play all ten cabinets." Reachable once the other nine are games.
        'full-house' => progress.cabinetsPlayed >= CabinetCatalog.all.length,
        // "Read every cabinet file."
        'curator' => progress.filesRead >= CabinetCatalog.all.length,
        // `wall-breaker`, `no-guessing` and `perfect-maze` belong to Brickyard,
        // Minefield and Dot Maze, which this build does not ship; `all-nighter`
        // needs a session clock nothing keeps yet. None of them can be earned,
        // so none of them is shown as earned.
        _ => false,
      };
}
