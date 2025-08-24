import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'velo.dart';

/// A widget that provides multiple [Velo] instances to the widget tree.
///
/// [MultiVeloListener] is a convenience widget that wraps [MultiProvider]
/// to provide multiple state management instances at once. This is useful
/// when you need to provide several [Velo] instances to a subtree.
///
/// **Parameters:**
/// - [listeners]: A list of Provider widgets (typically [ChangeNotifierProvider])
/// - [child]: The widget subtree that will have access to the provided instances
///
/// **Example:**
/// ```dart
/// MultiVeloListener(
///   listeners: [
///     ChangeNotifierProvider<UserVelo>(
///       create: (_) => UserVelo(),
///     ),
///     ChangeNotifierProvider<CartVelo>(
///       create: (_) => CartVelo(),
///     ),
///     ChangeNotifierProvider<ThemeVelo>(
///       create: (_) => ThemeVelo(),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// **Note:** This widget requires at least one provider in the [listeners] list.
/// An empty list will cause an assertion error.
///
/// See also:
/// - [MultiProvider] - The underlying widget from the Provider package
/// - [ChangeNotifierProvider] - Used to provide [Velo] instances
class MultiVeloListener extends StatelessWidget {
  /// Creates a [MultiVeloListener] widget.
  ///
  /// The [listeners] and [child] parameters must not be null.
  /// The [listeners] list must contain at least one provider.
  const MultiVeloListener({
    super.key,
    required this.child,
    required this.listeners,
  });

  /// The widget subtree that will have access to the provided [Velo] instances.
  final Widget child;

  /// A list of provider widgets that will be made available to [child].
  ///
  /// Typically contains [ChangeNotifierProvider] widgets with [Velo] instances.
  final List<SingleChildWidget> listeners;

  @override
  Widget build(BuildContext context) =>
      MultiProvider(providers: listeners, child: child);
}
