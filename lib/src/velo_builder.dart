import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../velo.dart';

/// A widget that listens to a [Velo] and rebuilds whenever the state changes.
/// 
/// [VeloBuilder] is the primary way to consume state from a [Velo] in your UI.
/// It automatically rebuilds when the state changes and provides error handling.
/// 
/// **Parameters:**
/// - [notifier]: Optional [Velo] instance. If null, will use [Provider] to find it.
/// - [builder]: Function called to build the widget with the current state.
/// - [loadingWidget]: Optional widget shown when an error occurs. Defaults to [SizedBox.shrink].
/// 
/// **Example:**
/// ```dart
/// VeloBuilder<CounterVelo, CounterState>(
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
/// 
/// **With error handling:**
/// ```dart
/// VeloBuilder<CounterVelo, CounterState>(
///   loadingWidget: Text('Something went wrong'),
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
class VeloBuilder<N extends Velo<T>, T> extends StatelessWidget {

  const VeloBuilder({
    super.key,
    this.notifier,
    required this.builder,
    this.loadingWidget,
  });
  final N? notifier;
  final Widget Function(BuildContext context, T state) builder;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    try {
      final notifier = this.notifier ?? context.read<N>();

      return ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, state, _) {
          try {
            return builder(context, state);
          } on Exception catch (error) {
            debugPrint('VeloBuilder: Error in builder callback: $error');
            return loadingWidget ?? const SizedBox.shrink();
          }
        },
      );
    } on Exception catch (error) {
      debugPrint('VeloBuilder: Failed to find notifier of type $N in widget tree: $error');
      return loadingWidget ?? const SizedBox.shrink();
    }
  }
}
