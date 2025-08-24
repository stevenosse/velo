# Velo

A simple and efficient state management solution for Flutter, inspired by flutter_bloc but keeping only the essentials.

## Features

- 🚀 **Simple**: Easy to learn and use
- ⚡ **Efficient**: Built on Flutter's native ValueNotifier
- 🔄 **Reactive**: Automatic UI updates when state changes
- 🧪 **Testable**: Easy to test with built-in testing utilities
- 📦 **Lightweight**: Minimal dependencies
- 🎯 **Type-safe**: Full TypeScript-like type safety

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  velo: ^1.0.0
```

## Quick Start

### 1. Define your state

```dart
class CounterState extends Equatable {
  final int count;
  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }

  @override
  List<Object?> get props => [count];
}
```

### 2. Create a Velo class

```dart
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }
}
```

### 3. Use in your UI

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VeloBuilder<CounterVelo, CounterState>(
          builder: (context, state) {
            return Text('Count: ${state.count}');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterVelo>().increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Available Widgets

- **VeloBuilder**: Rebuilds when state changes
- **VeloListener**: Performs side effects without rebuilding
- **VeloConsumer**: Combines builder and listener functionality
- **MultiVeloListener**: Provides multiple Velo instances

## Documentation

For more detailed documentation, examples, and best practices, visit our [GitHub repository](https://github.com/steve-nosse/velo).

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.