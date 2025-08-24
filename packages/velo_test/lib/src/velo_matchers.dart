import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';

/// Custom matchers for Velo testing.
class VeloMatchers {
  /// Private constructor to prevent instantiation
  VeloMatchers._();

  /// Matches when a Velo notifier emits the expected states in order.
  static Matcher emitsInOrder<S>(List<S> expectedStates) {
    ArgumentError.checkNotNull(expectedStates, 'expectedStates');
    return _EmitsInOrderMatcher<S>(expectedStates);
  }

  /// Matches when a Velo notifier emits any of the expected states.
  static Matcher emitsAnyOf<S>(List<S> expectedStates) {
    ArgumentError.checkNotNull(expectedStates, 'expectedStates');
    if (expectedStates.isEmpty) {
      throw ArgumentError.value(expectedStates, 'expectedStates', 'Cannot be empty');
    }
    return _EmitsAnyOfMatcher<S>(expectedStates);
  }

  /// Matches when a Velo notifier's current state equals the expected state.
  static Matcher hasState<S>(S expectedState) {
    ArgumentError.checkNotNull(expectedState, 'expectedState');
    return _HasStateMatcher<S>(expectedState);
  }

  /// Matches when a Velo notifier emits exactly the expected number of states.
  static Matcher emitsCount(int expectedCount) {
    ArgumentError.checkNotNull(expectedCount, 'expectedCount');
    if (expectedCount < 0) {
      throw ArgumentError.value(expectedCount, 'expectedCount', 'Cannot be negative');
    }
    return _EmitsCountMatcher(expectedCount);
  }

  /// Matches when a Velo notifier emits states that satisfy the given predicate.
  static Matcher emitsWhere<S>(bool Function(S state) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    return _EmitsWhereMatcher<S>(predicate);
  }
}

/// Matcher that checks if states are emitted in the expected order.
class _EmitsInOrderMatcher<S> extends Matcher {
  const _EmitsInOrderMatcher(this.expectedStates);
  
  final List<S> expectedStates;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! List<S>) {
      matchState['error'] = 'Expected List<$S> but got ${item.runtimeType}';
      return false;
    }
    
    if (item.length != expectedStates.length) {
      matchState['error'] = 
          'Expected ${expectedStates.length} states but got ${item.length}';
      return false;
    }
    
    for (int i = 0; i < expectedStates.length; i++) {
      if (item[i] != expectedStates[i]) {
        matchState['error'] = 
            'State at index $i: expected ${expectedStates[i]} but got ${item[i]}';
        return false;
      }
    }
    
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('emits states in order: $expectedStates');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final error = matchState['error'];
    if (error != null) {
      return mismatchDescription.add(error.toString());
    }
    return mismatchDescription.add('emitted: $item');
  }
}

/// Matcher that checks if any of the expected states are emitted.
class _EmitsAnyOfMatcher<S> extends Matcher {

  const _EmitsAnyOfMatcher(this.expectedStates);
  final List<S> expectedStates;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! List<S>) return false;
    
    return item.any((state) => expectedStates.contains(state));
  }

  @override
  Description describe(Description description) => description.add('emits any of: $expectedStates');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) => mismatchDescription.add('emitted: $item');
}

/// Matcher that checks if a Velo notifier has the expected current state.
class _HasStateMatcher<S> extends Matcher {

  const _HasStateMatcher(this.expectedState);
  final S expectedState;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! Velo<S>) return false;
    
    return item.state == expectedState;
  }

  @override
  Description describe(Description description) => description.add('has state: $expectedState');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Velo<S>) {
      return mismatchDescription.add('has state: ${item.state}');
    }
    return mismatchDescription.add('is not a Velo notifier');
  }
}

/// Matcher that checks if the expected number of states are emitted.
class _EmitsCountMatcher extends Matcher {

  const _EmitsCountMatcher(this.expectedCount);
  final int expectedCount;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! List) return false;
    
    return item.length == expectedCount;
  }

  @override
  Description describe(Description description) => description.add('emits $expectedCount states');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is List) {
      return mismatchDescription.add('emitted ${item.length} states');
    }
    return mismatchDescription.add('is not a list of states');
  }
}

/// Matcher that checks if emitted states satisfy a predicate.
class _EmitsWhereMatcher<S> extends Matcher {

  const _EmitsWhereMatcher(this.predicate);
  final bool Function(S state) predicate;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! List<S>) return false;
    
    return item.every(predicate);
  }

  @override
  Description describe(Description description) => description.add('emits states that satisfy the predicate');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) => mismatchDescription.add('emitted: $item');
}

/// Utility functions for Velo testing.
class VeloTestUtils {
  /// Private constructor to prevent instantiation
  VeloTestUtils._();

  /// Waits for a Velo notifier to emit a specific state.
  static Future<void> waitForState<S>(
    Velo<S> velo,
    S expectedState, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    ArgumentError.checkNotNull(velo, 'velo');
    ArgumentError.checkNotNull(expectedState, 'expectedState');
    ArgumentError.checkNotNull(timeout, 'timeout');

    if (timeout.isNegative) {
      throw ArgumentError.value(timeout, 'timeout', 'Cannot be negative');
    }

    if (velo.state == expectedState) return;
    
    final completer = Completer<void>();
    late void Function() listener;
    Timer? timeoutTimer;
    
    listener = () {
      try {
        if (velo.state == expectedState) {
          velo.removeListener(listener);
          timeoutTimer?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      } catch (error) {
        velo.removeListener(listener);
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }
    };
    
    velo.addListener(listener);
    
    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      velo.removeListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'Timed out waiting for state: $expectedState after ${timeout.inMilliseconds}ms',
            timeout,
          ),
        );
      }
    });
    
    return completer.future;
  }

  /// Waits for a Velo notifier to emit any state that satisfies the predicate.
  static Future<S> waitForStateWhere<S>(
    Velo<S> velo,
    bool Function(S state) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (predicate(velo.state)) return velo.state;
    
    final completer = Completer<S>();
    late void Function() listener;
    
    listener = () {
      if (predicate(velo.state)) {
        velo.removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete(velo.state);
        }
      }
    };
    
    velo.addListener(listener);
    
    // Set up timeout
    Timer(timeout, () {
      velo.removeListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'Timed out waiting for state matching predicate',
            timeout,
          ),
        );
      }
    });
    
    return completer.future;
  }

  /// Collects all states emitted by a Velo notifier during the execution of an action.
  static Future<List<S>> collectStates<S>(
    Velo<S> velo,
    Future<void> Function() action,
  ) async {
    final states = <S>[];
    
    void listener() {
      states.add(velo.state);
    }
    
    velo.addListener(listener);
    
    try {
      await action();
      return states;
    } finally {
      velo.removeListener(listener);
    }
  }
}