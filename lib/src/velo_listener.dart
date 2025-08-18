import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'velo.dart';

/// A widget that listens to changes in a Velo without rebuilding.
///
/// This is useful when you want to perform side effects (like showing a snackbar)
/// in response to state changes without rebuilding the widget tree.
class VeloListener<N extends Velo<T>, T> extends SingleChildStatefulWidget {
  const VeloListener({
    super.key,
    this.notifier,
    required this.listener,
    super.child,
  });

  final N? notifier;
  final void Function(BuildContext context, T state) listener;

  @override
  State<StatefulWidget> createState() => _VeloListenerState<N, T>();
}

class _VeloListenerState<N extends Velo<T>, T>
    extends SingleChildState<VeloListener<N, T>> {
  late final N notifier;
  late T state;

  @override
  void initState() {
    super.initState();
    try {
      notifier = widget.notifier ?? context.read<N>();
      state = notifier.state;
      notifier.addListener(_handleStateChange);
    } catch (error) {
      debugPrint(
          'VeloListener: Failed to find notifier of type $N in widget tree');
      rethrow;
    }
  }

  void _handleStateChange() {
    if (mounted && _hasStateChanged(notifier.state, state)) {
      final newState = notifier.state;
      state = newState;
      try {
        widget.listener(context, newState);
      } on Exception catch (error) {
        debugPrint('VeloListener: Error in listener callback: $error');
      }
    }
  }

  bool _hasStateChanged(T newState, T oldState) {
    if (newState is Equatable && oldState is Equatable) {
      return newState != oldState;
    }
    return newState != oldState;
  }

  @override
  void dispose() {
    try {
      notifier.removeListener(_handleStateChange);
    } on Exception catch (error) {
      debugPrint(
          'VeloListener: Error removing listener during dispose: $error');
    }
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();
}
