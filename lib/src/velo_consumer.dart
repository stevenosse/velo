import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/src/velo.dart';

class StateNotifierConsumer<N extends Velo<T>, T> extends StatefulWidget {
  final N? notifier;
  final Widget Function(BuildContext context, T state) builder;
  final void Function(BuildContext context, T state)? listener;

  const StateNotifierConsumer({
    super.key,
    this.notifier,
    required this.builder,
    this.listener,
  });

  @override
  State<StateNotifierConsumer<N, T>> createState() => _StateNotifierConsumerState<N, T>();
}

class _StateNotifierConsumerState<N extends Velo<T>, T> extends State<StateNotifierConsumer<N, T>> {
  late N notifier;
  @override
  void initState() {
    super.initState();
    try {
      notifier = widget.notifier ?? context.read<N>();
      notifier.addListener(_handleStateChange);
    } catch (error) {
      // Handle case where notifier is not found in widget tree
      debugPrint('StateNotifierConsumer: Failed to find notifier of type $N in widget tree');
      rethrow;
    }
  }

  @override
  void dispose() {
    try {
      notifier.removeListener(_handleStateChange);
    } catch (error) {
      // Notifier might already be disposed or not available
      debugPrint('StateNotifierConsumer: Failed to remove listener during dispose');
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StateNotifierConsumer<N, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNotifier = oldWidget.notifier ?? context.read<N>();
    final newNotifier = widget.notifier ?? context.read<N>();

    if (oldNotifier != newNotifier) {
      oldNotifier.removeListener(_handleStateChange);
      newNotifier.addListener(_handleStateChange);
    }
  }

  void _handleStateChange() {
    if (mounted) {
      try {
        setState(() {});
        final notifier = widget.notifier ?? context.read<N>();
        widget.listener?.call(context, notifier.state);
      } catch (error) {
        debugPrint('StateNotifierConsumer: Error in state change handler: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier ?? context.read<N>();

    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, state, _) {
        return widget.builder(context, state);
      },
    );
  }
}
