/// A simple and efficient state management solution for Flutter.
///
/// Velo is inspired by `flutter_bloc`'s Cubit pattern but focuses on simplicity
/// and efficiency. It builds upon Flutter's native [ValueNotifier] and integrates
/// with [Equatable] for optimal state comparisons.
///
/// ## Getting Started
///
/// 1. Define your state class using [Equatable]:
/// ```dart
/// class CounterState extends Equatable {
///   final int count;
///   const CounterState({this.count = 0});
///
///   @override
///   List<Object?> get props => [count];
/// }
/// ```
///
/// 2. Create a Velo class to manage your state:
/// ```dart
/// class CounterVelo extends Velo<CounterState> {
///   CounterVelo() : super(const CounterState());
///
///   void increment() {
///     emit(state.copyWith(count: state.count + 1));
///   }
/// }
/// ```
///
/// 3. Use Velo widgets in your UI:
/// ```dart
/// VeloBuilder<CounterVelo, CounterState>(
///   builder: (context, state) {
///     return Text('Count: ${state.count}');
///   },
/// )
/// ```
///
/// ## Available Widgets
///
/// - [VeloBuilder]: Rebuilds when state changes
/// - [VeloListener]: Performs side effects without rebuilding
/// - [VeloConsumer]: Combines builder and listener functionality
/// - [MultiVeloListener]: Provides multiple Velo instances
///
/// ## Integration with Provider
///
/// Velo works seamlessly with the Provider package:
/// ```dart
/// Provider<CounterVelo>(
///   create: (_) => CounterVelo(),
///   dispose: (_, velo) => velo.dispose(),
///   child: MyApp(),
/// )
/// ```
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'velo.dart';

export 'src/multi_velo_listener.dart';
export 'src/velo.dart';
export 'src/velo_builder.dart';
export 'src/velo_consumer.dart';
export 'src/velo_listener.dart';
