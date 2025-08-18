import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

Widget buildText(BuildContext context, CounterState state) => Text('Count: ${state.count}');

class CounterState extends Equatable {

  const CounterState({
    this.count = 0,
    this.isLoading = false,
    this.error,
  });
  final int count;
  final bool isLoading;
  final String? error;

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) => CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );

  @override
  List<Object?> get props => [count, isLoading, error];
}

class SimpleState {
  const SimpleState(this.value);
  final int value;

  @override
  bool operator ==(Object other) => other is SimpleState && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class CounterNotifier extends Velo<CounterState> {
  CounterNotifier() : super(const CounterState());

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
    await emitAsync(Future.delayed(
      const Duration(milliseconds: 100),
      () => state.copyWith(count: state.count + 1),
    ));
  }

  Future<void> incrementAsyncWithError() async {
    await emitAsync(Future.delayed(
      const Duration(milliseconds: 100),
      () => throw Exception('Async error'),
    ));
  }
}

class SimpleNotifier extends Velo<SimpleState> {
  SimpleNotifier() : super(const SimpleState(0));

  void setValue(int value) {
    emit(SimpleState(value));
  }
}

Widget createTestWidget({
  required Widget child,
  CounterNotifier? counterNotifier,
  SimpleNotifier? simpleNotifier,
}) => MaterialApp(
    home: MultiProvider(
      providers: [
        if (counterNotifier != null)
          ChangeNotifierProvider<CounterNotifier>.value(value: counterNotifier),
        if (simpleNotifier != null)
          ChangeNotifierProvider<SimpleNotifier>.value(value: simpleNotifier),
      ],
      child: child,
    ),
  );