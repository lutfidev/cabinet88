// Renders every image Cabinet88 ships or uploads, from the app's own tokens.
//
//   flutter test tool/render_store_assets.dart
//
// Nothing here is a design decision. The two faces are the vendored ones, the
// colours and the glow come from `lib/theme/`, and the copy is the design's
// verbatim wordmark. What this file adds is arithmetic: how large a glyph has
// to be to fit Android's safe zone, and where the screenshots come from.
//
// It is a tool, not a test. It asserts nothing about the app, and `flutter
// test` with no path sweeps `test/` only, so it never runs by accident.
// Re-run it whenever the palette, the type or a screen changes.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cabinet88/games/serpent88/serpent88_game.dart';
import 'package:cabinet88/games/serpent88/serpent_engine.dart';
import 'package:cabinet88/games/serpent88/serpent_rules.dart';
import 'package:cabinet88/models/cabinet_catalog.dart';
import 'package:cabinet88/screens/cabinet_detail_screen.dart';
import 'package:cabinet88/screens/home_screen.dart';
import 'package:cabinet88/screens/play_screen.dart';
import 'package:cabinet88/services/audio_service.dart';
import 'package:cabinet88/services/haptic_service.dart';
import 'package:cabinet88/services/progress_service.dart';
import 'package:cabinet88/services/settings_service.dart';
import 'package:cabinet88/services/trophy_service.dart';
import 'package:cabinet88/theme/app_theme.dart';
import 'package:cabinet88/widgets/crt_overlay.dart';
import 'package:cabinet88/widgets/play/play_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Where things land
// ---------------------------------------------------------------------------

const String _resDir = 'android/app/src/main/res';
const String _storeDir = 'store';

/// Android's launcher buckets, and the scale each one draws at.
const Map<String, double> _densities = <String, double>{
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

// ---------------------------------------------------------------------------
// Android platform geometry, which is not design
// ---------------------------------------------------------------------------

/// An adaptive icon layer is 108dp square.
const double _adaptiveExtent = 108;

/// Only the middle 66dp survives every mask a launcher may apply, and a round
/// mask makes that a *circle*, not a square. The mark is fitted to the circle,
/// so the corners of its box stay inside the crop too.
const double _adaptiveSafe = 66;

/// The legacy launcher icon, for the API levels below 26 that have no adaptive
/// icon at all. 48dp at mdpi, and nothing masks it, so the mark may use more of
/// the square than the adaptive safe zone allows.
const double _legacyExtent = 48;

/// How much of an unmasked square the mark spans, measured the same way as the
/// safe zone: across the diagonal of its ink. The launcher — and Play — round
/// and shadow these bitmaps themselves, so they keep a margin of their own.
const double _unmaskedFill = 0.74;

/// Google Play's listing icon and feature graphic, in pixels.
const Size _playIcon = Size(512, 512);
const Size _featureGraphic = Size(1024, 500);

/// How wide the wordmark runs across the feature graphic.
const double _featureFill = 0.62;

/// Phone screenshots. 1080x1920 is exactly 9:16, the tallest frame Play accepts
/// for a phone, and 360x640 logical is a frame the app is already tested at.
const double _shotScale = 3.0;
const Size _shotLogical = Size(360, 640);

// ---------------------------------------------------------------------------
// The mark
// ---------------------------------------------------------------------------

/// The second half of the wordmark, which is the whole icon.
///
/// Hard rule 2 renders the wordmark as `CABINET 88`. At 48dp only two
/// characters survive, and `88` is the half that reads as a number rather than
/// a truncated word.
const String _mark = '88';

/// The wordmark and the line under it, both verbatim from the design.
const String _wordmark = 'CABINET 88';
const String _wordmarkSub = 'EST. 1983 · REBUILT 2026';

// ---------------------------------------------------------------------------
// Measuring and painting
// ---------------------------------------------------------------------------

/// Every measurement is taken once at this size and scaled from there.
const double _reference = 100;

/// The pixel face, in [colour], with the wordmark's own glow or without it.
TextStyle _markStyle({required Color colour, required bool glow}) => TextStyle(
      fontFamily: AppFonts.pixelFamily,
      color: colour,
      shadows: glow ? AppShadows.wordmarkGlow : null,
    );

/// Lays [text] out at [size] in [style], unconstrained.
ui.Paragraph _layout(String text, TextStyle style, {required double size}) {
  final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(fontFamily: style.fontFamily, fontSize: size),
  )
    ..pushStyle(style.copyWith(fontSize: size).getTextStyle())
    ..addText(text);
  return builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
}

