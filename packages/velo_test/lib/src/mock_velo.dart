import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';

/// A mock implementation of [Velo] for testing purposes.
///
/// This class provides additional testing capabilities such as:
/// - State history tracking
/// - Emission verification
/// - Custom state injection
/// - Automatic memory management
class MockVelo<T> extends Velo<T> {
  MockVelo(super.initialState) {
    _addInitialStateToHistory();
  }

  /// Maximum number of states to keep in history (prevents memory leaks)
  static const int _maxHistorySize = 10000;

  /// List of all states that have been emitted, including the initial state.
  final List<T> _stateHistory = <T>[];

  /// Whether the mock has been disposed
  bool _disposed = false;

  /// List of all states that have been emitted, including the initial state.
  /// Returns a copy to prevent external modification.
  List<T> get stateHistory {
    _checkNotDisposed();
    return List<T>.unmodifiable(_stateHistory);
  }

  /// List of all states that have been emitted (excluding initial state).
  /// Returns a copy to prevent external modification.
  List<T> get emittedStates {
    _checkNotDisposed();
    return _stateHistory.length > 1 
        ? List<T>.unmodifiable(_stateHistory.skip(1)) 
        : <T>[];
  }

  void _addInitialStateToHistory() {
    if (_stateHistory.isEmpty) {
      _stateHistory.add(state);
    }
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('MockVelo has been disposed and cannot be used');
    }
  }

  void _trimHistoryIfNeeded() {
    // Keep history size manageable to prevent memory leaks
    if (_stateHistory.length > _maxHistorySize) {
      // Remove oldest states but keep some history
      const keepCount = _maxHistorySize ~/ 2;
      final statesToKeep = _stateHistory.skip(_stateHistory.length - keepCount).toList();
      _stateHistory
        ..clear()
        ..addAll(statesToKeep);
    }
  }

  @override
  void emit(T state) {
    _checkNotDisposed();
    _stateHistory.add(state);
    _trimHistoryIfNeeded();
    super.emit(state);
  }

  /// Verifies that the specified state was emitted.
  void verifyStateEmitted(T expectedState) {
    _checkNotDisposed();
    expect(
      _stateHistory.contains(expectedState),
      isTrue,
      reason: 'Expected state $expectedState was not emitted',
    );
  }

  /// Verifies that states were emitted in the specified order.
  void verifyStatesEmittedInOrder(List<T> expectedStates) {
    _checkNotDisposed();
    expect(
      emittedStates,
      equals(expectedStates),
      reason: 'States were not emitted in the expected order',
    );
  }

  /// Verifies that no states have been emitted (only initial state exists).
  void verifyNoStatesEmitted() {
    _checkNotDisposed();
    expect(
      emittedStates,
      isEmpty,
      reason: 'Expected no states to be emitted, but found: $emittedStates',
    );
  }

  /// Clears the state history while keeping the current state.
  void clearHistory() {
    _checkNotDisposed();
    _stateHistory
      ..clear()
      ..add(state); // Re-add current state
  }

  /// Gets the number of times a specific state was emitted.
  int getEmissionCount(T targetState) {
    _checkNotDisposed();
    return _stateHistory.where((state) => state == targetState).length;
  }

  /// Gets the history size for memory monitoring.
  int get historySize {
    _checkNotDisposed();
    return _stateHistory.length;
  }

  /// Gets whether the history size is approaching the limit.
  bool get isHistoryNearLimit => historySize > _maxHistorySize * 0.8;

  @override
  void dispose() {
    if (!_disposed) {
      _stateHistory.clear();
      _disposed = true;
      super.dispose();
    }
  }
}
