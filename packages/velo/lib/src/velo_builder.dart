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
/// - [errorWidget]: Optional widget shown when an error occurs. Defaults to [SizedBox.shrink].
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
///   errorWidget: Text('Something went wrong'),
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
class VeloBuilder<N extends Velo<T>, T> extends StatelessWidget {
  /// Creates a [VeloBuilder] widget that listens to a [Velo] and rebuilds on state changes.
  ///
  /// The [builder] parameter is required and defines how to build the widget based on the current state.
  ///
  /// The [notifier] parameter is optional. If not provided, [VeloBuilder] will attempt
  /// to find the [Velo] instance using [Provider.of] from the widget tree.
  ///
  /// The [errorWidget] parameter is optional and will be shown if an error occurs
  /// during building. If not provided, defaults to [SizedBox.shrink].
  ///
  /// **Example:**
  /// ```dart
  /// VeloBuilder<CounterVelo, CounterState>(
  ///   builder: (context, state) => Text('Count: ${state.count}'),
  ///   errorWidget: Icon(Icons.error),
  /// )
  /// ```
  const VeloBuilder({
    super.key,
    this.notifier,
    required this.builder,
    this.errorWidget,
  });

  /// The [Velo] notifier to listen to for state changes.
  ///
  /// If null, [VeloBuilder] will attempt to find an instance of type [N]
  /// in the widget tree using [Provider.of].
  final N? notifier;

  /// A function that describes the part of the user interface represented by this widget.
  ///
  /// The builder function is called with the current [BuildContext] and the current state [T]
  /// whenever the state changes. It should return a widget that represents the UI for the given state.
  ///
  /// **Example:**
  /// ```dart
  /// builder: (context, state) {
  ///   return Text('Current value: ${state.value}');
  /// }
  /// ```
  final Widget Function(BuildContext context, T state) builder;

  /// An optional widget to display when an error occurs during building.
  ///
  /// If the [builder] function throws an exception or if the [notifier] cannot be found
  /// in the widget tree, this widget will be displayed instead of the normal content.
  ///
  /// If null, defaults to [SizedBox.shrink] which renders an empty space.
  ///
  /// **Example:**
  /// ```dart
  /// errorWidget: Icon(Icons.error, color: Colors.red)
  /// ```
  final Widget? errorWidget;

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
            return errorWidget ?? const SizedBox.shrink();
          }
        },
      );
    } on Exception catch (error) {
      debugPrint(
        'VeloBuilder: Failed to find notifier of type $N in widget tree: $error',
      );
      return errorWidget ?? const SizedBox.shrink();
    }
  }
}
