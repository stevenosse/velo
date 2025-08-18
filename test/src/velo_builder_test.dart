import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VeloBuilder', () {
    testWidgets('should build widget with state', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloBuilder<CounterNotifier, CounterState>(
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

    testWidgets('should show loading widget on builder error', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloBuilder<CounterNotifier, CounterState>(
            loadingWidget: const Text('Loading'),
            builder: (context, state) {
              throw Exception('Builder error');
            },
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should handle missing notifier gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VeloBuilder<CounterNotifier, CounterState>(
            loadingWidget: Text('No Notifier'),
            builder: buildText,
          ),
        ),
      );

      expect(find.text('No Notifier'), findsOneWidget);
    });

    testWidgets('should handle notifier disposal during build', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloBuilder<CounterNotifier, CounterState>(
            loadingWidget: const Text('Loading'),
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      notifier.dispose();
      await tester.pump();

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should rebuild when notifier changes', (tester) async {
      final notifier1 = CounterNotifier();
      final notifier2 = CounterNotifier()..increment();

      Widget buildWithNotifier(CounterNotifier notifier) => createTestWidget(
            counterNotifier: notifier,
            child: VeloBuilder<CounterNotifier, CounterState>(
              builder: (context, state) => Text('Count: ${state.count}'),
            ),
          );

      await tester.pumpWidget(buildWithNotifier(notifier1));
      expect(find.text('Count: 0'), findsOneWidget);

      await tester.pumpWidget(buildWithNotifier(notifier2));
      expect(find.text('Count: 1'), findsOneWidget);

      notifier1.dispose();
      notifier2.dispose();
    });

    testWidgets('should handle loading state properly', (tester) async {
      final notifier = CounterNotifier();

      await tester.pumpWidget(
        createTestWidget(
          counterNotifier: notifier,
          child: VeloBuilder<CounterNotifier, CounterState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const CircularProgressIndicator();
              }
              return Text('Count: ${state.count}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      notifier.setLoading(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('should pass notifier directly when provided', (tester) async {
      final notifier = CounterNotifier()..increment();

      await tester.pumpWidget(
        MaterialApp(
          home: VeloBuilder<CounterNotifier, CounterState>(
            notifier: notifier,
            builder: (context, state) => Text('Count: ${state.count}'),
          ),
        ),
      );

      expect(find.text('Count: 1'), findsOneWidget);

      notifier.dispose();
    });
  });
}
