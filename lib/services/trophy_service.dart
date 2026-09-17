import '../models/trophy.dart';

/// Where the UI asks whether a trophy is unlocked.
///
/// One seam, so the detail screen never reads progress directly. Phase 5 puts
/// a persistence-backed implementation behind this without touching a widget.
abstract interface class TrophyService {
  bool isUnlocked(Trophy trophy);
}

/// The implementation Cabinet88 ships until real progress exists.
///
/// It returns the design's own mock state, which is what [Trophy.unlocked]
/// carries — three of the four featured trophies open, one locked. Nothing is
/// written anywhere and nothing is read from disk.
class SeededTrophyService implements TrophyService {
  const SeededTrophyService();

  @override
  bool isUnlocked(Trophy trophy) => trophy.unlocked;
}
