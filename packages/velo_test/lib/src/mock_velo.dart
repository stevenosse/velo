import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';

/// A mock implementation of [Velo] for testing purposes.
///
/// This class provides additional testing capabilities such as:
/// - State history tracking
/// - Emission verification
/// - Custom state injection
class MockVelo<T> extends Velo<T> {
  MockVelo(super.initialState);

  /// List of all states that have been emitted, including the initial state.
  final List<T> stateHistory = [];

  /// List of all states that have been emitted (excluding initial state).
  List<T> get emittedStates => stateHistory.skip(1).toList();

  @override
  void emit(T state) {
    stateHistory.add(state);
    super.emit(state);
  }

  /// Verifies that the specified state was emitted.
  void verifyStateEmitted(T expectedState) {
    expect(
      stateHistory.contains(expectedState),
      isTrue,
      reason: 'Expected state $expectedState was not emitted',
    );
  }

  /// Verifies that states were emitted in the specified order.
  void verifyStatesEmittedInOrder(List<T> expectedStates) {
    expect(
      emittedStates,
      equals(expectedStates),
      reason: 'States were not emitted in the expected order',
    );
  }

  /// Verifies that no states have been emitted (only initial state exists).
  void verifyNoStatesEmitted() {
    expect(
      emittedStates,
      isEmpty,
      reason: 'Expected no states to be emitted, but found: $emittedStates',
    );
  }

  /// Clears the state history.
  void clearHistory() {
    stateHistory
      ..clear()
      ..add(state); // Re-add current state
  }

  /// Gets the number of times a specific state was emitted.
  int getEmissionCount(T targetState) =>
      stateHistory.where((state) => state == targetState).length;
}
