import 'package:flutter_test/flutter_test.dart';
import 'package:velo/velo.dart';
import 'package:velo_test/velo_test.dart';

// Test Velo for testing purposes
class TestCounterVelo extends Velo<int> {
  TestCounterVelo() : super(0);

  void increment() {
    emit(state + 1);
  }

  void incrementBy(int value) {
    emit(state + value);
  }

  Future<void> incrementAsync() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    increment();
  }

  void emitSequence(List<int> values) {
    for (var value in values) {
      emit(value);
    }
  }
}

void main() {
  group('Custom Matchers', () {
    late TestCounterVelo velo;

    setUp(() {
      velo = TestCounterVelo();
    });

    tearDown(() {
      velo.dispose();
    });

    group('emitsInOrder', () {
      test('should pass when states are emitted in correct order', () async {
        velo.emitSequence([1, 2, 3]);
        
        // Wait a bit for all emissions to complete
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsInOrder([1, 2, 3]));
      });

      test('should fail when states are emitted in wrong order', () async {
        velo.emitSequence([3, 1, 2]);
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(
          () => expect(velo, VeloMatchers.emitsInOrder([1, 2, 3])),
          throwsA(isA<TestFailure>()),
        );
      });

      test('should handle empty list', () async {
        expect(velo, VeloMatchers.emitsInOrder(<int>[])); // Should pass for no emissions
      });
    });

    group('emitsAnyOf', () {
      test('should pass when any expected state is emitted', () async {
        velo.increment(); // emits 1
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsAnyOf([1, 5, 10]));
      });

      test('should fail when none of expected states are emitted', () async {
        velo.increment(); // emits 1
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(
          () => expect(velo, VeloMatchers.emitsAnyOf([5, 10, 15])),
          throwsA(isA<TestFailure>()),
        );
      });
    });

    group('hasState', () {
      test('should pass when velo has the expected state', () {
        velo.increment(); // state becomes 1
        
        expect(velo, VeloMatchers.hasState(1));
      });

      test('should fail when velo does not have the expected state', () {
        velo.increment(); // state becomes 1
        
        expect(
          () => expect(velo, VeloMatchers.hasState(5)),
          throwsA(isA<TestFailure>()),
        );
      });
    });

    group('emitsCount', () {
      test('should pass when exact number of states are emitted', () async {
        velo.emitSequence([1, 2, 3]); // 3 emissions
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsCount(3));
      });

      test('should fail when different number of states are emitted', () async {
        velo.emitSequence([1, 2]); // 2 emissions
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(
          () => expect(velo, VeloMatchers.emitsCount(3)),
          throwsA(isA<TestFailure>()),
        );
      });

      test('should handle zero emissions', () async {
        // No emissions
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsCount(0));
      });
    });

    group('emitsWhere', () {
      test('should pass when emitted states match predicate', () async {
        velo.emitSequence([2, 4, 6]); // all even numbers
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsWhere((state) => (state as int) % 2 == 0));
      });

      test('should fail when emitted states do not match predicate', () async {
        velo.emitSequence([1, 3, 5]); // all odd numbers
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(
          () => expect(velo, VeloMatchers.emitsWhere((state) => (state as int) % 2 == 0)),
          throwsA(isA<TestFailure>()),
        );
      });

      test('should handle complex predicates', () async {
        velo.emitSequence([10, 20, 30]); // all greater than 5
        
        await Future<void>.delayed(const Duration(milliseconds: 10));
        
        expect(velo, VeloMatchers.emitsWhere((state) => (state as int) > 5));
      });
    });
  });

  group('Matcher Edge Cases', () {
    late TestCounterVelo velo;

    setUp(() {
      velo = TestCounterVelo();
    });

    tearDown(() {
      velo.dispose();
    });

    test('should handle rapid state changes', () async {
      // Emit states rapidly
      for (int i = 1; i <= 100; i++) {
        velo.emit(i);
      }
      
      await Future<void>.delayed(const Duration(milliseconds: 50));
      
      expect(velo, VeloMatchers.hasState(100));
      expect(velo, VeloMatchers.emitsCount(100));
    });

    test('should handle duplicate state emissions', () async {
      velo.emitSequence([1, 1, 1, 2, 2]);
      
      await Future<void>.delayed(const Duration(milliseconds: 10));
      
      expect(velo, VeloMatchers.emitsInOrder([1, 1, 1, 2, 2]));
      expect(velo, VeloMatchers.emitsCount(5));
      expect(velo, VeloMatchers.hasState(2));
    });

    test('should work with async state changes', () async {
      await velo.incrementAsync();
      
      // Wait for async operation to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));
      
      expect(velo, VeloMatchers.hasState(1));
      expect(velo, VeloMatchers.emitsCount(1));
    });
  });
}