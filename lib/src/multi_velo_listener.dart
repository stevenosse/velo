import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MultiStateNotifierListener extends StatelessWidget {
  const MultiStateNotifierListener({super.key, required this.child, required this.listeners});

  final Widget child;
  final List<SingleChildWidget> listeners;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listeners,
      child: child,
    );
  }
}
