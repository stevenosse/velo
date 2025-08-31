import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

/// Extension methods for [WidgetTester] to simplify Velo widget testing.
extension VeloWidgetTester on WidgetTester {
  /// Pumps a widget with the provided Velo instances.
  Future<void> pumpVeloWidget<T extends Velo<dynamic>>(
    Widget widget, {
    List<T>? velos,
    bool wrapInMaterialApp = true,
  }) async {
    ArgumentError.checkNotNull(widget, 'widget');

    if (velos != null) {
      for (int i = 0; i < velos.length; i++) {
        ArgumentError.checkNotNull(velos[i], 'velos[$i]');
      }
    }

    Widget testWidget = widget;

    try {
      if (velos != null && velos.isNotEmpty) {
        testWidget = MultiProvider(
          providers: velos
              .map((velo) => ChangeNotifierProvider<T>.value(value: velo))
              .toList(),
          child: testWidget,
        );
      }

      if (wrapInMaterialApp) {
        testWidget = MaterialApp(home: Scaffold(body: testWidget));
      }

      await pumpWidget(testWidget);
    } catch (e) {
      throw StateError('Unexpected error while pumping widget: $e');
    }
  }

  /// Finds a VeloBuilder widget by its Velo type.
  Finder findVeloBuilder<T extends Velo<dynamic>>() =>
      find.byWidgetPredicate((widget) => widget is VeloBuilder<T, dynamic>);

  /// Finds a VeloListener widget by its Velo type.
  Finder findVeloListener<T extends Velo<dynamic>>() =>
      find.byWidgetPredicate((widget) => widget is VeloListener<T, dynamic>);

  /// Finds a VeloConsumer widget by its Velo type.
  Finder findVeloConsumer<T extends Velo<dynamic>>() =>
      find.byWidgetPredicate((widget) => widget is VeloConsumer<T, dynamic>);

  /// Waits for a specific state to be present in a VeloBuilder.
  Future<void> waitForVeloState<T extends Velo<dynamic>, S>(
    S expectedState, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    ArgumentError.checkNotNull(expectedState, 'expectedState');
    ArgumentError.checkNotNull(timeout, 'timeout');

    if (timeout.isNegative) {
      throw ArgumentError.value(timeout, 'timeout', 'Cannot be negative');
    }

    try {
      await waitFor(() {
        try {
          final context = element(find.byType(MaterialApp));
          final velo = Provider.of<T>(context, listen: false);
          return velo.state == expectedState;
        } on ProviderNotFoundException catch (e) {
          throw StateError(
            'Velo of type $T not found in widget tree. '
            'Make sure to provide it using pumpVeloWidget or similar. '
            'Original error: $e',
          );
        }
      }, timeout: timeout);
    } catch (e) {
      throw StateError('Failed to wait for Velo state $expectedState: $e');
    }
  }

  /// Triggers a rebuild by calling setState on a StatefulWidget.
  Future<void> triggerRebuild() async {
    await pump(Duration.zero);
  }
}

/// Helper class for creating mock widgets that use Velo.
class VeloTestWidget<T extends Velo<S>, S> extends StatelessWidget {
  const VeloTestWidget({
    super.key,
    required this.velo,
    this.builder,
    this.listener,
    this.child,
  });

  final T velo;
  final Widget Function(BuildContext, S)? builder;
  final void Function(BuildContext, S)? listener;
  final Widget? child;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<T>.value(
    value: velo,
    child: MaterialApp(
      home: Scaffold(
        body: builder != null
            ? VeloBuilder<T, S>(
                builder: builder!,
                errorWidget: const Text('Test Error'),
              )
            : listener != null
            ? VeloListener<T, S>(
                listener: listener!,
                child: child ?? const SizedBox(),
              )
            : child ?? const SizedBox(),
      ),
    ),
  );
}

/// Creates a test widget that wraps a VeloBuilder.
Widget createVeloBuilderTestWidget<T extends Velo<S>, S>({
  required T velo,
  required Widget Function(BuildContext, S) builder,
}) => VeloTestWidget<T, S>(velo: velo, builder: builder);

/// Creates a test widget that wraps a VeloListener.
Widget createVeloListenerTestWidget<T extends Velo<S>, S>({
  required T velo,
  required void Function(BuildContext, S) listener,
  Widget? child,
}) => VeloTestWidget<T, S>(velo: velo, listener: listener, child: child);

/// Utility function to wait for a condition with a timeout.
Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  ArgumentError.checkNotNull(condition, 'condition');
  ArgumentError.checkNotNull(timeout, 'timeout');
  ArgumentError.checkNotNull(interval, 'interval');

  if (timeout.isNegative) {
    throw ArgumentError.value(timeout, 'timeout', 'Cannot be negative');
  }

  if (interval.isNegative || interval == Duration.zero) {
    throw ArgumentError.value(interval, 'interval', 'Must be positive');
  }

  final stopwatch = Stopwatch()..start();
  Object? lastError;

  while (stopwatch.elapsed < timeout) {
    try {
      if (condition()) {
        return; // Condition met, exit successfully
      }
    } on Exception catch (error) {
      lastError = error;
      // Continue trying unless timeout is reached
    }

    await Future<void>.delayed(interval);
  }

  // Timeout reached
  final errorMessage = StringBuffer(
    'Condition was not met within ${timeout.inMilliseconds}ms',
  );
  if (lastError != null) {
    errorMessage.write('. Last error: $lastError');
  }

  throw TimeoutException(errorMessage.toString(), timeout);
}

/// Exception thrown when a condition times out.
class TimeoutException implements Exception {
  const TimeoutException(this.message, this.timeout);

  final String message;
  final Duration timeout;

  @override
  String toString() => 'TimeoutException: $message';
}