/// Where the ink actually lands for [text], laid out at [_reference].
///
/// Found by rasterising the string and scanning the alpha channel, not by
/// trusting the line box. Press Start 2P leaves a descender's worth of empty
/// space under a digit, so a glyph centred on its line box sits visibly high —
/// which is exactly what the first cut of this icon did.
///
/// The rectangle is relative to the paragraph's own origin, so it scales by
/// `size / _reference` and subtracts straight from a centre point.
Future<Rect> _inkAtReference(String text, TextStyle style) async {
  // The glow is dropped for the measurement: it is soft alpha reaching far past
  // the letterform, and it is the letterform that has to be centred.
  final ui.Paragraph paragraph =
      _layout(text, style.copyWith(shadows: const <Shadow>[]), size: _reference);
  final ui.LineMetrics line = paragraph.computeLineMetrics().single;
  final int width = paragraph.maxIntrinsicWidth.ceil() + 2;
  final int height = (line.ascent + line.descent).ceil() + 2;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()))
      .drawParagraph(paragraph, const Offset(1, 1));
  final ui.Image raster = await recorder.endRecording().toImage(width, height);
  final ByteData? pixels =
      await raster.toByteData(format: ui.ImageByteFormat.rawRgba);
  raster.dispose();
  if (pixels == null) {
    throw StateError('could not measure "$text"');
  }

  int left = width;
  int top = height;
  int right = -1;
  int bottom = -1;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (pixels.getUint8((y * width + x) * 4 + 3) == 0) {
        continue;
      }
      if (x < left) left = x;
      if (x > right) right = x;
      if (y < top) top = y;
      if (y > bottom) bottom = y;
    }
  }
  if (right < 0) {
    throw StateError('"$text" drew nothing — is the font loaded?');
  }
  // Back out the one-pixel margin the string was drawn at.
  return Rect.fromLTRB(
    left - 1,
    top - 1,
    right.toDouble(),
    bottom.toDouble(),
  );
}

/// The font size at which [ink] spans a circle of [diameter]. The diagonal is
/// the part a round mask bites first, so that is what is fitted.
double _sizeToFitCircle(Rect ink, double diameter) =>
    _reference *
    diameter /
    math.sqrt(ink.width * ink.width + ink.height * ink.height);

/// The font size at which [ink] is [width] wide.
double _sizeToFitWidth(Rect ink, double width) => _reference * width / ink.width;

/// Draws [text] at [size] with its *ink* centred on [centre].
void _drawInkCentred(
  Canvas canvas,
  String text,
  TextStyle style,
  Rect ink,
  double size,
  Offset centre,
) {
  final double scale = size / _reference;
  final Offset inkCentre = Offset(
    (ink.left + ink.right) / 2 * scale,
    (ink.top + ink.bottom) / 2 * scale,
  );
  canvas.drawParagraph(_layout(text, style, size: size), centre - inkCentre);
}

/// The app shell gradient, over the whole of [size].
void _paintBackground(Canvas canvas, Size size) {
  final Rect rect = Offset.zero & size;
  canvas.drawRect(rect, Paint()..shader = AppGradients.appShell.createShader(rect));
}

/// A painter that puts the `88` on a circle of [safeDiameter], centred in
/// [size]. Measuring is asynchronous, so it happens here, up front, and what
/// comes back is a plain painter the synchronous [_raster] can run.
Future<void Function(Canvas)> _markPainter(
  Size size,
  double safeDiameter, {
  required Color colour,
  required bool glow,
}) async {
  final TextStyle style = _markStyle(colour: colour, glow: glow);
  final Rect ink = await _inkAtReference(_mark, style);
  final double fitted = _sizeToFitCircle(ink, safeDiameter);
  return (Canvas canvas) => _drawInkCentred(
        canvas,
        _mark,
        style,
        ink,
        fitted,
        size.center(Offset.zero),
      );
}

// ---------------------------------------------------------------------------
// Files
// ---------------------------------------------------------------------------

Future<void> _writePng(ui.Image image, String path) async {
  final ByteData? encoded = await image.toByteData(format: ui.ImageByteFormat.png);
  if (encoded == null) {
    throw StateError('could not encode $path');
  }
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(encoded.buffer.asUint8List(0, encoded.lengthInBytes));
  // ignore: avoid_print
  print('  ${path.padRight(62)} ${image.width}x${image.height}');
}

