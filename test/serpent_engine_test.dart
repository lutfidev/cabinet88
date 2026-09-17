import 'dart:math';

import 'package:cabinet88/games/serpent88/serpent_engine.dart';
import 'package:cabinet88/games/serpent88/serpent_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hands out the numbers a test wants, in order, then zeroes. Food is rolled
/// as two calls — x then y — so a pair of entries places one apple.
class _ScriptedRandom implements Random {
  _ScriptedRandom(this.script);

  final List<int> script;
  int _next = 0;

  @override
  int nextInt(int max) => _next < script.length ? script[_next++] : 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

/// Every apple in the top-left corner, which is nowhere near the opening
/// position — so a run is entirely predictable.
Random get _corner => _ScriptedRandom(const <int>[]);

/// Steps the engine [count] times.
void _run(SerpentEngine engine, int count) {
  for (int i = 0; i < count; i++) {
    engine.step();
  }
}

/// Drives the engine east to the apple at (12,8), which it eats on the fourth
/// step. The serpent is four long afterwards.
SerpentEngine _afterFirstApple() {
  final SerpentEngine engine = SerpentEngine(random: _corner);
  _run(engine, 4);
  return engine;
}

void main() {
  group('the opening position', () {
    test('is the design\'s', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);

      expect(engine.snake, SerpentRules.startSnake);
      expect(engine.head, const Cell(8, 8));
      expect(engine.direction, Direction.right);
      expect(engine.food, const Cell(12, 8));
      expect(engine.score, 0);
      expect(engine.eaten, 0);
      expect(engine.level, 1);
      expect(engine.stepMs, SerpentRules.startStepMs);
      expect(engine.isOver, isFalse);
    });

    test('comes back after a run, whatever state it ended in', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);
      _run(engine, 40);
      expect(engine.isOver, isTrue);

      engine.start();

      expect(engine.snake, SerpentRules.startSnake);
      expect(engine.isOver, isFalse);
      expect(engine.score, 0);
      expect(engine.food, const Cell(12, 8));
    });
  });

  group('moving', () {
    test('a step advances the head and drags the tail', () {
      final SerpentEngine engine = SerpentEngine(random: _corner)..step();

      expect(engine.head, const Cell(9, 8));
      expect(engine.snake, const <Cell>[Cell(9, 8), Cell(8, 8), Cell(7, 8)]);
      expect(engine.snake.length, SerpentRules.startSnake.length);
    });

    test('an apple grows the serpent and scores 10 plus the count', () {
      final SerpentEngine engine = _afterFirstApple();

      expect(engine.head, const Cell(12, 8));
      expect(engine.snake.length, 4);
      expect(engine.eaten, 1);
      expect(engine.score, 11);
    });

    test('the score, level and speed curves follow the apples', () {
      // Nine apples in a row, laid one square ahead each time.
      final SerpentEngine engine = SerpentEngine(
        random: _ScriptedRandom(<int>[
          for (int x = 13; x <= 15; x++) ...<int>[x, 8],
        ]),
      );
      _run(engine, 4);
      expect(engine.level, 1);
      expect(engine.stepMs, 135);

      _run(engine, 3);
      expect(engine.eaten, 4);
      // 11 + 12 + 13 + 14.
      expect(engine.score, 50);
      expect(engine.level, 1);

      expect(SerpentRules.levelFor(5), 2);
      expect(SerpentRules.levelFor(9), 2);
      expect(SerpentRules.levelFor(10), 3);
      expect(SerpentRules.stepMsFor(14), 70);
      expect(SerpentRules.stepMsFor(100), SerpentRules.fastestStepMs);
    });
  });

  group('collisions', () {
    test('every wall ends the run, and nothing wraps', () {
      for (final Direction heading in Direction.values) {
        final SerpentEngine engine = SerpentEngine(random: _corner)
          ..turn(heading);
        // Sixteen steps cross the whole field from the middle, whichever way
        // it is pointed.
        _run(engine, SerpentRules.gridSize);

        expect(engine.isOver, isTrue, reason: 'heading $heading');
      }
    });

    test('the serpent can bite itself', () {
      // Two apples, so it is five long and can close a loop on its own body.
      final SerpentEngine engine =
          SerpentEngine(random: _ScriptedRandom(<int>[13, 8]));
      _run(engine, 5);
      expect(engine.snake.length, 5);

      engine.turn(Direction.up);
      engine.step();
      engine.turn(Direction.left);
      engine.step();
      engine.turn(Direction.down);
      engine.step();

      expect(engine.isOver, isTrue);
    });

    test('the tail tip is not a collision — it is moving out of the way', () {
      final SerpentEngine engine = _afterFirstApple();

      engine.turn(Direction.up);
      engine.step();
      engine.turn(Direction.left);
      engine.step();
      engine.turn(Direction.down);
      engine.step();

      expect(engine.isOver, isFalse);
      expect(engine.head, const Cell(11, 8));
    });

    test('a finished run stops moving and stops turning', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);
      _run(engine, 40);
      final List<Cell> resting = List<Cell>.of(engine.snake);

      expect(engine.turn(Direction.up), isFalse);
      engine.step();

      expect(engine.snake, resting);
    });
  });

  group('turning', () {
    test('a reversal into your own neck is refused', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);

      expect(engine.turn(Direction.left), isFalse);
      engine.step();
      expect(engine.head, const Cell(9, 8));
    });

    test('the heading you are already on is refused', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);

      expect(engine.turn(Direction.right), isFalse);
    });

    test('two turns in one step cannot combine into a reversal', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);

      // Up is a legal quarter turn from right; down would then be a reversal
      // of the turn already queued, even though it is legal against the
      // heading still on screen.
      expect(engine.turn(Direction.up), isTrue);
      expect(engine.turn(Direction.down), isFalse);

      engine.step();
      expect(engine.head, const Cell(8, 7));
    });

    test('a fast corner keeps both halves', () {
      final SerpentEngine engine = SerpentEngine(random: _corner);

      expect(engine.turn(Direction.up), isTrue);
      expect(engine.turn(Direction.left), isTrue);
      // Two is the queue's depth: a third turn in the same step is dropped.
      expect(engine.turn(Direction.down), isFalse);

      engine.step();
      expect(engine.head, const Cell(8, 7));
      engine.step();
      expect(engine.head, const Cell(7, 7));
    });
  });

  group('food', () {
    test('never lands inside the serpent', () {
      // The first two rolls are squares the serpent is standing on, so both
      // are thrown away before (3,4) is taken.
      final SerpentEngine engine =
          SerpentEngine(random: _ScriptedRandom(<int>[12, 8, 11, 8, 3, 4]));
      _run(engine, 4);

      expect(engine.food, const Cell(3, 4));
    });

    test('stays off the serpent over a long random run', () {
      final SerpentEngine engine = SerpentEngine(random: Random(7));

      for (int i = 0; i < 400; i++) {
        if (engine.isOver) {
          engine.start();
        }
        engine.step();
        expect(engine.snake.contains(engine.food), isFalse);
        expect(engine.food.isOutsideField, isFalse);
      }
    });
  });
}
