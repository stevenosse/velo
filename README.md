# Velo Workspace

A comprehensive state management solution for Flutter applications, consisting of multiple packages for different use cases.

## Packages

This workspace contains the following packages:

### 📦 [velo](packages/velo/)

A lightweight, type-safe state management solution for Flutter applications built on top of ValueNotifier and Provider.

**Features:**
- 🚀 **Lightweight**: Minimal overhead with maximum performance
- 🔒 **Type-safe**: Full type safety with generic support
- 🎯 **Simple API**: Easy to learn and use
- 🔄 **Reactive**: Automatic UI updates when state changes
- 🧪 **Testable**: Built with testing in mind
- 📦 **Minimal dependencies**: Only depends on Flutter SDK and essential packages
- 🎨 **Flutter-first**: Designed specifically for Flutter applications

### 🧪 [velo_test](packages/velo_test/)

Testing utilities and helpers for the Velo state management package.

**Features:**
- 🎯 **Mock Velo classes**: Easy mocking for unit tests
- 📊 **State verification**: Verify state emissions and changes
- 🔍 **Widget testing**: Specialized helpers for widget tests
- ⏱️ **Async testing**: Support for testing async state changes
- 📈 **Test coverage**: Comprehensive testing utilities

## Quick start

For detailed usage instructions and examples, please refer to the individual package documentation:

- **[Velo package documentation](packages/velo/README.md)** - Core state management functionality
- **[Velo test package documentation](packages/velo_test/README.md)** - Testing utilities and helpers

### Basic example

Here's a simple counter example using Velo:

```dart
// 1. Define your state
class CounterState extends Equatable {
  const CounterState({this.count = 0});
  final int count;
  
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
  
  @override
  List<Object> get props => [count];
}

// 2. Create your Velo class
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());
  
  void increment() => emit(state.copyWith(count: state.count + 1));
  void decrement() => emit(state.copyWith(count: state.count - 1));
}

// 3. Use in your UI
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CounterVelo(),
      child: Scaffold(
        body: Center(
          child: VeloBuilder<CounterVelo, CounterState>(
            builder: (context, state) => Text('${state.count}'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<CounterVelo>().increment(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

## Installation

Add the packages you need to your `pubspec.yaml`:

```yaml
dependencies:
  velo: ^1.0.0
  
dev_dependencies:
  velo_test: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📚 Usage

### 1. Define a state

Create your state class by extending `Equatable`:

```dart
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;
  final bool isLoading;
  
  const CounterState({
    this.count = 0,
    this.isLoading = false,
  });
  
  @override
  List<Object?> get props => [count, isLoading];
  
  CounterState copyWith({
    int? count,
    bool? isLoading,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

### 2. Create a Velo

Extend the `Velo` class to create your state manager:

```dart
import 'package:velo/velo.dart';

class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());
  
  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }
  
  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }
  
  Future<void> incrementAsync() async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(state.copyWith(
      count: state.count + 1,
      isLoading: false,
    ));
  }
}
```

### 3. Use with widgets

#### VeloBuilder - For UI rebuilding

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Provider<CounterVelo>(
      create: (_) => CounterVelo(),
      dispose: (_, velo) => velo.dispose(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Velo Counter')),
        body: Center(
          child: VeloBuilder<CounterVelo, CounterState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const CircularProgressIndicator();
              }
              
              return Text(
                'Count: ${state.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => context.read<CounterVelo>().increment(),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
```

#### VeloListener - For side effects

```dart
VeloListener<CounterVelo, CounterState>(
  listener: (context, state) {
    if (state.count > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('High counter!')),
      );
    }
  },
  child: VeloBuilder<CounterVelo, CounterState>(
    builder: (context, state) {
      return Text('Count: ${state.count}');
    },
  ),
)
```

#### VeloConsumer - Combined builder + listener

```dart
VeloConsumer<CounterVelo, CounterState>(
  listener: (context, state) {
    // Side effects
    if (state.count < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Negative counter')),
      );
    }
  },
  builder: (context, state) {
    // UI building
    return Text('Count: ${state.count}');
  },
)
```

## 🔧 API Reference

### Velo<S>

Abstract main class that extends `ValueNotifier<S>`.

#### Methods

- `emit(S state)` : Emits a new state if different from the previous one
- `emitAsync(Future<S> futureState)` : Emits a state from a Future
- `S get state` : Gets the current state

### Widgets

#### VeloBuilder<N, S>

Rebuilds the UI when state changes.

```dart
VeloBuilder<MyVelo, MyState>(
  builder: (context, state) => Widget,
  loadingWidget: Widget?, // Widget displayed on error
)
```

#### VeloListener<N, S>

Listens to state changes without rebuilding.

```dart
VeloListener<MyVelo, MyState>(
  listener: (context, state) => void,
  child: Widget,
)
```

#### VeloConsumer<N, S>

Combines `VeloBuilder` and `VeloListener`.

```dart
VeloConsumer<MyVelo, MyState>(
  builder: (context, state) => Widget,
  listener: (context, state) => void,
)
```

#### MultiVeloListener

Provides multiple Velos in the widget tree.

```dart
MultiVeloListener(
  listeners: [
    Provider<CounterVelo>(create: (_) => CounterVelo()),
    Provider<UserVelo>(create: (_) => UserVelo()),
  ],
  child: MyWidget(),
)
```

## 💡 Best practices

1. **Immutable States** : Always use `copyWith()` to create new states
2. **Equatable** : Implement `Equatable` to avoid unnecessary rebuilds  
3. **Dispose** : Don't forget to dispose your Velos with Provider
4. **Separation** : One Velo per business domain
5. **Testing** : You can use https://pub.dev/packages/velo_test to test your Velos

## 🆚 Comparison with flutter_bloc

| Aspect | Velo | flutter_bloc |
|--------|------|--------------|
| Size | ~500 lines | ~5000+ lines |
| Complexity | Simple | Complex |
| Learning curve | Low | High |
| Performance | Excellent | Excellent |
| Features | Essential | Complete |

## Example project

Check out the [example](example/) directory for a complete Flutter application demonstrating how to use Velo in practice.

## Development

This is a multi-package workspace. To work with the packages:

### Getting started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/velo.git
   cd velo
   ```

2. Get workspace dependencies:
   ```bash
   flutter pub get
   ```

3. Get dependencies for individual packages:
   ```bash
   cd packages/velo && flutter pub get
   cd ../velo_test && flutter pub get
   ```

### Running tests

Run tests for all packages:
```bash
# Test velo package
cd packages/velo && flutter test

# Test velo_test package
cd packages/velo_test && flutter test
```

### Building the example

```bash
cd example
flutter pub get
flutter run
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/velo.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Make your changes
6. Run quality checks: `flutter analyze && dart format --set-exit-if-changed .`
7. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.
