import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:equatable/equatable.dart';
import 'package:velo/velo.dart';

// Helper function for tests
Widget _buildText(BuildContext context, CounterState state) {
  return Text('Count: ${state.count}');
}

// Test state classes
class CounterState extends Equatable {
  final int count;
  final bool isLoading;
  final String? error;

  const CounterState({
    this.count = 0,
    this.isLoading = false,
    this.error,
  });

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [count, isLoading, error];
}

class SimpleState {
  final int value;
  const SimpleState(this.value);

  @override
  bool operator ==(Object other) {
    return other is SimpleState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

// Test notifiers
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

void main() {
  group('StateNotifier', () {
    late CounterNotifier notifier;

    setUp(() {
      notifier = CounterNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should initialize with correct initial state', () {
      expect(notifier.state, const CounterState());
      expect(notifier.state.count, 0);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });

    test('should emit new state correctly', () {
      notifier.increment();
      expect(notifier.state.count, 1);

      notifier.decrement();
      expect(notifier.state.count, 0);
    });

    test('should not emit if state is equal (Equatable)', () {
      var emissionCount = 0;
      notifier.addListener(() => emissionCount++);

      // Emit same state
      notifier.emit(const CounterState());
      expect(emissionCount, 0);

      // Emit different state
      notifier.increment();
      expect(emissionCount, 1);
    });

    test('should handle async operations', () async {
      await notifier.incrementAsync();
      expect(notifier.state.count, 1);
    });

    test('should rethrow async errors', () async {
      expect(
        () => notifier.incrementAsyncWithError(),
        throwsA(isA<Exception>()),
      );
    });

    test('should notify listeners on state change', () {
      var notificationCount = 0;
      notifier.addListener(() => notificationCount++);

      notifier.increment();
      expect(notificationCount, 1);

      notifier.increment();
      expect(notificationCount, 2);
    });
  });



  group('StateNotifier with non-Equatable state', () {
    late SimpleNotifier notifier;

    setUp(() {
      notifier = SimpleNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should emit only when state actually changes', () {
      var emissionCount = 0;
      notifier.addListener(() => emissionCount++);

      // Emit same state
      notifier.setValue(0);
      expect(emissionCount, 0);

      // Emit different state
      notifier.setValue(1);
      expect(emissionCount, 1);
    });
  });

  group('StateNotifierBuilder', () {
    testWidgets('should build widget with state', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CounterNotifier>.value(
            value: notifier,
            child: StateNotifierBuilder<CounterNotifier, CounterState>(
              builder: (context, state) {
                return Text('Count: ${state.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should show loading widget on builder error', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CounterNotifier>.value(
            value: notifier,
            child: StateNotifierBuilder<CounterNotifier, CounterState>(
              loadingWidget: const Text('Loading'),
              builder: (context, state) {
                throw Exception('Builder error');
              },
            ),
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should handle missing notifier gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StateNotifierBuilder<CounterNotifier, CounterState>(
            loadingWidget: Text('No Notifier'),
            builder: _buildText,
          ),
        ),
      );

      expect(find.text('No Notifier'), findsOneWidget);
    });
  });

  group('StateNotifierListener', () {
    testWidgets('should call listener on state change', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;
      CounterState? lastState;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CounterNotifier>.value(
            value: notifier,
            child: StateNotifierListener<CounterNotifier, CounterState>(
              listener: (context, state) {
                listenerCallCount++;
                lastState = state;
              },
              child: const Text('Child'),
            ),
          ),
        ),
      );

      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(listenerCallCount, 1);
      expect(lastState?.count, 1);

      notifier.dispose();
    });

    testWidgets('should not call listener for equal states', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CounterNotifier>.value(
            value: notifier,
            child: StateNotifierListener<CounterNotifier, CounterState>(
              listener: (context, state) {
                listenerCallCount++;
              },
              child: const Text('Child'),
            ),
          ),
        ),
      );

      // Emit same state
      notifier.emit(const CounterState());
      await tester.pump();

      expect(listenerCallCount, 0);

      notifier.dispose();
    });
  });

  group('StateNotifierConsumer', () {
    testWidgets('should build and listen to state changes', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CounterNotifier>.value(
            value: notifier,
            child: StateNotifierConsumer<CounterNotifier, CounterState>(
              listener: (context, state) {
                listenerCallCount++;
              },
              builder: (context, state) {
                return Text('Count: ${state.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(listenerCallCount, 1);

      notifier.dispose();
    });
  });

  group('MultiStateNotifierListener', () {
    testWidgets('should provide multiple listeners', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = SimpleNotifier();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiStateNotifierListener(
            listeners: [
              ChangeNotifierProvider<CounterNotifier>.value(value: notifier1),
              ChangeNotifierProvider<SimpleNotifier>.value(value: notifier2),
            ],
            child: Builder(
              builder: (context) {
                final counter = context.read<CounterNotifier>();
                final simple = context.read<SimpleNotifier>();
                return Text('Counter: ${counter.state.count}, Simple: ${simple.state.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Counter: 0, Simple: 0'), findsOneWidget);

      notifier1.dispose();
      notifier2.dispose();
    });
  });
}