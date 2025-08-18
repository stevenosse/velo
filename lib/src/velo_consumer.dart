import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../velo.dart' show VeloBuilder, VeloListener;
import 'velo.dart';

/// A widget that combines [VeloBuilder] and [VeloListener] functionality.
///
/// [VeloConsumer] allows you to both rebuild your UI and perform side effects
/// in response to state changes from a [Velo].
///
/// **Parameters:**
/// - [notifier]: Optional [Velo] instance. If null, will use [Provider] to find it.
/// - [builder]: Function called to build the widget with the current state.
/// - [listener]: Optional function called when the state changes (for side effects).
///
/// **Example:**
/// ```dart
/// VeloConsumer<CounterVelo, CounterState>(
///   listener: (context, state) {
///     if (state.count > 10) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Counter is high!')),
///       );
///     }
///   },
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
///
/// **Note:** The listener is only called when the state actually changes,
/// not on every rebuild. This is efficient for side effects like navigation
/// or showing dialogs.
class VeloConsumer<N extends Velo<T>, T> extends StatefulWidget {
  const VeloConsumer({
    super.key,
    this.notifier,
    required this.builder,
    this.listener,
  });
  final N? notifier;
  final Widget Function(BuildContext context, T state) builder;
  final void Function(BuildContext context, T state)? listener;

  @override
  State<VeloConsumer<N, T>> createState() => _VeloConsumerState<N, T>();
}

class _VeloConsumerState<N extends Velo<T>, T>
    extends State<VeloConsumer<N, T>> {
  late N notifier;
  T? previousState;

  @override
  void initState() {
    super.initState();
    try {
      notifier = widget.notifier ?? context.read<N>();
      previousState = notifier.state;
    } catch (error) {
      // Handle case where notifier is not found in widget tree
      debugPrint(
          'VeloConsumer: Failed to find notifier of type $N in widget tree');
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VeloConsumer<N, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      final newNotifier = widget.notifier ?? context.read<N>();
      if (notifier != newNotifier) {
        final oldState = previousState;
        notifier = newNotifier;
        previousState = notifier.state;

        // Call listener if the new notifier has a different state
        if (widget.listener != null && oldState != notifier.state && mounted) {
          try {
            widget.listener!.call(context, notifier.state);
          } on Exception catch (error) {
            debugPrint(
                'VeloConsumer: Error in listener callback during update: $error');
          }
        }
      }
    } on Exception catch (error) {
      debugPrint('VeloConsumer: Error updating notifier: $error');
    }
  }

  void _callListenerIfNeeded(T currentState) {
    if (widget.listener != null && previousState != currentState && mounted) {
      try {
        widget.listener!.call(context, currentState);
        previousState = currentState;
      } on Exception catch (error) {
        debugPrint('VeloConsumer: Error in listener callback: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, state, _) {
          _callListenerIfNeeded(state);
          return widget.builder(context, state);
        },
      );
}
