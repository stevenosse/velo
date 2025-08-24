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

  void throwError() {
    throw Exception('Test error');
  }

  void emitMultiple() {
    emit(1);
    emit(2);
    emit(3);
  }
}

void main() {
  group('veloTest', () {
    veloTest<TestCounterVelo, int>(
      'should pass when expected states are emitted - emits [1] when increment is called',
      build: () => TestCounterVelo(),
      act: (velo) => velo.increment(),
      expect: () => [1],
    );

    veloTest<TestCounterVelo, int>(
      'should pass when multiple expected states are emitted - emits [1, 2, 3] when emitMultiple is called',
      build: () => TestCounterVelo(),
      act: (velo) => velo.emitMultiple(),
      expect: () => [1, 2, 3],
    );

    veloTest<TestCounterVelo, int>(
      'should pass when async actions emit expected states - emits [1] when incrementAsync is called',
      build: () => TestCounterVelo(),
      act: (velo) => velo.incrementAsync(),
      expect: () => [1],
    );

    veloTest<TestCounterVelo, int>(
      'should pass when no states are expected and none are emitted - emits nothing when no action is performed',
      build: () => TestCounterVelo(),
      act: (velo) {}, // No action
      expect: () => <int>[],
    );

    veloTest<TestCounterVelo, int>(
      'should pass when errors are expected and thrown - throws exception when throwError is called',
      build: () => TestCounterVelo(),
      act: (velo) => velo.throwError(),
      errors: () => [isA<Exception>()],
    );

    veloTest<TestCounterVelo, int>(
      'should pass with custom verify function - allows custom verification',
      build: () => TestCounterVelo(),
      act: (velo) {
        velo
          ..increment()
          ..increment();
      },
      expect: () => [1, 2],
    );

    veloTest<TestCounterVelo, int>(
      'should pass with seed state - starts with seed state',
      build: () => TestCounterVelo(),
      seed: 5,
      act: (velo) => velo.increment(),
      expect: () => [6],
    );

    veloTest<TestCounterVelo, int>(
      'should pass with wait duration - waits for async operations',
      build: () => TestCounterVelo(),
      act: (velo) => velo.incrementAsync(),
      wait: const Duration(milliseconds: 50),
      expect: () => [1],
    );

    veloTest<TestCounterVelo, int>(
      'should handle complex async scenarios - handles multiple async increments',
      build: () => TestCounterVelo(),
      act: (velo) async {
        await velo.incrementAsync();
        await velo.incrementAsync();
        velo.increment();
      },
      expect: () => [1, 2, 3],
    );
  });

  group('additional veloTest scenarios', () {
    veloTest<TestCounterVelo, int>(
      'increments to 1 - additional test',
      build: () => TestCounterVelo(),
      act: (TestCounterVelo velo) => velo.increment(),
      expect: () => [1],
    );

    veloTest<TestCounterVelo, int>(
      'increments by 5 - additional test',
      build: () => TestCounterVelo(),
      act: (TestCounterVelo velo) => velo.incrementBy(5),
      expect: () => [5],
    );
  });
}
