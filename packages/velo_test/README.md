# Velo Test

Production-ready testing utilities for the Velo state management package.

## Features

- 🚀 **veloTest Function**: Advanced testing function similar to blocTest with enhanced error handling
- 🎯 **Custom Matchers**: Type-safe specialized matchers for Velo state testing
- 🧪 **Mock Velo Classes**: Memory-efficient mock implementations with automatic cleanup
- 📊 **State History Tracking**: Smart history tracking with memory leak prevention
- 🔍 **State Verification**: Comprehensive state verification with detailed error messages
- 🎯 **Widget Testing Helpers**: Robust utilities for testing Velo widgets with error handling
- ⏱️ **Async Testing Support**: Advanced helpers for testing async state changes with timeout management
- 📝 **Test Helpers**: Production-ready pre-built test classes and utilities
- 🔒 **Memory Management**: Built-in memory leak prevention and resource cleanup
- ⚡ **Performance Optimized**: Tested for high-frequency state changes and stress scenarios
- 🛡️ **Error Resilient**: Comprehensive error handling and recovery mechanisms

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

The `veloTest` function provides a declarative, production-ready way to test Velo notifiers with enhanced error handling and automatic cleanup:

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
      'handles errors correctly with type-safe matchers',
      build: () => CounterVelo(),
      act: (velo) => velo.throwError(),
      errors: () => [isA<Exception>()],
    );

    veloTest<CounterVelo, int>(
      'supports custom verification with automatic cleanup',
      build: () => CounterVelo(),
      act: (velo) async {
        velo.increment();
        velo.increment();
      },
      verify: (velo) async {
        // Custom verification with proper error handling
        expect(velo.state, equals(2));
        await VeloTestUtils.waitForState(velo, 2);
      },
    );
  });
}
```

### Key Improvements in veloTest

- **Enhanced Error Handling**: Automatically captures and properly reports both synchronous and asynchronous errors
- **Memory Management**: Automatically disposes Velo instances and cleans up listeners
- **Type Safety**: Improved type checking for error matchers and state verification
- **Custom Verification**: New `verify` parameter for custom test logic with proper cleanup

### Custom Matchers

Velo Test provides type-safe specialized matchers with enhanced error reporting:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('Custom Matchers', () {
    late CounterVelo counterVelo;

    setUp(() {
      counterVelo = CounterVelo();
    });

    tearDown(() {
      counterVelo.dispose(); // Automatic cleanup
    });

    test('emitsInOrder matcher with detailed error reporting', () {
      final states = <int>[];
      counterVelo.addListener(() => states.add(counterVelo.state));
      
      counterVelo.increment();
      counterVelo.increment();
      counterVelo.increment();
      
      // Type-safe with enhanced error messages
      expect(states, emitsInOrder([1, 2, 3]));
    });

    test('hasState matcher with current state verification', () {
      counterVelo.increment();
      expect(counterVelo, hasState(1));
    });

    test('emitsCount matcher with exact count verification', () {
      final states = <int>[];
      counterVelo.addListener(() => states.add(counterVelo.state));
      
      counterVelo.increment();
      counterVelo.increment();
      
      expect(states, emitsCount(2));
    });

    test('emitsWhere matcher with predicate validation', () {
      final states = <int>[];
      counterVelo.addListener(() => states.add(counterVelo.state));
      
      counterVelo.increment();
      counterVelo.increment();
      
      expect(states, emitsWhere((state) => state > 0));
    });

    test('utility functions with timeout and error handling', () async {
      // Wait for specific state with timeout
      counterVelo.incrementAsync();
      await VeloTestUtils.waitForState(counterVelo, 1);
      
      // Collect states during action execution
      final states = await VeloTestUtils.collectStates(counterVelo, () async {
        counterVelo.increment();
        counterVelo.increment();
      });
      expect(states, equals([2, 3]));
      
      // Wait for state matching predicate
      counterVelo.setValue(10);
      final result = await VeloTestUtils.waitForStateWhere(
        counterVelo, 
        (state) => state >= 10,
      );
      expect(result, equals(10));
    });
  });
}
```

### Mock Velo Testing

Enhanced MockVelo with memory leak prevention and automatic cleanup:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