/// Runs [paint] onto a canvas of [size] and hands back the raster.
Future<ui.Image> _raster(Size size, void Function(Canvas canvas) paint) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  paint(Canvas(recorder, Offset.zero & size));
  return recorder.endRecording().toImage(size.width.round(), size.height.round());
}

/// Rasters [paint] over [size] and writes it to [path].
Future<void> _render(
  Size size,
  String path,
  void Function(Canvas canvas) paint,
) async {
  final ui.Image image = await _raster(size, paint);
  await _writePng(image, path);
  image.dispose();
}

/// Loads the vendored faces off disk, so the tool draws the type the app ships
/// rather than the test harness's placeholder.
///
/// All three families, including the symbol subset, because the D-pad's arrows
/// and the cabinet file's star come from it — without it they render as Space
/// Grotesk's `.notdef`, a question mark in a box, which is exactly what this
/// screenshot showed before the subset was vendored.
Future<void> _loadFonts() async {
  const Map<String, List<String>> faces = <String, List<String>>{
    AppFonts.pixelFamily: <String>['PressStart2P-Regular.ttf'],
    AppFonts.bodyFamily: <String>[
      'SpaceGrotesk-Regular.ttf',
      'SpaceGrotesk-Medium.ttf',
      'SpaceGrotesk-SemiBold.ttf',
      'SpaceGrotesk-Bold.ttf',
    ],
    AppFonts.symbolFamily: <String>['NotoSansSymbols2-Subset.ttf'],
  };
  for (final MapEntry<String, List<String>> face in faces.entries) {
    final FontLoader loader = FontLoader(face.key);
    for (final String file in face.value) {
      final ByteData bytes =
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
      loader.addFont(Future<ByteData>.value(bytes));
    }
    await loader.load();
  }
}

// ---------------------------------------------------------------------------
// Screenshot harness — the same tree main.dart builds
// ---------------------------------------------------------------------------

/// The key the capture is taken from.
final GlobalKey _capture = GlobalKey();

/// Progress seeded so the screenshots show an app that has been played.
///
/// The best score is the catalog's own figure for Serpent 88, so the number on
/// the playlist row, the cabinet file and the HUD are the same number. One
/// cabinet played and one file read leaves `first-coin` and `century` earned
/// and the rest locked, which is the honest state of this build.
Map<String, Object> _seededProgress() => <String, Object>{
      '${ProgressService.bestPrefix}${CabinetCatalog.serpentId}':
          CabinetCatalog.featured.highScore,
      ProgressService.playedKey: <String>[CabinetCatalog.serpentId],
      ProgressService.filesReadKey: <String>[CabinetCatalog.serpentId],
    };

Future<Widget> _harness(Widget home) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(_seededProgress());
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await settings.load();
  await progress.load();

  return RepaintBoundary(
    key: _capture,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressService>.value(value: progress),
        ChangeNotifierProvider<SettingsService>.value(value: settings),
        Provider<HapticService>(
          create: (BuildContext c) => HapticService(c.read<SettingsService>()),
        ),
        Provider<AudioService>(
          create: (BuildContext c) => AudioService(c.read<SettingsService>()),
        ),
        ProxyProvider<ProgressService, TrophyService>(
          update: (BuildContext _, ProgressService p, TrophyService? _) =>
              ProgressTrophyService(p),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        // Scanlines are on by default and belong in the picture: they are what
        // the app looks like out of the box (hard rule 5).
        builder: (BuildContext context, Widget? child) => PaletteScope(
          palette: AppPalette.standard,
          child: CrtOverlay(child: child ?? const SizedBox.shrink()),
        ),
        home: home,
      ),
    ),
  );
}

/// Puts the tester on a 1080x1920 phone, with the app's shadows switched back
/// on.
///
/// `flutter_test` sets [debugDisableShadows] so goldens stay identical across
/// machines, and every `BoxShadow` then paints as a hard, unblurred shape. That
/// is the right default for a test and the wrong one here: it turned the play
/// field's glow into a solid green slab over the board. These are pictures of
/// the app, so the app's shadows belong in them.
///
/// The framework checks the flag is back before the test body returns, which is
/// what [_shoot] does after the capture.
void _useShotFrame(WidgetTester tester) {
  debugDisableShadows = false;
  tester.view
    ..physicalSize = Size(
      _shotLogical.width * _shotScale,
      _shotLogical.height * _shotScale,
    )
    ..devicePixelRatio = _shotScale;
  addTearDown(tester.view.reset);
}

