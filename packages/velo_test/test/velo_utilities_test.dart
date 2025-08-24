import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import 'package:velo_test/src/velo_matchers.dart';

/// Test Velo notifier for utility function testing
class TestCounterVelo extends Velo<int> {
  TestCounterVelo() : super(0);

  void increment() {
    emit(state + 1);
  }

  void setTo(int value) {
    emit(value);
  }

  Future<void> incrementAsync() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    increment();
  }

  Future<void> incrementMultiple(int count) async {
    for (int i = 0; i < count; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      increment();
    }
  }
}

void main() {
  group('VeloMatchers Utility Functions', () {
    late TestCounterVelo velo;

    setUp(() {
      velo = TestCounterVelo();
    });

    tearDown(() {
      velo.dispose();
    });

    group('waitForState', () {
      test('should wait for specific state', () async {
        // Start async increment
        unawaited(velo.incrementAsync());

        await VeloTestUtils.waitForState(velo, 1);
        final result = velo.state;
        expect(result, equals(1));
        expect(velo.state, equals(1));
      });

      test('should return immediately if already at target state', () async {
        velo.setTo(5);

        await VeloTestUtils.waitForState(velo, 5);
        final result = velo.state;
        expect(result, equals(5));
      });

      test('should timeout if state is never reached', () async {
        expect(
          () => VeloTestUtils.waitForState(
            velo,
            999,
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should wait for state change in sequence', () async {
        // Start multiple increments
        unawaited(velo.incrementMultiple(3));

        await VeloTestUtils.waitForState(velo, 3);
        final result = velo.state;
        expect(result, equals(3));
      });
    });

    group('waitForStateWhere', () {
      test('should wait for state matching predicate', () async {
        // Start async increment
        unawaited(velo.incrementMultiple(5));

        final result = await VeloTestUtils.waitForStateWhere(
          velo,
          (state) => state > 3,
        );
        expect(result, greaterThan(3));
      });

      test('should return immediately if current state matches', () async {
        velo.setTo(10);

        final result = await VeloTestUtils.waitForStateWhere(
          velo,
          (state) => state > 5,
        );
        expect(result, equals(10));
      });

      test('should timeout if predicate is never satisfied', () async {
        expect(
          () => VeloTestUtils.waitForStateWhere(
            velo,
            (state) => state > 100,
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should work with complex predicates', () async {
        unawaited(velo.incrementMultiple(10));

        final result = await VeloTestUtils.waitForStateWhere(
          velo,
          (state) => (state) % 3 == 0 && state > 0,
        );
        expect(result % 3, equals(0));
        expect(result, greaterThan(0));
      });
    });

    group('collectStates', () {
      test('should collect all states during action execution', () async {
        final states = await VeloTestUtils.collectStates(velo, () async {
          velo
            ..increment() // 1
            ..increment() // 2
            ..increment(); // 3
        });

        expect(states, equals([1, 2, 3]));
      });

      test('should collect states from async actions', () async {
        final states = await VeloTestUtils.collectStates(
          velo,
          () => velo.incrementMultiple(3),
        );

        expect(states, equals([1, 2, 3]));
      });

      test('should handle empty actions', () async {
        final states = await VeloTestUtils.collectStates(velo, () async {
          // Do nothing
        });

        expect(states, isEmpty);
      });

      test('should collect rapid state changes', () async {
        final states = await VeloTestUtils.collectStates(velo, () async {
          for (int i = 0; i < 5; i++) {
            velo.increment();
          }
        });

        expect(states, equals([1, 2, 3, 4, 5]));
      });

      test('should handle exceptions in actions', () async {
        expect(
          () => VeloTestUtils.collectStates(velo, () async {
            velo.increment();
            throw Exception('Test exception');
          }),
          throwsException,
        );

        // Verify state was still collected before exception
        expect(velo.state, equals(1));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid listener additions/removals', () async {
        final futures = <Future<int>>[];

        // Start multiple waitForState calls
        for (int i = 1; i <= 5; i++) {
          futures.add(VeloTestUtils.waitForState(velo, i).then((_) => i));
        }

        // Increment to satisfy all waits
        unawaited(velo.incrementMultiple(5));

        final results = await Future.wait(futures);
        expect(results, equals([1, 2, 3, 4, 5]));
      });

      test('should handle concurrent collectStates calls', () async {
        final futures = <Future<List<int>>>[];

        // Start multiple collectStates calls
        for (int i = 0; i < 3; i++) {
          futures.add(
            VeloTestUtils.collectStates(velo, () async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              velo.increment();
            }),
          );
        }

        final results = await Future.wait(futures);

        // Each should have collected one state change
        for (final states in results) {
          expect(states.length, equals(1));
        }
      });
    });
  });
}
