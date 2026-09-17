import '../theme/colors.dart';
import 'cabinet.dart';

/// The ten cabinets, in the order the design lists them.
///
/// Titles, taglines, blurbs, notes and control copy are verbatim from
/// `design/Arcade Vault.dc.html`. Nothing here is invented — see hard rule 7.
abstract final class CabinetCatalog {
  static const List<Cabinet> all = <Cabinet>[
    Cabinet(
      id: 'serpent',
      title: 'Serpent 88',
      genre: CabinetGenre.arcade,
      year: 1988,
      hue: AppColors.accentPositive,
      highScore: 24680,
      plays: 412,
      playable: true,
      blurb: 'The one everybody played under a desk. One line, one apple, no mercy.',
      note: 'Restored from the original 16×16 field. Wrap-around is off, '
          'exactly as it shipped.',
      controls: <CabinetControl>[
        CabinetControl(
          input: 'D-PAD',
          action: 'Steer the serpent — no stopping, no reversing',
        ),
        CabinetControl(input: 'SWIPE', action: 'Flick anywhere on the field to turn'),
        CabinetControl(input: 'START', action: 'Drop a fresh coin and start over'),
      ],
    ),
    Cabinet(
      id: 'blockfall',
      title: 'Blockfall',
      genre: CabinetGenre.puzzle,
      year: 1986,
      hue: AppColors.accentSecondary,
      highScore: 118450,
      plays: 640,
      blurb: 'Seven shapes, endless gravity, and the sound you still hear in your sleep.',
      note: 'Marathon and sprint boards, with the original rotation rules preserved.',
      controls: <CabinetControl>[
        CabinetControl(input: 'D-PAD', action: 'Move and soft-drop the falling piece'),
        CabinetControl(input: 'A', action: 'Rotate clockwise'),
      ],
    ),
    Cabinet(
      id: 'deflect',
      title: 'Deflect',
      genre: CabinetGenre.versus,
      year: 1979,
      hue: AppColors.accentPrimary,
      highScore: 21,
      plays: 198,
      blurb: 'Two paddles, one square, and the argument that never ended.',
      note: 'Local two-player on one device, or take on the house paddle.',
      controls: <CabinetControl>[
        CabinetControl(input: 'SLIDE', action: 'Drag your paddle up and down'),
      ],
    ),
    Cabinet(
      id: 'brickyard',
      title: 'Brickyard',
      genre: CabinetGenre.arcade,
      year: 1981,
      hue: AppColors.accentWarning,
      highScore: 9870,
      plays: 322,
      blurb: 'Chip away at the wall until the ball finds the gap you were praying for.',
      note: 'Thirty hand-built walls, then it starts over faster.',
      controls: <CabinetControl>[
        CabinetControl(input: 'SLIDE', action: 'Move the paddle'),
        CabinetControl(input: 'A', action: 'Launch the ball'),
      ],
    ),
    Cabinet(
      id: 'starlancer',
      title: 'Star Lancer',
      genre: CabinetGenre.shooter,
      year: 1984,
      hue: AppColors.accentHighlight,
      highScore: 64200,
      plays: 511,
      blurb: 'Waves come down, you go up. Everything in between is reflex.',
      note: 'Original attract mode included, because it deserves to be seen.',
      controls: <CabinetControl>[
        CabinetControl(input: 'D-PAD', action: 'Strafe left and right'),
        CabinetControl(input: 'A', action: 'Fire'),
      ],
    ),
    Cabinet(
      id: 'dotmaze',
      title: 'Dot Maze',
      genre: CabinetGenre.arcade,
      year: 1982,
      hue: AppColors.accentPositive,
      highScore: 47310,
      plays: 388,
      blurb: 'Clear the maze, dodge the hunters, learn the corners by heart.',
      note: 'Four mazes with the classic patterns intact.',
      controls: <CabinetControl>[
        CabinetControl(input: 'D-PAD', action: 'Turn at junctions'),
      ],
    ),
    Cabinet(
      id: 'minefield',
      title: 'Minefield',
      genre: CabinetGenre.puzzle,
      year: 1990,
      hue: AppColors.accentSecondary,
      highScore: 0,
      plays: 154,
      blurb: 'Pure deduction, wearing the disguise of a grid of gray squares.',
      note: 'Beginner through expert, with a no-guess board generator.',
      controls: <CabinetControl>[
        CabinetControl(input: 'TAP', action: 'Reveal a square'),
        CabinetControl(input: 'HOLD', action: 'Plant a flag'),
      ],
    ),
    Cabinet(
      id: 'patience',
      title: 'Patience',
      genre: CabinetGenre.cards,
      year: 1990,
      hue: AppColors.accentDanger,
      highScore: 0,
      plays: 276,
      blurb: 'The reason nobody got any work done in 1991.',
      note: 'Draw one or draw three, with the winning cascade animation.',
      controls: <CabinetControl>[
        CabinetControl(input: 'DRAG', action: 'Move cards between piles'),
        CabinetControl(input: 'TAP', action: 'Auto-play to a foundation'),
      ],
    ),
    Cabinet(
      id: 'molerush',
      title: 'Mole Rush',
      genre: CabinetGenre.reflex,
      year: 1985,
      hue: AppColors.accentWarning,
      highScore: 8140,
      plays: 96,
      blurb: 'A carnival cabinet in your hand. Faster than you remember.',
      note: 'Nine holes, escalating tempo, and a mallet with real weight to it.',
      controls: <CabinetControl>[
        CabinetControl(input: 'TAP', action: 'Whack a mole'),
      ],
    ),
    Cabinet(
      id: 'twenty48',
      title: 'Twenty48',
      genre: CabinetGenre.puzzle,
      year: 1994,
      hue: AppColors.accentHighlight,
      highScore: 34816,
      plays: 430,
      blurb: 'The newest cabinet in the vault, and the hardest one to put down.',
      note: 'Undo is off by default. Turn it on if you must.',
      controls: <CabinetControl>[
        CabinetControl(input: 'SWIPE', action: 'Slide the whole board'),
      ],
    ),
  ];

  /// The cabinet the home screen features, and the only one playable in v1.
  static Cabinet get featured => all.first;

  static Cabinet byId(String id) =>
      all.firstWhere((Cabinet c) => c.id == id, orElse: () => all.first);
}
