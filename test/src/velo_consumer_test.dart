import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VeloConsumer', () {
    testWidgets('should build and listen to state changes', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloConsumer<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
            },
            builder: (context, state) => Text('Count: ${state.count}'),
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

    testWidgets('should handle listener errors gracefully', (tester) async {
      final notifier = CounterNotifier();
      var builderCallCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloConsumer<CounterNotifier, CounterState>(
            listener: (context, state) {
              throw Exception('Listener error');
            },
            builder: (context, state) {
              builderCallCount++;
              return Text('Count: ${state.count}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(builderCallCount, 1);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(builderCallCount, 2);

      notifier.dispose();
    });

    testWidgets('should handle notifier change in didUpdateWidget',
        (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = CounterNotifier()
        ..increment()
        ..increment();

      var listenerCallCount = 0;
      CounterState? lastListenerState;

      Widget buildWithNotifier(CounterNotifier notifier) => createTestWidget(
            counterNotifier: notifier,
            child: VeloConsumer<CounterNotifier, CounterState>(
              listener: (context, state) {
                listenerCallCount++;
                lastListenerState = state;
              },
              builder: (context, state) => Text('Count: ${state.count}'),
            ),
          );

      await tester.pumpWidget(buildWithNotifier(notifier1));
      expect(find.text('Count: 0'), findsOneWidget);

      await tester.pumpWidget(buildWithNotifier(notifier2));
      expect(find.text('Count: 2'), findsOneWidget);

      expect(listenerCallCount, 1);
      expect(lastListenerState?.count, 2);

      notifier1.dispose();
      notifier2.dispose();
    });

    testWidgets('should not call listener for same state', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloConsumer<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
            },
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(listenerCallCount, 0);

      notifier.emit(const CounterState());
      await tester.pump();

      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(listenerCallCount, 1);

      notifier.dispose();
    });

    testWidgets('should work with provided notifier', (tester) async {
      final notifier = CounterNotifier()..increment();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: VeloConsumer<CounterNotifier, CounterState>(
            notifier: notifier,
            listener: (context, state) {
              listenerCallCount++;
            },
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(find.text('Count: 1'), findsOneWidget);
      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 2'), findsOneWidget);
      expect(listenerCallCount, 1);

      notifier.dispose();
    });

    testWidgets('should work without null listener parameter', (tester) async {
      final notifier = CounterNotifier();

      // Test VeloConsumer works when listener is not provided
      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloConsumer<CounterNotifier, CounterState>(
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should handle null listener gracefully', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloConsumer<CounterNotifier, CounterState>(
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      notifier.dispose();
    });
  });
}
