import '../models/cabinet.dart';
import '../models/cabinet_catalog.dart';
import 'arcade_game.dart';
import 'serpent88/serpent88_game.dart';

/// Which cabinet has a real game behind the shell, and how to build it.
///
/// The one place that names a game. The play shell asks here and stays
/// ignorant of Serpent 88, which is what lets cabinet eleven arrive without
/// touching a screen.
abstract final class GameCatalog {
  /// A fresh game for [cabinet], or null when this build ships none for it.
  static ArcadeGame? createFor(Cabinet cabinet) => switch (cabinet.id) {
        CabinetCatalog.serpentId => Serpent88Game(),
        _ => null,
      };

  /// The cabinet demo mode sends people to.
  static Cabinet get playableCabinet =>
      CabinetCatalog.byId(CabinetCatalog.serpentId);
}
