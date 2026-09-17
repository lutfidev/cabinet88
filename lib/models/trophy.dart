/// One achievement in the trophy case.
///
/// Trophies are global, not per-cabinet: the design keeps a single list and the
/// cabinet detail screen shows the first four of it, the same four for every
/// cabinet. Modelling them on [Cabinet] would mean inventing data the design
/// does not have.
class Trophy {
  const Trophy({
    required this.id,
    required this.name,
    required this.description,
    required this.glyph,
  });

  /// Stable key. The unlock rule is keyed off this, never off [name], so the
  /// copy can change without a trophy quietly re-locking itself.
  final String id;

  final String name;
  final String description;

  /// The single pixel-type character shown in the ring.
  final String glyph;
}

/// The eight trophies, in the order the design lists them.
abstract final class TrophyCatalog {
  static const List<Trophy> all = <Trophy>[
    Trophy(
      id: 'first-coin',
      name: 'First Coin',
      description: 'Played your first cabinet',
      glyph: '1',
    ),
    Trophy(
      id: 'century',
      name: 'Century',
      description: 'Score 100 in Serpent 88',
      glyph: 'C',
    ),
    Trophy(
      id: 'wall-breaker',
      name: 'Wall Breaker',
      description: 'Clear a Brickyard wall without losing a ball',
      glyph: 'W',
    ),
    Trophy(
      id: 'no-guessing',
      name: 'No Guessing',
      description: 'Win Minefield expert',
      glyph: 'X',
    ),
    Trophy(
      id: 'full-house',
      name: 'Full House',
      description: 'Play all ten cabinets',
      glyph: 'F',
    ),
    Trophy(
      id: 'all-nighter',
      name: 'All Nighter',
      description: 'Two hours in one sitting',
      glyph: 'Z',
    ),
    Trophy(
      id: 'perfect-maze',
      name: 'Perfect Maze',
      description: 'Clear Dot Maze without dying',
      glyph: 'P',
    ),
    Trophy(
      id: 'curator',
      name: 'Curator',
      description: 'Read every cabinet file',
      glyph: 'K',
    ),
  ];

  /// The subset the cabinet detail screen's Trophies tab shows.
  static List<Trophy> get featured => all.take(4).toList(growable: false);
}
