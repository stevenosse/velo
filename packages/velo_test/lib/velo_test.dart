/// Testing utilities for the Velo state management package.
///
/// This package provides helpful utilities and mock classes for testing
/// applications that use Velo for state management.
///
/// ## Features
///
/// - Mock Velo classes for testing
/// - Test helpers for common testing scenarios
/// - Widget testing utilities
/// - State verification helpers
/// - veloTest function similar to blocTest
/// - Custom matchers for Velo testing
///
/// ## Usage
///
/// ```dart
/// import 'package:velo_test/velo_test.dart';
/// import 'package:flutter_test/flutter_test.dart';
///
/// void main() {
///   group('CounterVelo', () {
///     veloTest<CounterVelo, int>(
///       'emits [1] when increment is called',
///       build: () => CounterVelo(),
///       act: (velo) => velo.increment(),
///       expect: () => [1],
///     );
///
///     veloTest<CounterVelo, int>(
///       'emits [1, 2, 3] when increment is called 3 times',
///       build: () => CounterVelo(),
///       act: (velo) async {
///         velo.increment();
///         velo.increment();
///         velo.increment();
///       },
///       expect: () => [1, 2, 3],
///     );
///   });
/// }
/// ```
library;

// Convenience functions for easier access to matchers
import 'package:flutter_test/flutter_test.dart';
import 'src/velo_matchers.dart';

export 'src/mock_velo.dart';
export 'src/test_helpers.dart';
export 'src/velo_matchers.dart';
export 'src/velo_test.dart';
export 'src/widget_test_helpers.dart';

/// Matches when a Velo notifier emits the expected states in order.
Matcher emitsInOrder<S>(List<S> expectedStates) =>
    VeloMatchers.emitsInOrder<S>(expectedStates);

/// Matches when a Velo notifier emits any of the expected states.
Matcher emitsAnyOf<S>(List<S> expectedStates) =>
    VeloMatchers.emitsAnyOf<S>(expectedStates);

/// Matches when a Velo notifier's current state equals the expected state.
Matcher hasState<S>(S expectedState) => VeloMatchers.hasState<S>(expectedState);

/// Matches when a Velo notifier emits exactly the expected number of states.
Matcher emitsCount(int expectedCount) => VeloMatchers.emitsCount(expectedCount);

/// Matches when a Velo notifier emits states that satisfy the given predicate.
Matcher emitsWhere<S>(bool Function(S state) predicate) =>
    VeloMatchers.emitsWhere<S>(predicate);
