import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

/// A simple counter state for testing purposes.
class CounterState extends Equatable {
  const CounterState({this.count = 0, this.isLoading = false, this.error});

  final int count;
  final bool isLoading;
  final String? error;

  CounterState copyWith({int? count, bool? isLoading, String? error}) =>
      CounterState(
        count: count ?? this.count,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [count, isLoading, error];
}

/// A simple state class without Equatable for testing.
class SimpleState {
  const SimpleState(this.value);
  final int value;

  @override
  bool operator ==(Object other) =>
      other is SimpleState && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// A test Velo implementation for counter functionality.
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  void setError(String? error) {
    emit(state.copyWith(error: error));
  }

  Future<void> incrementAsync() async {
    await emitAsync(
      Future.delayed(
        const Duration(milliseconds: 100),
        () => state.copyWith(count: state.count + 1),
      ),
    );
  }

  Future<void> incrementAsyncWithError() async {
    await emitAsync(
      Future.delayed(
        const Duration(milliseconds: 100),
        () => throw Exception('Async error'),
      ),
    );
  }
}

/// A simple test Velo implementation.
class SimpleVelo extends Velo<SimpleState> {
  SimpleVelo() : super(const SimpleState(0));

  void setValue(int value) {
    emit(SimpleState(value));
  }
}

/// Helper function to build a text widget from counter state.
Widget buildText(BuildContext context, CounterState state) =>
    Text('Count: ${state.count}');

/// Creates a test widget with the necessary providers.
Widget createTestWidget({
  required Widget child,
  CounterVelo? counterVelo,
  SimpleVelo? simpleVelo,
}) => MaterialApp(
  home: MultiProvider(
    providers: [
      if (counterVelo != null)
        ChangeNotifierProvider<CounterVelo>.value(value: counterVelo),
      if (simpleVelo != null)
        ChangeNotifierProvider<SimpleVelo>.value(value: simpleVelo),
    ],
    child: child,
  ),
);

/// Pumps a widget and waits for all animations and microtasks to complete.
Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Waits for a specific condition to be true with a timeout.
Future<void> waitForCondition(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final stopwatch = Stopwatch()..start();

  while (!condition() && stopwatch.elapsed < timeout) {
    await Future<void>.delayed(interval);
  }

  if (!condition()) {
    throw Exception('Condition was not met within ${timeout.inMilliseconds}ms');
  }
}
