# Velo Test

Testing utilities for the Velo state management package.

## Features

- 🚀 **veloTest Function**: Similar to blocTest for easy Velo testing
- 🎯 **Custom Matchers**: Specialized matchers for Velo state testing
- 🧪 **Mock Velo Classes**: Easy-to-use mock implementations for testing
- 📊 **State History Tracking**: Track all state emissions during tests
- 🔍 **State Verification**: Verify specific states were emitted
- 🎯 **Widget Testing Helpers**: Utilities for testing Velo widgets
- ⏱️ **Async Testing Support**: Helpers for testing async state changes
- 📝 **Test Helpers**: Pre-built test classes and utilities

## Installation

Add this to your package's `pubspec.yaml` file under `dev_dependencies`:

```yaml
dev_dependencies:
  velo_test: ^1.0.0
```

## Usage

### Basic Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('CounterVelo', () {
    late CounterVelo counterVelo;

    setUp(() {
      counterVelo = CounterVelo();
    });

    tearDown(() {
      counterVelo.dispose();
    });

    test('initial state is correct', () {
      expect(counterVelo.state, equals(const CounterState()));
    });

    test('increment updates state correctly', () {
      counterVelo.increment();
      expect(counterVelo.state.count, equals(1));
    });
  });
}
```

### veloTest Function

The `veloTest` function provides a declarative way to test Velo notifiers, similar to `blocTest`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('CounterVelo with veloTest', () {
    veloTest<CounterVelo, int>(
      'emits [1] when increment is called',
      build: () => CounterVelo(),
      act: (velo) => velo.increment(),
      expect: () => [1],
    );

    veloTest<CounterVelo, int>(
      'emits [1, 2, 3] when increment is called 3 times',
      build: () => CounterVelo(),
      act: (velo) async {
        velo.increment();
        velo.increment();
        velo.increment();
      },
      expect: () => [1, 2, 3],
    );

    veloTest<CounterVelo, int>(
      'handles errors correctly',
      build: () => CounterVelo(),
      act: (velo) => velo.throwError(),
      errors: () => [isA<Exception>()],
    );

    veloTest<CounterVelo, int>(
      'supports custom matchers',
      build: () => CounterVelo(),
      act: (velo) async {
        velo.increment();
        velo.increment();
      },
      verify: (velo) {
        expect(velo.state, emitsInOrder([1, 2]));
        expect(velo, hasState(2));
      },
    );
  });
}
```

### Custom Matchers

Velo Test provides specialized matchers for testing state emissions:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('Custom Matchers', () {
    late CounterVelo counterVelo;

    setUp(() {
      counterVelo = CounterVelo();
    });

    test('emitsInOrder matcher', () async {
      counterVelo.increment();
      counterVelo.increment();
      counterVelo.increment();
      
      expect(counterVelo, emitsInOrder([1, 2, 3]));
    });

    test('hasState matcher', () {
      counterVelo.increment();
      expect(counterVelo, hasState(1));
    });

    test('emitsCount matcher', () async {
      counterVelo.increment();
      counterVelo.increment();
      
      expect(counterVelo, emitsCount(2));
    });

    test('emitsWhere matcher', () async {
      counterVelo.increment();
      counterVelo.increment();
      
      expect(counterVelo, emitsWhere((state) => state > 1));
    });

    test('utility functions', () async {
      // Wait for specific state
      counterVelo.incrementAsync();
      await waitForState(counterVelo, 1);
      
      // Collect states over time
      final states = await collectStates(counterVelo, Duration(seconds: 1));
      expect(states, contains(1));
    });
  });
}
```

### Mock Velo Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('MockVelo', () {
    late MockVelo<CounterState> mockVelo;

    setUp(() {
      mockVelo = MockVelo(const CounterState());
    });

    test('tracks state history', () {
      mockVelo.emit(const CounterState(count: 1));
      mockVelo.emit(const CounterState(count: 2));

      expect(mockVelo.stateHistory.length, equals(3)); // initial + 2 emissions
      expect(mockVelo.emittedStates.length, equals(2)); // only emissions
    });

    test('verifies state emissions', () {
      const targetState = CounterState(count: 5);
      mockVelo.emit(targetState);

      mockVelo.verifyStateEmitted(targetState);
    });

    test('verifies emission order', () {
      const state1 = CounterState(count: 1);
      const state2 = CounterState(count: 2);
      
      mockVelo.emit(state1);
      mockVelo.emit(state2);

      mockVelo.verifyStatesEmittedInOrder([state1, state2]);
    });
  });
}
```

### Widget Testing

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('VeloBuilder Widget Tests', () {
    testWidgets('displays correct state', (tester) async {
      final counterVelo = CounterVelo();
      
      await tester.pumpVeloWidget(
        VeloBuilder<CounterVelo, CounterState>(
          builder: (context, state) {
            return Text('Count: ${state.count}');
          },
        ),
        velos: [counterVelo],
      );

      expect(find.text('Count: 0'), findsOneWidget);

      counterVelo.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });
  });
}
```

### Async Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('Async State Changes', () {
    testWidgets('waits for async state changes', (tester) async {
      final counterVelo = CounterVelo();
      
      await tester.pumpVeloWidget(
        VeloBuilder<CounterVelo, CounterState>(
          builder: (context, state) {
            return Text('Count: ${state.count}');
          },
        ),
        velos: [counterVelo],
      );

      // Trigger async increment
      counterVelo.incrementAsync();
      
      // Wait for the state to change
      await tester.waitForVeloState<CounterVelo, CounterState>(
        const CounterState(count: 1),
      );

      expect(find.text('Count: 1'), findsOneWidget);
    });
  });
}
```

## Available Test Helpers

### veloTest Function
- `veloTest<V, S>()`: Main testing function similar to blocTest
- `veloTestGroup<V, S>()`: Group multiple veloTest calls with shared setup

### Custom Matchers
- `emitsInOrder(List<S> states)`: Verifies states are emitted in specific order
- `emitsAnyOf(List<S> states)`: Checks if any of the expected states are emitted
- `hasState(S state)`: Verifies notifier has specific state
- `emitsCount(int count)`: Ensures exact number of state emissions
- `emitsWhere(bool Function(S) predicate)`: Tests states matching custom conditions

### Utility Functions
- `waitForState<V, S>(V velo, S state)`: Wait for specific state
- `waitForStateWhere<V, S>(V velo, bool Function(S) predicate)`: Wait for state matching condition
- `collectStates<V, S>(V velo, Duration duration)`: Collect all state changes over time

### Mock Classes
- `MockVelo<T>`: Mock implementation with state history tracking
- `CounterVelo`: Pre-built counter implementation for testing
- `SimpleVelo`: Simple test implementation

### Test States
- `CounterState`: Equatable state with count, loading, and error
- `SimpleState`: Basic state without Equatable

### Widget Helpers
- `VeloWidgetTester` extension: Additional methods for `WidgetTester`
- `createVeloBuilderTestWidget()`: Creates test widgets with VeloBuilder
- `createVeloListenerTestWidget()`: Creates test widgets with VeloListener
- `pumpVeloWidget()`: Pumps widgets with Velo providers

### General Utility Functions
- `waitForCondition()`: Waits for a condition with timeout
- `waitFor()`: Generic wait function
- `pumpAndSettle()`: Pumps and settles animations

## Documentation

For more detailed documentation and examples, visit our [GitHub repository](https://github.com/steve-nosse/velo).

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.