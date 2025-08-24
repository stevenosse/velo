import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
/// [expect] is an optional [Function] that returns a [Matcher] which the [Velo]
/// under test is expected to emit after [act] is executed.
///
/// [errors] is an optional [Function] that returns a [Matcher] which the [Velo]
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
  bool verify = true,
  Map<String, dynamic>? tags,
  Timeout? timeout,
}) {
  test(
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

          if (wait != null) {
            await Future<void>.delayed(wait);
          }

          if (expect != null) {
            final dynamic expected = expect();
            final List<S> expectedStates = expected is List<S>
                ? expected
                : expected is Iterable<S>
                ? expected.toList()
                : <S>[expected as S];

            final List<S> actualStates = skip > 0
                ? states.skip(skip).toList()
                : states;

            if (verify) {
              expect(actualStates, equals(expectedStates));
            }
          }

          if (errors != null) {
            final dynamic expectedErrors = errors();
            final List<Object> expectedErrorsList = expectedErrors is List
                ? List<Object>.from(expectedErrors)
                : expectedErrors is Iterable
                ? List<Object>.from(expectedErrors)
                : <Object>[expectedErrors as Object];

            if (verify) {
              expect(veloErrors, equals(expectedErrorsList));
            }
          }
        } finally {
          velo.removeListener(stateListener);
        }
      } finally {
        await tearDown?.call();
      }
    },
    tags: tags,
    timeout: timeout,
  );
}

/// A variant of [veloTest] that uses the standard `test` function instead of `testWidgets`.
/// This is useful when you don't need widget testing capabilities.
@isTest
void veloTestGroup<V extends Velo<S>, S>(
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
  bool verify = true,
  Map<String, dynamic>? tags,
  Timeout? timeout,
}) {
  test(
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

          if (wait != null) {
            await Future<void>.delayed(wait);
          }

          if (expect != null) {
            final dynamic expected = expect();
            final List<S> expectedStates = expected is List<S>
                ? expected
                : expected is Iterable<S>
                ? expected.toList()
                : <S>[expected as S];

            final List<S> actualStates = skip > 0
                ? states.skip(skip).toList()
                : states;

            if (verify) {
              expect(actualStates, equals(expectedStates));
            }
          }

          if (errors != null) {
            final dynamic expectedErrors = errors();
            final List<Object> expectedErrorsList = expectedErrors is List
                ? List<Object>.from(expectedErrors)
                : expectedErrors is Iterable
                ? List<Object>.from(expectedErrors)
                : <Object>[expectedErrors as Object];

            if (verify) {
              expect(veloErrors, equals(expectedErrorsList));
            }
          }
        } finally {
          velo.removeListener(stateListener);
        }
      } finally {
        await tearDown?.call();
      }
    },
    tags: tags,
    timeout: timeout,
  );
}
