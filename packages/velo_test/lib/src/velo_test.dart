import 'dart:async';

import 'package:flutter_test/flutter_test.dart' as test;
import 'package:meta/meta.dart';
import 'package:velo/velo.dart';

/// Tests a [Velo] by running [act] and asserting that the correct sequence
/// of states are emitted.
///
/// [build] should construct the [Velo] under test.
///
/// [seed] is an optional initial state which will be emitted before [act] is called.
///
/// [act] is an optional callback which will be invoked with the [Velo] under
/// test and should be used to interact with the [Velo].
///
/// [wait] is an optional [Duration] which can be used to wait for async operations
/// within the [Velo] under test such as debounce timers.
///
/// [expect] is an optional [Function] that returns a [test.Matcher] which the [Velo]
/// under test is expected to emit after [act] is executed.
///
/// [errors] is an optional [Function] that returns a [test.Matcher] which the [Velo]
/// under test is expected to throw after [act] is executed.
///
/// [skip] is an optional [int] which can be used to skip any number of states.
/// The default value is 0.
///
/// [verify] is an optional [bool] which determines whether to verify state
/// changes and errors. The default value is true.
///
/// [setUp] is an optional callback which will be invoked before the test.
///
/// [tearDown] is an optional callback which will be invoked after the test.
///
/// [tags] is optional and if it is passed, it declares user-defined tags
/// that are applied to the test. These tags can be used to select or skip
/// the test on the command line, or to do bulk test configuration.
///
/// [timeout] is optional and is used to specify a custom timeout for the test.
///
/// ```dart
/// veloTest<CounterVelo, int>(
///   'emits [1] when increment is called',
///   build: () => CounterVelo(),
///   act: (velo) => velo.increment(),
///   expect: () => [1],
/// );
/// ```
@isTest
void veloTest<V extends Velo<S>, S>(
  String description, {
  required V Function() build,
  S? seed,
  FutureOr<void> Function(V velo)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  dynamic Function()? errors,
  FutureOr<void> Function()? setUp,
  FutureOr<void> Function()? tearDown,
  FutureOr<void> Function(V velo)? verify,
  Map<String, dynamic>? tags,
  Duration? timeout,
}) {
  test.test(
    description,
    () async {
      await setUp?.call();

      late V velo;
      late List<S> states;
      late List<Object> veloErrors;

      try {
        velo = build();
        states = <S>[];
        veloErrors = <Object>[];

        if (seed != null) {
          velo.emit(seed);
        }

        // Listen to state changes using addListener
        void stateListener() {
          states.add(velo.state);
        }

        velo.addListener(stateListener);

        try {
          await act?.call(velo);
        } catch (error) {
          // Capture synchronous errors from act function
          veloErrors.add(error);
        }

        if (wait != null) {
          await Future<void>.delayed(wait);
        }

        try {
          if (expect != null) {
            final dynamic expected = expect();

            // Handle both actual states and matchers
            if (expected is List) {
              final List<S> actualStates = skip > 0
                  ? states.skip(skip).toList()
                  : states;

              // Check if the list contains matchers or actual values
              if (expected.isNotEmpty && expected.first is test.Matcher) {
                // Handle list of matchers
                final List<test.Matcher> matchers = expected
                    .cast<test.Matcher>();
                test.expect(
                  actualStates.length,
                  test.equals(matchers.length),
                  reason:
                      'Expected ${matchers.length} states but got ${actualStates.length}',
                );

                for (int i = 0; i < matchers.length; i++) {
                  test.expect(actualStates[i], matchers[i]);
                }
              } else {
                // Handle list of actual values
                final List<S> expectedStates = expected.cast<S>();
                test.expect(
                  actualStates,
                  test.equals(expectedStates),
                  reason:
                      'Expected states $expectedStates but got $actualStates',
                );
              }
            } else if (expected is test.Matcher) {
              // Handle single matcher
              final List<S> actualStates = skip > 0
                  ? states.skip(skip).toList()
                  : states;

              test.expect(
                actualStates.length,
                test.equals(1),
                reason: 'Expected 1 state but got ${actualStates.length}',
              );

              if (actualStates.isNotEmpty) {
                test.expect(actualStates.first, expected);
              }
            } else {
              // Handle single actual value or iterable
              final List<S> expectedStates = expected is Iterable<S>
                  ? expected.toList()
                  : <S>[expected as S];

              final List<S> actualStates = skip > 0
                  ? states.skip(skip).toList()
                  : states;

              test.expect(
                actualStates,
                test.equals(expectedStates),
                reason: 'Expected states $expectedStates but got $actualStates',
              );
            }
          }

          if (errors != null) {
            final dynamic expectedErrors = errors();
            final List<test.Matcher> expectedErrorMatchers =
                expectedErrors is List
                ? expectedErrors.cast<test.Matcher>()
                : expectedErrors is Iterable
                ? expectedErrors.cast<test.Matcher>().toList()
                : <test.Matcher>[expectedErrors as test.Matcher];

            test.expect(
              veloErrors.length,
              test.equals(expectedErrorMatchers.length),
              reason:
                  'Expected ${expectedErrorMatchers.length} errors but got ${veloErrors.length}',
            );

            for (int i = 0; i < expectedErrorMatchers.length; i++) {
              test.expect(veloErrors[i], expectedErrorMatchers[i]);
            }
          }

          // Call custom verify function if provided
          await verify?.call(velo);
        } finally {
          velo.removeListener(stateListener);
        }
      } finally {
        velo.dispose();
        await tearDown?.call();
      }
    },
    tags: tags,
    timeout: timeout != null ? test.Timeout(timeout) : null,
  );
}