void main() {
  group('MockVelo', () {
    late MockVelo<CounterState> mockVelo;

    setUp(() {
      mockVelo = MockVelo(const CounterState());
    });

    tearDown(() {
      mockVelo.dispose(); // Prevents memory leaks
    });

    test('tracks state history with memory management', () {
      mockVelo.emit(const CounterState(count: 1));
      mockVelo.emit(const CounterState(count: 2));

      expect(mockVelo.stateHistory.length, equals(3)); // initial + 2 emissions
      expect(mockVelo.emittedStates.length, equals(2)); // only emissions
      
      // Check memory usage
      expect(mockVelo.isHistoryNearLimit, isFalse);
    });

    test('verifies state emissions with enhanced error messages', () {
      const targetState = CounterState(count: 5);
      mockVelo.emit(targetState);

      mockVelo.verifyStateEmitted(targetState);
      expect(mockVelo.getEmissionCount(targetState), equals(1));
    });

    test('verifies emission order with detailed reporting', () {
      const state1 = CounterState(count: 1);
      const state2 = CounterState(count: 2);
      
      mockVelo.emit(state1);
      mockVelo.emit(state2);

      mockVelo.verifyStatesEmittedInOrder([state1, state2]);
    });

    test('automatically handles large state histories', () {
      // Emit many states to test memory management
      for (int i = 1; i <= 15000; i++) {
        mockVelo.emit(CounterState(count: i));
      }

      // History should be automatically trimmed
      expect(mockVelo.historySize, lessThanOrEqualTo(10000));
      expect(mockVelo.state, equals(const CounterState(count: 15000)));
    });

    test('prevents usage after disposal', () {
      mockVelo.dispose();
      
      expect(() => mockVelo.emit(const CounterState(count: 1)), throwsStateError);
      expect(() => mockVelo.stateHistory, throwsStateError);
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

## Production-Ready Test Helpers

### Core Testing Functions
- `veloTest<V, S>()`: Enhanced testing function with automatic cleanup and error handling
- Removed `veloTestGroup` (was redundant) for cleaner API

### Type-Safe Custom Matchers
- `emitsInOrder(List<S> states)`: Verifies states emitted in specific order with detailed error reporting
- `emitsAnyOf(List<S> states)`: Checks if any expected states are emitted with validation
- `hasState(S state)`: Verifies notifier has specific state with type safety
- `emitsCount(int count)`: Ensures exact number of state emissions with bounds checking
- `emitsWhere(bool Function(S) predicate)`: Tests states matching custom conditions with null safety

### Advanced Utility Functions
- `VeloTestUtils.waitForState<V, S>(V velo, S state)`: Wait for specific state with timeout and cleanup
- `VeloTestUtils.waitForStateWhere<V, S>(V velo, bool Function(S) predicate)`: Wait for state matching condition with error handling
- `VeloTestUtils.collectStates<V, S>(V velo, Future<void> Function() action)`: Collect states during action execution with automatic cleanup

### Memory-Managed Mock Classes
- `MockVelo<T>`: Memory-efficient mock with automatic history trimming and disposal protection
- `CounterVelo`: Production-ready counter implementation for testing
- `SimpleVelo`: Simple test implementation with proper lifecycle management

### Enhanced Test States
- `CounterState`: Equatable state with count, loading, and error with proper equality
- `SimpleState`: Basic state without Equatable but with proper hashCode and equality

### Robust Widget Helpers
- `VeloWidgetTester` extension: Enhanced methods for `WidgetTester` with error handling
- `createVeloBuilderTestWidget()`: Creates test widgets with VeloBuilder and error boundaries
- `createVeloListenerTestWidget()`: Creates test widgets with VeloListener and cleanup
- `pumpVeloWidget()`: Pumps widgets with Velo providers and validation

### Advanced Utility Functions
- `waitForCondition()`: Waits for condition with timeout and error capture
- `waitFor()`: Generic wait function with interval validation and error handling
- `TimeoutException`: Custom exception for timeout scenarios with detailed messages

### Performance and Memory Features
- **Automatic Memory Management**: All helpers include automatic cleanup and disposal
- **Performance Optimized**: Tested for high-frequency state changes (10,000+ states)
- **Memory Leak Prevention**: Built-in history trimming and resource cleanup
- **Error Recovery**: Comprehensive error handling with helpful messages
- **Type Safety**: Full null safety and generic type constraints

## Best Practices

### Memory Management
```dart
// ✅ Always dispose resources
void main() {
  group('MyVelo', () {
    late MyVelo velo;

    setUp(() {
      velo = MyVelo();
    });

    tearDown(() {
      velo.dispose(); // Prevents memory leaks
    });

    // Your tests here...
  });
}
```

### Error Handling
```dart
// ✅ Use veloTest for comprehensive error handling
veloTest<MyVelo, MyState>(
  'handles errors gracefully',
  build: () => MyVelo(),
  act: (velo) => velo.triggerError(),
  errors: () => [isA<MyCustomException>()],
);
```

### High-Frequency Testing
```dart
// ✅ Use MockVelo for performance testing
test('handles high-frequency updates', () {
  final mock = MockVelo<int>(0);
  
  // Emit many states - automatically managed
  for (int i = 0; i < 10000; i++) {
    mock.emit(i);
  }
  
  expect(mock.historySize, lessThanOrEqualTo(10000));
  mock.dispose(); // Cleanup
});
```

### Widget Testing
```dart
// ✅ Use enhanced widget test helpers
testWidgets('my widget test', (tester) async {
  final velo = MyVelo();
  
  try {
    await tester.pumpVeloWidget(
      MyWidget(),
      velos: [velo],
    );
    
    await tester.waitForVeloState<MyVelo, MyState>(expectedState);
    // Assertions...
  } finally {
    velo.dispose();
  }
});
```

## Migration from bloc_test

If migrating from `bloc_test`, the API is very similar:

```dart
// bloc_test
blocTest<MyBloc, MyState>(
  'description',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [MyState()],
);

// velo_test
veloTest<MyVelo, MyState>(
  'description',
  build: () => MyVelo(),
  act: (velo) => velo.doSomething(),
  expect: () => [MyState()],
);
```

### Key Differences
- `act` receives the Velo instance directly (no events)
- Enhanced error handling and cleanup
- Built-in memory management
- More comprehensive utility functions

## Documentation

For more detailed documentation and examples, visit our [GitHub repository](https://github.com/steve-nosse/velo).

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.