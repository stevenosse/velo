# Velo 🚴‍♂️

[![CI](https://github.com/username/velo/actions/workflows/ci.yml/badge.svg)](https://github.com/username/velo/actions/workflows/ci.yml)
[![Coverage](https://github.com/username/velo/actions/workflows/coverage.yml/badge.svg)](https://github.com/username/velo/actions/workflows/coverage.yml)
[![Quality](https://github.com/username/velo/actions/workflows/quality.yml/badge.svg)](https://github.com/username/velo/actions/workflows/quality.yml)
[![codecov](https://codecov.io/gh/username/velo/branch/main/graph/badge.svg)](https://codecov.io/gh/username/velo)

[![pub package](https://img.shields.io/pub/v/velo.svg)](https://pub.dev/packages/velo)
[![pub points](https://img.shields.io/pub/points/velo)](https://pub.dev/packages/velo/score)
[![popularity](https://img.shields.io/pub/popularity/velo)](https://pub.dev/packages/velo/score)
[![likes](https://img.shields.io/pub/likes/velo)](https://pub.dev/packages/velo/score)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter_lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)

A simple and efficient state management solution for Flutter, inspired by `flutter_bloc` but keeping only the essentials.

Velo takes the `Cubit` concept from `flutter_bloc` and builds upon Flutter's native `ValueNotifier` with `Equatable` support for efficient state comparisons.

## 🌟 Features

- **Simple** : Built on Flutter's native `ValueNotifier`
- **Efficient** : Integrates with `Equatable` to avoid unnecessary rebuilds  
- **Lightweight** : Only essential components, no superfluous complexity
- **Compatible** : Works perfectly with the `Provider` package
- **Complete** : Includes builder, consumer, and listener widgets

## 🚀 Installation

Add `velo` to your `pubspec.yaml`:

```yaml
dependencies:
  velo: ^1.0.0
  provider: ^6.1.5
  equatable: ^2.0.7
```

## 📚 Usage

### 1. Define a State

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

### 3. Use with Widgets

#### VeloBuilder - For UI Rebuilding

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

#### VeloListener - For Side Effects

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

#### VeloConsumer - Combined Builder + Listener

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

### Velo&lt;S&gt;

Abstract main class that extends `ValueNotifier&lt;S&gt;`.

#### Methods

- `emit(S state)` : Emits a new state if different from the previous one
- `emitAsync(Future&lt;S&gt; futureState)` : Emits a state from a Future
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

## 💡 Best Practices

1. **Immutable States** : Always use `copyWith()` to create new states
2. **Equatable** : Implement `Equatable` to avoid unnecessary rebuilds  
3. **Dispose** : Don't forget to dispose your Velos with Provider
4. **Separation** : One Velo per business domain
5. **Testing** : Test your Velos as simple Dart classes

## 🧪 Testing

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterVelo', () {
    late CounterVelo counterVelo;

    setUp(() {
      counterVelo = CounterVelo();
    });

    tearDown(() {
      counterVelo.dispose();
    });

    test('initial state', () {
      expect(counterVelo.state, const CounterState());
    });

    test('increment', () {
      counterVelo.increment();
      expect(counterVelo.state.count, 1);
    });
  });
}
```

## 🆚 Comparison with flutter_bloc

| Aspect | Velo | flutter_bloc |
|--------|------|--------------|
| Size | ~500 lines | ~5000+ lines |
| Complexity | Simple | Complex |
| Learning curve | Low | High |
| Performance | Excellent | Excellent |
| Features | Essential | Complete |

## 🔍 Code Quality

Velo maintains high code quality standards:

- **100% Test Coverage**: All code paths are tested
- **Static Analysis**: Passes all Flutter linter rules  
- **CI/CD**: Automated testing on every commit
- **Security Scanning**: Regular security vulnerability checks
- **Documentation**: Comprehensive API documentation

### Quality Metrics

- ✅ All tests pass on multiple platforms (Linux, macOS, Windows)
- ✅ Zero linter warnings or errors
- ✅ 100% documented public API
- ✅ Semantic versioning
- ✅ Changelog maintained

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/velo.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Make your changes
6. Run quality checks: `flutter analyze && dart format --set-exit-if-changed .`
7. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.
