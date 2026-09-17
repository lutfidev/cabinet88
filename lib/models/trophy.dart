/// One achievement in the trophy case.
///
/// Trophies are global, not per-cabinet: the design keeps a single list and the
/// cabinet detail screen shows the first four of it, the same four for every
/// cabinet. Modelling them on [Cabinet] would mean inventing data the design
/// does not have.
class Trophy {
  const Trophy({
    required this.name,
    required this.description,
    required this.glyph,
    required this.unlocked,
  });

  final String name;
  final String description;

  /// The single pixel-type character shown in the ring.
  final String glyph;

  /// Seeded from the design's mock state. Phase 6 wires this to real progress.
  final bool unlocked;
}

/// The eight trophies, in the order the design lists them.
abstract final class TrophyCatalog {
  static const List<Trophy> all = <Trophy>[
    Trophy(
      name: 'First Coin',
      description: 'Played your first cabinet',
      glyph: '1',
      unlocked: true,
    ),
    Trophy(
      name: 'Century',
      description: 'Score 100 in Serpent 88',
      glyph: 'C',
      unlocked: true,
    ),
    Trophy(
      name: 'Wall Breaker',
      description: 'Clear a Brickyard wall without losing a ball',
      glyph: 'W',
      unlocked: true,
    ),
    Trophy(
      name: 'No Guessing',
      description: 'Win Minefield expert',
      glyph: 'X',
      unlocked: false,
    ),
    Trophy(
      name: 'Full House',
      description: 'Play all ten cabinets',
      glyph: 'F',
      unlocked: true,
    ),
    Trophy(
      name: 'All Nighter',
      description: 'Two hours in one sitting',
      glyph: 'Z',
      unlocked: false,
    ),
    Trophy(
      name: 'Perfect Maze',
      description: 'Clear Dot Maze without dying',
      glyph: 'P',
      unlocked: false,
    ),
    Trophy(
      name: 'Curator',
      description: 'Read every cabinet file',
      glyph: 'K',
      unlocked: true,
    ),
  ];

  /// The subset the cabinet detail screen's Trophies tab shows.
  static List<Trophy> get featured => all.take(4).toList(growable: false);
}