Future<void> _shoot(WidgetTester tester, String name) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_capture));
  // Rasterising and writing a file are real asynchronous work: the engine and
  // the filesystem answer on their own threads, not on the fake clock a widget
  // test runs on. Outside `runAsync` the await resolves but the next pump
  // deadlocks, which is what a ten-minute hang looked like.
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: _shotScale);
    await _writePng(image, '$_storeDir/screenshots/$name.png');
    image.dispose();
  });
  // Unmount before the test ends: every screen rises on a one-shot controller
  // and the play shell holds a ticker.
  await tester.pumpWidget(const SizedBox.shrink());
  // Hand the painting flag back the way the framework expects to find it.
  debugDisableShadows = true;
}

// ---------------------------------------------------------------------------
// The autopilot
// ---------------------------------------------------------------------------

/// The D-pad glyphs, as the shell draws them.
const Map<Direction, String> _glyphs = <Direction, String>{
  Direction.up: '▲',
  Direction.down: '▼',
  Direction.left: '◀',
  Direction.right: '▶',
};

/// Whether the serpent survives a step into [cell]. The final segment is
/// ignored, exactly as the engine's own rule does: it moves out of the way.
bool _survives(SerpentEngine engine, Cell cell) {
  if (cell.isOutsideField) {
    return false;
  }
  for (int i = 0; i < engine.snake.length - 1; i++) {
    if (engine.snake[i] == cell) {
      return false;
    }
  }
  return true;
}

/// A greedy but self-preserving heading: toward the apple when that square is
/// survivable, otherwise any square that is.
///
/// [requested] is the last heading handed to the shell rather than the engine's
/// current one, because a turn already queued has not been stepped into yet,
/// and turning back across it is what kills a run.
Direction? _steer(SerpentEngine engine, Direction requested) {
  final Cell head = engine.head;
  final Cell food = engine.food;
  final List<Direction> preferred = <Direction>[
    if (food.x > head.x) Direction.right,
    if (food.x < head.x) Direction.left,
    if (food.y > head.y) Direction.down,
    if (food.y < head.y) Direction.up,
  ];
  for (final Direction heading in <Direction>[...preferred, ...Direction.values]) {
    if (heading.isOpposite(requested)) {
      continue;
    }
    if (_survives(engine, head.translated(heading))) {
      return heading;
    }
  }
  return null;
}

// ---------------------------------------------------------------------------

