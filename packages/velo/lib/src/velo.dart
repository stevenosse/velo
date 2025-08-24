import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A state management class that extends [ValueNotifier] with [Equatable] support.
///
/// Velo provides a simple and efficient way to manage state in Flutter applications,
/// inspired by `flutter_bloc`'s Cubit but with a lighter footprint.
///
/// **Key features:**
/// - Built on Flutter's native [ValueNotifier]
/// - Efficient state comparison using [Equatable]
/// - Simple emit-based state updates
/// - Async state operations support
///
/// **Example:**
/// ```dart
/// class CounterState extends Equatable {
///   final int count;
///   const CounterState({this.count = 0});
///
///   @override
///   List<Object?> get props => [count];
///
///   CounterState copyWith({int? count}) {
///     return CounterState(count: count ?? this.count);
///   }
/// }
///
/// class CounterVelo extends Velo<CounterState> {
///   CounterVelo() : super(const CounterState());
///
///   void increment() {
///     emit(state.copyWith(count: state.count + 1));
///   }
/// }
/// ```
///
/// **Usage with widgets:**
/// ```dart
/// VeloBuilder<CounterVelo, CounterState>(
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
abstract class Velo<S> extends ValueNotifier<S> {
  Velo(super.state);

  /// Gets the current state.
  ///
  /// This is a getter that returns the current value from the underlying [ValueNotifier].
  S get state => super.value;

  /// Emits a new state if it's different from the current state.
  ///
  /// For states that implement [Equatable], the comparison is done using the
  /// `==` operator which respects [Equatable]'s implementation.
  /// For other states, direct comparison is used.
  ///
  /// This method only triggers listeners if the new state is actually different.
  ///
  /// **Example:**
  /// ```dart
  /// emit(state.copyWith(count: state.count + 1));
  /// ```
  void emit(S state) {
    if (state is Equatable && value is Equatable) {
      if (state != value) {
        value = state;
      }
    } else if (state != value) {
      value = state;
    }
  }

  /// Emits a state from a [Future].
  ///
  /// This method waits for the [futureState] to complete and then emits the result.
  /// If the [Future] completes with an error, the error is rethrown.
  ///
  /// **Example:**
  /// ```dart
  /// Future<void> loadData() async {
  ///   await emitAsync(fetchDataFromApi().then(
  ///     (data) => state.copyWith(data: data, isLoading: false)
  ///   ));
  /// }
  /// ```
  Future<void> emitAsync(Future<S> futureState) async {
    try {
      final newState = await futureState;
      emit(newState);
    } catch (error) {
      // Let the concrete implementation handle errors
      rethrow;
    }
  }
}
