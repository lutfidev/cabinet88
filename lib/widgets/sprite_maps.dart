/// The placeholder pixel art, as 8×8 character grids.
///
/// One character per pixel, keyed to `PixelPalette.byKey`; a `.` leaves the
/// cell empty. Every map is verbatim from the design's `MAPS` table.
///
/// This is the only file in the app that holds art data (hard rule 6). When
/// commissioned sprites arrive they replace what is here, and no screen, tile
/// or layout changes.
abstract final class SpriteMaps {
  /// Grid edge in cells. Every map is square.
  static const int size = 8;

  /// Drawn when a key has no map, matching the design's `MAPS[key] || serpent`.
  static const String fallbackId = 'serpent';

  // Non-cabinet sprites. Cabinet sprites are keyed by `Cabinet.id`.
  static const String avatar = 'avatar';
  static const String navHome = 'home';
  static const String navGrid = 'grid';
  static const String navGlass = 'glass';
  static const String navCup = 'cup';
  static const String navFace = 'face';

  static const Map<String, List<String>> byId = <String, List<String>>{
    'serpent': <String>[
      '.GGGGG..',
      '.G......',
      '.G.GGG..',
      '.G...G..',
      '.GGG.G..',
      '.....G..',
      '.GGGGG..',
      '.r......',
    ],
    'blockfall': <String>[
      '..cc....',
      '..cc....',
      '..cc.mm.',
      '..cc.mm.',
      '.yy..mm.',
      '.yyoo...',
      '..ooaa..',
      '..ooaa..',
    ],
    'deflect': <String>[
      '.c....m.',
      '.c....m.',
      '.c....m.',
      '...w....',
      '....w...',
      '.c....m.',
      '.c....m.',
      '.c....m.',
    ],
    'brickyard': <String>[
      'rrrrrrrr',
      'oooooooo',
      'yyyyyyyy',
      'gggggggg',
      '........',
      '....w...',
      '........',
      '..cccc..',
    ],
    'starlancer': <String>[
      '...w....',
      '..www...',
      '..wcw...',
      '.wwcww..',
      'wwwcwww.',
      '.w.c.w..',
      '...m....',
      '..m.m...',
    ],
    'dotmaze': <String>[
      'bbbbbbbb',
      'b......b',
      'b.bb.b.b',
      'b.b..b.b',
      'b.b.yb.b',
      'b.bb.b.b',
      'b......b',
      'bbbbbbbb',
    ],
    'minefield': <String>[
      '...w....',
      '.w.b.w..',
      '..bbb...',
      '.bbbbb..',
      'wbbbbbbw',
      '.bbbbb..',
      '..bbb...',
      '.w.b.w..',
    ],
    'patience': <String>[
      '.wwwwww.',
      '.w....w.',
      '.w.rr.w.',
      '.wrrrrw.',
      '.w.rr.w.',
      '.w..r.w.',
      '.w....w.',
      '.wwwwww.',
    ],
    'molerush': <String>[
      '........',
      '..ssss..',
      '.swssws.',
      '.ssssss.',
      '..spps..',
      '.aaaaaa.',
      'aaaaaaaa',
      '........',
    ],
    'twenty48': <String>[
      '........',
      '.yy.oo..',
      '.yy.oo..',
      '........',
      '.mm.cc..',
      '.mm.cc..',
      '........',
      '........',
    ],
    avatar: <String>[
      '..mmmm..',
      '.mwmmwm.',
      '.mmmmmm.',
      '.m.mm.m.',
      '..mmmm..',
      '.m.mm.m.',
      '.m....m.',
      '........',
    ],
    navHome: <String>[
      '..y..y..',
      '.yyyyyy.',
      'yy.yy.yy',
      '.y....y.',
      '.yyyyyy.',
      '..y..y..',
      '........',
      '........',
    ],
    navGrid: <String>[
      '.cc.cc..',
      '.cc.cc..',
      '........',
      '.cc.cc..',
      '.cc.cc..',
      '........',
      '........',
      '........',
    ],
    navGlass: <String>[
      '..ccc...',
      '.c...c..',
      '.c...c..',
      '..ccc...',
      '...cc...',
      '....cc..',
      '........',
      '........',
    ],
    navCup: <String>[
      '.yyyyy..',
      '.y...y..',
      '..yyy...',
      '...y....',
      '..yyy...',
      '........',
      '........',
      '........',
    ],
    navFace: <String>[
      '..mmm...',
      '.m...m..',
      '.m.m.m..',
      '.m...m..',
      '.mmmmm..',
      '........',
      '........',
      '........',
    ],
  };
}
