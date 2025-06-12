import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

class StateNotifierBuilder<N extends Velo<T>, T> extends StatelessWidget {
  final N? notifier;
  final Widget Function(BuildContext context, T state) builder;
  final Widget? loadingWidget;

  const StateNotifierBuilder({
    super.key,
    this.notifier,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final notifier = this.notifier ?? context.read<N>();

      return ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, state, _) {
          try {
            return builder(context, state);
          } catch (error) {
            debugPrint('StateNotifierBuilder: Error in builder callback: $error');
            return loadingWidget ?? const SizedBox.shrink();
          }
        },
      );
    } catch (error) {
      debugPrint('StateNotifierBuilder: Failed to find notifier of type $N in widget tree');
      return loadingWidget ?? const SizedBox.shrink();
    }
  }
}
