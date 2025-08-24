import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VeloListener', () {
    testWidgets('should call listener on state change', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;
      CounterState? lastState;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
              lastState = state;
            },
            child: const Text('Child'),
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
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
            },
            child: const Text('Child'),
          ),
        ),
      );

      notifier.emit(const CounterState());
      await tester.pump();

      expect(listenerCallCount, 0);

      notifier.dispose();
    });

    testWidgets('should handle listener errors gracefully', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              throw Exception('Listener error');
            },
            child: const Text('Child'),
          ),
        ),
      );

      expect(() {
        notifier.increment();
      }, returnsNormally);

      await tester.pump();
      expect(find.text('Child'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should work with provided notifier', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: VeloListener<CounterNotifier, CounterState>(
            notifier: notifier,
            listener: (context, state) {
              listenerCallCount++;
            },
            child: const Text('Child'),
          ),
        ),
      );

      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(listenerCallCount, 1);

      notifier.dispose();
    });

    testWidgets('should continue listening after widget update',
        (tester) async {
      final notifier = CounterNotifier();

      var listenerCallCount = 0;
      CounterState? lastState;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
              lastState = state;
            },
            child: const Text('Child'),
          ),
        ),
      );

      expect(listenerCallCount, 0);

      notifier.increment();
      await tester.pump();

      expect(listenerCallCount, 1);
      expect(lastState?.count, 1);

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
              lastState = state;
            },
            child: const Text('Child Updated'),
          ),
        ),
      );

      notifier.increment();
      await tester.pump();

      expect(listenerCallCount, 2);
      expect(lastState?.count, 2);

      notifier.dispose();
    });

    testWidgets('should handle disposal correctly', (tester) async {
      final notifier = CounterNotifier();
      var listenerCallCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloListener<CounterNotifier, CounterState>(
            listener: (context, state) {
              listenerCallCount++;
            },
            child: const Text('Child'),
          ),
        ),
      );

      notifier.increment();
      await tester.pump();
      expect(listenerCallCount, 1);

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: const Text('No Listener'),
        ),
      );

      notifier.increment();
      await tester.pump();
      expect(listenerCallCount, 1);

      notifier.dispose();
    });
  });
}
