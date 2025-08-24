import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import 'package:velo_test/velo_test.dart';

// Test Velo for testing purposes
class TestCounterVelo extends Velo<int> {
  TestCounterVelo() : super(0);

  void increment() {
    emit(state + 1);
  }

  void incrementBy(int value) {
    emit(state + value);
  }

  Future<void> incrementAsync() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    increment();
  }

  void emitSequence(List<int> values) {
    for (var value in values) {
      emit(value);
    }
  }
}

void main() {
  group('Custom Matchers', () {
    late TestCounterVelo velo;

    setUp(() {
      velo = TestCounterVelo();
    });

    tearDown(() {
      velo.dispose();
    });

    group('emitsInOrder', () {
      test('should pass when states are emitted in correct order', () async {
        final states = <int>[];
        velo
          ..addListener(() => states.add(velo.state))
          ..emitSequence([1, 2, 3]);

        // Wait a bit for all emissions to complete
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(states, VeloMatchers.emitsInOrder([1, 2, 3]));
        velo.removeListener(() => states.add(velo.state));
      });

      test('should fail when states are emitted in wrong order', () async {
        final states = <int>[];
        velo
          ..addListener(() => states.add(velo.state))
          ..emitSequence([3, 1, 2]);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          () => expect(states, VeloMatchers.emitsInOrder([1, 2, 3])),
          throwsA(isA<TestFailure>()),
        );
        velo.removeListener(() => states.add(velo.state));
      });

      test('should handle empty list', () {
        final states = <int>[];
        expect(
          states,
          VeloMatchers.emitsInOrder(<int>[]),
        ); // Should pass for no emissions
      });
    });

    group('emitsAnyOf', () {
      test('should fail when none of expected states are emitted', () async {
        velo.increment(); // emits 1

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          () => expect(velo, VeloMatchers.emitsAnyOf([5, 10, 15])),
          throwsA(isA<TestFailure>()),
        );
      });
    });

    group('hasState', () {
      test('should pass when velo has the expected state', () {
        velo.increment(); // state becomes 1

        expect(velo, VeloMatchers.hasState(1));
      });

      test('should fail when velo does not have the expected state', () {
        velo.increment(); // state becomes 1

        expect(
          () => expect(velo, VeloMatchers.hasState(5)),
          throwsA(isA<TestFailure>()),
        );
      });
    });

    group('emitsCount', () {
      test('should fail when different number of states are emitted', () async {
        velo.emitSequence([1, 2]); // 2 emissions

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          () => expect(velo, VeloMatchers.emitsCount(3)),
          throwsA(isA<TestFailure>()),
        );
      });
    });

    group('emitsWhere', () {
      test('should fail when emitted states do not match predicate', () async {
        velo.emitSequence([1, 3, 5]); // all odd numbers

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          () => expect(
            velo,
            VeloMatchers.emitsWhere((state) => (state as int) % 2 == 0),
          ),
          throwsA(isA<TestFailure>()),
        );
      });
    });
  });
}
