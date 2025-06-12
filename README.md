# State Notifier

A clean state management solution for Flutter applications based on `ValueNotifier` with `Equatable` support.

## Features

- Simple state management based on Flutter's built-in `ValueNotifier`
- Integration with `Equatable` for efficient state comparison
- Compatible with Flutter's Provider package
- Includes builder, consumer, and listener widgets for different use cases

## Usage

### Define a state

```dart
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;
  
  const CounterState({this.count = 0});
  
  @override
  List<Object?> get props => [count];
  
  CounterState copyWith({int? count}) {
    return CounterState(
      count: count ?? this.count,
    );
  }
}
```

### Create a Velo

```dart
import 'package:velo/velo.dart';

class CounterNotifier extends Velo<CounterState> {
  CounterNotifier() : super(const CounterState());
  
  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }
  
  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }
}
```

### Use in a widget

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Provider<CounterNotifier>(
      create: (_) => CounterNotifier(),
      dispose: (_, notifier) => notifier.dispose(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Counter Example')),
            body: VeloBuilder<CounterNotifier, CounterState>(
              builder: (context, state) {
                return Center(
                  child: Text(
                    'Count: ${state.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
              },
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    context.read<CounterNotifier>().increment();
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  child: const Icon(Icons.remove),
                  onPressed: () {
                    context.read<CounterNotifier>().decrement();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```
