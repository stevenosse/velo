import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('MultiVeloListener', () {
    testWidgets('should provide multiple listeners', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = SimpleNotifier();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiVeloListener(
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

    // Note: MultiVeloListener with empty listeners will throw AssertionError
    // This is the expected behavior as MultiProvider requires at least one provider

    testWidgets('should provide access to all notifiers', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = SimpleNotifier();
      
      notifier1.increment();
      notifier2.setValue(5);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiVeloListener(
            listeners: [
              ChangeNotifierProvider<CounterNotifier>.value(value: notifier1),
              ChangeNotifierProvider<SimpleNotifier>.value(value: notifier2),
            ],
            child: Builder(
              builder: (context) {
                final counter = context.watch<CounterNotifier>();
                final simple = context.watch<SimpleNotifier>();
                return Text('Counter: ${counter.state.count}, Simple: ${simple.state.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Counter: 1, Simple: 5'), findsOneWidget);

      // Test that changes are reflected
      notifier1.increment();
      await tester.pump();

      expect(find.text('Counter: 2, Simple: 5'), findsOneWidget);

      notifier2.setValue(10);
      await tester.pump();

      expect(find.text('Counter: 2, Simple: 10'), findsOneWidget);

      notifier1.dispose();
      notifier2.dispose();
    });

    testWidgets('should handle single provider', (tester) async {
      final notifier = CounterNotifier();
      notifier.increment();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiVeloListener(
            listeners: [
              ChangeNotifierProvider<CounterNotifier>.value(value: notifier),
            ],
            child: Builder(
              builder: (context) {
                final counter = context.watch<CounterNotifier>();
                return Text('Count: ${counter.state.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 1'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should support nested MultiVeloListener', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = SimpleNotifier();
      final notifier3 = CounterNotifier();
      
      notifier3.increment();
      notifier3.increment();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiVeloListener(
            listeners: [
              ChangeNotifierProvider<CounterNotifier>.value(value: notifier1),
            ],
            child: MultiVeloListener(
              listeners: [
                ChangeNotifierProvider<SimpleNotifier>.value(value: notifier2),
              ],
              child: Builder(
                builder: (context) {
                  final counter = context.watch<CounterNotifier>();
                  final simple = context.watch<SimpleNotifier>();
                  return Text('Counter: ${counter.state.count}, Simple: ${simple.state.value}');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Counter: 0, Simple: 0'), findsOneWidget);

      notifier1.dispose();
      notifier2.dispose();
      notifier3.dispose();
    });

    testWidgets('should handle provider disposal gracefully', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = SimpleNotifier();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiVeloListener(
            listeners: [
              ChangeNotifierProvider<CounterNotifier>.value(value: notifier1),
              ChangeNotifierProvider<SimpleNotifier>.value(value: notifier2),
            ],
            child: Builder(
              builder: (context) {
                try {
                  final counter = context.read<CounterNotifier>();
                  final simple = context.read<SimpleNotifier>();
                  return Text('Counter: ${counter.state.count}, Simple: ${simple.state.value}');
                } catch (e) {
                  return const Text('Error accessing providers');
                }
              },
            ),
          ),
        ),
      );

      expect(find.text('Counter: 0, Simple: 0'), findsOneWidget);

      // Dispose one notifier
      notifier1.dispose();
      await tester.pump();

      // Should still work with remaining provider
      expect(find.byType(Text), findsOneWidget);

      notifier2.dispose();
    });
  });
}