void main() {
  setUpAll(_loadFonts);

  test('launcher icon', () async {
    // ignore: avoid_print
    print('\nlauncher icon');
    for (final MapEntry<String, double> bucket in _densities.entries) {
      final String dir = '$_resDir/mipmap-${bucket.key}';
      final Size adaptive = Size.square(_adaptiveExtent * bucket.value);
      final double safe = _adaptiveSafe * bucket.value;

      await _render(
        adaptive,
        '$dir/ic_launcher_background.png',
        (Canvas c) => _paintBackground(c, adaptive),
      );
      await _render(
        adaptive,
        '$dir/ic_launcher_foreground.png',
        await _markPainter(
          adaptive,
          safe,
          colour: AppColors.accentHighlight,
          glow: true,
        ),
      );
      // Themed icons: the launcher picks the colour, so the layer is a flat
      // silhouette with no glow for it to tint.
      await _render(
        adaptive,
        '$dir/ic_launcher_monochrome.png',
        await _markPainter(
          adaptive,
          safe,
          colour: AppColors.onAccent,
          glow: false,
        ),
      );

      final Size legacy = Size.square(_legacyExtent * bucket.value);
      final void Function(Canvas) legacyMark = await _markPainter(
        legacy,
        legacy.width * _unmaskedFill,
        colour: AppColors.accentHighlight,
        glow: true,
      );
      await _render(legacy, '$dir/ic_launcher.png', (Canvas c) {
        _paintBackground(c, legacy);
        legacyMark(c);
      });
    }
  });

  test('play store icon', () async {
    // ignore: avoid_print
    print('\nplay store listing');
    final void Function(Canvas) mark = await _markPainter(
      _playIcon,
      _playIcon.width * _unmaskedFill,
      colour: AppColors.accentHighlight,
      glow: true,
    );
    await _render(_playIcon, '$_storeDir/icon-512.png', (Canvas c) {
      _paintBackground(c, _playIcon);
      mark(c);
    });
  });

  test('feature graphic', () async {
    // The two lines keep the design's own sizes relative to one another —
    // pixel 22 over pixel 8 — and the pair is scaled as a block. Only the
    // wordmark's width is chosen here; everything else follows from the design.
    final TextStyle top = _markStyle(colour: AppColors.accentHighlight, glow: true);
    final TextStyle bottom = TextStyle(
      fontFamily: AppFonts.pixelFamily,
      color: AppColors.accentSecondary,
      letterSpacing: AppLetterSpacing.wordmarkSub,
    );

    final Rect topInk = await _inkAtReference(_wordmark, top);
    final Rect bottomInk = await _inkAtReference(_wordmarkSub, bottom);

    final double topSize =
        _sizeToFitWidth(topInk, _featureGraphic.width * _featureFill);
    final double bottomSize = topSize * AppFontSizes.pixel8 / AppFontSizes.pixel22;

    final double topHeight = topInk.height * topSize / _reference;
    final double bottomHeight = bottomInk.height * bottomSize / _reference;
    // The design sets the wordmark on a 1.5 line box; the air under it is what
    // is left of that box once the letterform is taken out.
    final double gap = topSize * AppLineHeights.normal - topHeight;
    final double block = topHeight + gap + bottomHeight;
    final double blockTop = (_featureGraphic.height - block) / 2;
    final double centreX = _featureGraphic.width / 2;

    await _render(_featureGraphic, '$_storeDir/feature-graphic.png', (Canvas c) {
      _paintBackground(c, _featureGraphic);
      _drawInkCentred(
        c,
        _wordmark,
        top,
        topInk,
        topSize,
        Offset(centreX, blockTop + topHeight / 2),
      );
      _drawInkCentred(
        c,
        _wordmarkSub,
        bottom,
        bottomInk,
        bottomSize,
        Offset(centreX, blockTop + topHeight + gap + bottomHeight / 2),
      );
    });
  });

  testWidgets('screenshot: home', (WidgetTester tester) async {
    // ignore: avoid_print
    print('\nscreenshots');
    _useShotFrame(tester);
    await tester.pumpWidget(await _harness(const HomeScreen()));
    await tester.pumpAndSettle();
    await _shoot(tester, '1-home');
  });

  testWidgets('screenshot: the cabinet file', (WidgetTester tester) async {
    _useShotFrame(tester);
    await tester.pumpWidget(
      await _harness(CabinetDetailScreen(cabinet: CabinetCatalog.featured)),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, '2-cabinet-file');
  });

  testWidgets('screenshot: mid-game', (WidgetTester tester) async {
    _useShotFrame(tester);
    // A seeded engine, so the board in the picture is reproducible: the same
    // apples land in the same places on every run.
    final SerpentEngine engine = SerpentEngine(random: math.Random(8888));
    await tester.pumpWidget(
      await _harness(
        PlayScreen(
          cabinet: CabinetCatalog.featured,
          game: Serpent88Game(engine: engine),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Drop the coin.
    await tester.tap(
      find.descendant(of: find.byType(PlayOverlay), matching: find.text('START')),
    );
    await tester.pump();

    // Then let the real engine play itself, apple by apple. Never
    // pumpAndSettle past this point: the shell's ticker never stops.
    //
    // It stops while the run is still alive, because a screenshot of the
    // GAME OVER overlay is a screenshot of an overlay, not of the game.
    Direction requested = engine.direction;
    for (int frame = 0; frame < 900 && !engine.isOver && engine.eaten < 12; frame++) {
      final Direction? want = _steer(engine, requested);
      if (want != null && want != requested) {
        await tester.tap(find.text(_glyphs[want]!));
        requested = want;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    // ignore: avoid_print
    print('  board: score ${engine.score}, level ${engine.level}, '
        'length ${engine.snake.length}, over ${engine.isOver}');

    await _shoot(tester, '3-serpent-88');
  });

  testWidgets('screenshot: the trophy case', (WidgetTester tester) async {
    _useShotFrame(tester);
    await tester.pumpWidget(
      await _harness(CabinetDetailScreen(cabinet: CabinetCatalog.featured)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trophies'));
    await tester.pumpAndSettle();
    await _shoot(tester, '4-trophies');
  });
}
