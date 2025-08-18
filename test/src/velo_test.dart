import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Velo', () {
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
      notifier
        ..addListener(() => emissionCount++)
        ..emit(const CounterState());
      expect(emissionCount, 0);

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

    test('should handle null state properly', () {
      expect(() => notifier.emit(notifier.state), returnsNormally);
    });

    test('should not emit same Equatable state twice', () {
      var emissionCount = 0;
      notifier.addListener(() => emissionCount++);

      final initialState = notifier.state;

      notifier.emit(initialState);
      expect(emissionCount, 0);

      notifier.emit(const CounterState());
      expect(emissionCount, 0);
    });

    test('should handle concurrent async operations', () async {
      final futures = <Future<void>>[];

      for (int i = 0; i < 5; i++) {
        futures.add(notifier.incrementAsync());
      }

      await Future.wait(futures);

      expect(notifier.state.count, 5);
    });

    test('should maintain state consistency during rapid emissions', () {
      var emissionCount = 0;
      notifier.addListener(() => emissionCount++);

      for (int i = 1; i <= 100; i++) {
        notifier.emit(CounterState(count: i));
      }

      expect(notifier.state.count, 100);
      expect(emissionCount, 100);
    });

    test('should notify listeners on state change', () {
      var notificationCount = 0;
      notifier
        ..addListener(() => notificationCount++)
        ..increment();
      expect(notificationCount, 1);

      notifier.increment();
      expect(notificationCount, 2);
    });
  });

  group('Velo with non-Equatable state', () {
    late SimpleNotifier notifier;

    setUp(() {
      notifier = SimpleNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should emit only when state actually changes', () {
      var emissionCount = 0;
      notifier
        ..addListener(() => emissionCount++)
        ..setValue(0);
      expect(emissionCount, 0);

      notifier.setValue(1);
      expect(emissionCount, 1);
    });
  });
}
